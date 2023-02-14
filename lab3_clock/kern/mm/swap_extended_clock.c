#include <defs.h>
#include <x86.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include<swap_extended_clock.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a extended_clock algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While extended_clock is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of extended_clock PRA
 * (1) Prepare: In order to implement extended_clock PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

list_entry_t pra_list_head;
/*
 * (2) _extended_clock_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access extended_clock PRA
 */
static int
_extended_clock_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in extended_clock_init_mm\n",mm->sm_priv);
     return 0;
}
/*
 * (3)_extended_clock_map_swappable: According extended_clock PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_extended_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && head != NULL);

    list_add(head, entry);
    // 初始访问位和修改位均置0
    struct Page *ptr = le2page(entry, pra_page_link);
    pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
    // 将PTE_A（访问位）和PTE_D（读写位）置0
    *pte &= ~PTE_D;
    *pte &= ~PTE_A;
    
    
    return 0;
}
/*
 *  (4)_extended_clock_swap_out_victim: According extended_clock PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_extended_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     // 两个指针，一个指向头，一个指向尾
    list_entry_t *head = (list_entry_t*)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    list_entry_t *tail = head->prev;
    int i;
    for (i = 0; i <= 3; i ++) {
        while (tail != head) {
            struct Page *page = le2page(tail, pra_page_link);
            pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
            switch(i)
            {
                case 0:
                {
                    if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
                        list_del(tail);
                        cprintf("我们找到了(0,0)的页进行换出\n\n");
                        *ptr_page = page;
                        return 0;
                    }
                    tail = tail->prev;
                    break;
                }
                case 1:
                {
                    if( !(*ptep & PTE_A) && (*ptep & PTE_D) )
                    {
                        list_del(tail);
                        cprintf("我们找到了(0,1)的页进行换出\n\n");
                        *ptr_page = page;
                        return 0;
                    }
                    else
                    {
                        *ptep &= ~PTE_A;
                    }
                    tail = tail->prev;
                    break;
                }
                case 2:
                {
                    if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
                        list_del(tail);
                        cprintf("我们找到了(1,0)的页进行换出\n\n");
                        *ptr_page = page;
                        return 0;
                    }
                    tail = tail->prev;
                    break;
                }
                default:
                {
                    if( !(*ptep & PTE_A) && (*ptep & PTE_D) )
                    {
                        list_del(tail);
                        cprintf("我们找到了(1,1)的页进行换出\n\n");
                        *ptr_page = page;
                        return 0;
                    }
                    tail = tail->prev;
                }

            }
            
        }
        tail = tail->prev;
    
    }
    

    
}

static void visit(struct mm_struct *mm,uintptr_t addr,int value){
    *(unsigned char*) addr = value;
    //从虚拟地址获取pte
    uintptr_t *pte = get_pte(mm->pgdir,addr,0);
    //之后我们将访问位，以及direty位置1
    if(pte!=NULL)
    {
    *pte |=PTE_A ;
    *pte |=PTE_D;
    }
   
}



static int
_extended_clock_check_swap(struct mm_struct *mm) {
    cprintf("write Virt Page c in extended_clock_check_swap\n");
    //*(unsigned char *)0x3000 = 0x0c;
    visit(mm,0x3000,0x0c);
    assert(pgfault_num==4);
    cprintf("write Virt Page a in extended_clock_check_swap\n");
    //*(unsigned char *)0x1000 = 0x0a;
    visit(mm,0x1000,0x0a);
    assert(pgfault_num==4);
    cprintf("write Virt Page d in extended_clock_check_swap\n");
    //*(unsigned char *)0x4000 = 0x0d;
    visit(mm,0x4000,0x0d);
    assert(pgfault_num==4);
   /*cprintf("write Virt Page b in extended_clock_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);*/
    cprintf("write Virt Page e in extended_clock_check_swap\n");
    //*(unsigned char *)0x5000 = 0x0e;
    visit(mm,0x5000,0x0e);
    //assert(pgfault_num==5);
    cprintf("write Virt Page b in extended_clock_check_swap\n");
    //*(unsigned char *)0x2000 = 0x0b;
    visit(mm,0x2000,0x0b);
    //assert(pgfault_num==5);
    cprintf("write Virt Page a in extended_clock_check_swap\n");
    //*(unsigned char *)0x1000 = 0x0a;
    visit(mm,0x1000,0x0a);
    //assert(pgfault_num==6);
    cprintf("write Virt Page b in extended_clock_check_swap\n");
    //*(unsigned char *)0x2000 = 0x0b;
    visit(mm,0x2000,0x0b);
    //assert(pgfault_num==7);
    cprintf("write Virt Page c in extended_clock_check_swap\n");
    //*(unsigned char *)0x3000 = 0x0c;
    visit(mm,0x3000,0x0c);
    //assert(pgfault_num==8);
    cprintf("write Virt Page d in extended_clock_check_swap\n");
    //*(unsigned char *)0x4000 = 0x0d;
    visit(mm,0x4000,0x0d);
    //assert(pgfault_num==9);
    cprintf("write Virt Page e in extended_clock_check_swap\n");
    //*(unsigned char *)0x5000 = 0x0e;
    visit(mm,0x5000,0x0e);
    //assert(pgfault_num==10);
    cprintf("write Virt Page a in extended_clock_check_swap\n");
    //assert(*(unsigned char *)0x1000 == 0x0a);
    //*(unsigned char *)0x1000 = 0x0a;
    visit(mm,0x1000,0x0a);
    //assert(pgfault_num==11);
    return 0;
}


static int
_extended_clock_init(void)
{
    return 0;
}

static int
_extended_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_extended_clock_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_extended_clock =
{
     .name            = "extended_clock swap manager",
     .init            = &_extended_clock_init,
     .init_mm         = &_extended_clock_init_mm,
     .tick_event      = &_extended_clock_tick_event,
     .map_swappable   = &_extended_clock_map_swappable,
     .set_unswappable = &_extended_clock_set_unswappable,
     .swap_out_victim = &_extended_clock_swap_out_victim,
     .check_swap      = &_extended_clock_check_swap,
};
