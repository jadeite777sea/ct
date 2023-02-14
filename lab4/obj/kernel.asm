
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 12 00       	mov    $0x129000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 12 c0       	mov    %eax,0xc0129000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 12 c0       	mov    $0xc0128000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 54 e1 12 c0       	mov    $0xc012e154,%eax
c0100041:	2d 00 b0 12 c0       	sub    $0xc012b000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 b0 12 c0 	movl   $0xc012b000,(%esp)
c0100059:	e8 25 9f 00 00       	call   c0109f83 <memset>

    cons_init();                // init the console
c010005e:	e8 25 16 00 00       	call   c0101688 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 20 a1 10 c0 	movl   $0xc010a120,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 3c a1 10 c0 	movl   $0xc010a13c,(%esp)
c0100078:	e8 f0 02 00 00       	call   c010036d <cprintf>

    print_kerninfo();
c010007d:	e8 0e 08 00 00       	call   c0100890 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 a7 00 00 00       	call   c010012e <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 de 55 00 00       	call   c010566a <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 d5 1f 00 00       	call   c0102066 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 5c 21 00 00       	call   c01021f2 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 21 7d 00 00       	call   c0107dbc <vmm_init>
    proc_init();                // init process table
c010009b:	e8 dd 90 00 00       	call   c010917d <proc_init>
    
    ide_init();                 // init ide devices
c01000a0:	e8 1d 17 00 00       	call   c01017c2 <ide_init>
    swap_init();                // init swap
c01000a5:	e8 05 68 00 00       	call   c01068af <swap_init>

    clock_init();               // init clock interrupt
c01000aa:	e8 38 0d 00 00       	call   c0100de7 <clock_init>
    intr_enable();              // enable irq interrupt
c01000af:	e8 10 1f 00 00       	call   c0101fc4 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b4:	e8 85 92 00 00       	call   c010933e <cpu_idle>

c01000b9 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b9:	55                   	push   %ebp
c01000ba:	89 e5                	mov    %esp,%ebp
c01000bc:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c6:	00 
c01000c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ce:	00 
c01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d6:	e8 27 0c 00 00       	call   c0100d02 <mon_backtrace>
}
c01000db:	90                   	nop
c01000dc:	89 ec                	mov    %ebp,%esp
c01000de:	5d                   	pop    %ebp
c01000df:	c3                   	ret    

c01000e0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e0:	55                   	push   %ebp
c01000e1:	89 e5                	mov    %esp,%ebp
c01000e3:	83 ec 18             	sub    $0x18,%esp
c01000e6:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000ef:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100101:	89 04 24             	mov    %eax,(%esp)
c0100104:	e8 b0 ff ff ff       	call   c01000b9 <grade_backtrace2>
}
c0100109:	90                   	nop
c010010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010010d:	89 ec                	mov    %ebp,%esp
c010010f:	5d                   	pop    %ebp
c0100110:	c3                   	ret    

c0100111 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100117:	8b 45 10             	mov    0x10(%ebp),%eax
c010011a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100121:	89 04 24             	mov    %eax,(%esp)
c0100124:	e8 b7 ff ff ff       	call   c01000e0 <grade_backtrace1>
}
c0100129:	90                   	nop
c010012a:	89 ec                	mov    %ebp,%esp
c010012c:	5d                   	pop    %ebp
c010012d:	c3                   	ret    

c010012e <grade_backtrace>:

void
grade_backtrace(void) {
c010012e:	55                   	push   %ebp
c010012f:	89 e5                	mov    %esp,%ebp
c0100131:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100134:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100139:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100140:	ff 
c0100141:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010014c:	e8 c0 ff ff ff       	call   c0100111 <grade_backtrace0>
}
c0100151:	90                   	nop
c0100152:	89 ec                	mov    %ebp,%esp
c0100154:	5d                   	pop    %ebp
c0100155:	c3                   	ret    

c0100156 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100156:	55                   	push   %ebp
c0100157:	89 e5                	mov    %esp,%ebp
c0100159:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010015c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100162:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100165:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100168:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010016c:	83 e0 03             	and    $0x3,%eax
c010016f:	89 c2                	mov    %eax,%edx
c0100171:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100176:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017e:	c7 04 24 41 a1 10 c0 	movl   $0xc010a141,(%esp)
c0100185:	e8 e3 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010018a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018e:	89 c2                	mov    %eax,%edx
c0100190:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100195:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019d:	c7 04 24 4f a1 10 c0 	movl   $0xc010a14f,(%esp)
c01001a4:	e8 c4 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001ad:	89 c2                	mov    %eax,%edx
c01001af:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bc:	c7 04 24 5d a1 10 c0 	movl   $0xc010a15d,(%esp)
c01001c3:	e8 a5 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001cc:	89 c2                	mov    %eax,%edx
c01001ce:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001d3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001db:	c7 04 24 6b a1 10 c0 	movl   $0xc010a16b,(%esp)
c01001e2:	e8 86 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e7:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001eb:	89 c2                	mov    %eax,%edx
c01001ed:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fa:	c7 04 24 79 a1 10 c0 	movl   $0xc010a179,(%esp)
c0100201:	e8 67 01 00 00       	call   c010036d <cprintf>
    round ++;
c0100206:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c010020b:	40                   	inc    %eax
c010020c:	a3 00 b0 12 c0       	mov    %eax,0xc012b000
}
c0100211:	90                   	nop
c0100212:	89 ec                	mov    %ebp,%esp
c0100214:	5d                   	pop    %ebp
c0100215:	c3                   	ret    

c0100216 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100216:	55                   	push   %ebp
c0100217:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100219:	90                   	nop
c010021a:	5d                   	pop    %ebp
c010021b:	c3                   	ret    

c010021c <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010021c:	55                   	push   %ebp
c010021d:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010021f:	90                   	nop
c0100220:	5d                   	pop    %ebp
c0100221:	c3                   	ret    

c0100222 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100222:	55                   	push   %ebp
c0100223:	89 e5                	mov    %esp,%ebp
c0100225:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100228:	e8 29 ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010022d:	c7 04 24 88 a1 10 c0 	movl   $0xc010a188,(%esp)
c0100234:	e8 34 01 00 00       	call   c010036d <cprintf>
    lab1_switch_to_user();
c0100239:	e8 d8 ff ff ff       	call   c0100216 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023e:	e8 13 ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100243:	c7 04 24 a8 a1 10 c0 	movl   $0xc010a1a8,(%esp)
c010024a:	e8 1e 01 00 00       	call   c010036d <cprintf>
    lab1_switch_to_kernel();
c010024f:	e8 c8 ff ff ff       	call   c010021c <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100254:	e8 fd fe ff ff       	call   c0100156 <lab1_print_cur_status>
}
c0100259:	90                   	nop
c010025a:	89 ec                	mov    %ebp,%esp
c010025c:	5d                   	pop    %ebp
c010025d:	c3                   	ret    

c010025e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010025e:	55                   	push   %ebp
c010025f:	89 e5                	mov    %esp,%ebp
c0100261:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100264:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100268:	74 13                	je     c010027d <readline+0x1f>
        cprintf("%s", prompt);
c010026a:	8b 45 08             	mov    0x8(%ebp),%eax
c010026d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100271:	c7 04 24 c7 a1 10 c0 	movl   $0xc010a1c7,(%esp)
c0100278:	e8 f0 00 00 00       	call   c010036d <cprintf>
    }
    int i = 0, c;
c010027d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100284:	e8 73 01 00 00       	call   c01003fc <getchar>
c0100289:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010028c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100290:	79 07                	jns    c0100299 <readline+0x3b>
            return NULL;
c0100292:	b8 00 00 00 00       	mov    $0x0,%eax
c0100297:	eb 78                	jmp    c0100311 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100299:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010029d:	7e 28                	jle    c01002c7 <readline+0x69>
c010029f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002a6:	7f 1f                	jg     c01002c7 <readline+0x69>
            cputchar(c);
c01002a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ab:	89 04 24             	mov    %eax,(%esp)
c01002ae:	e8 e2 00 00 00       	call   c0100395 <cputchar>
            buf[i ++] = c;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002b6:	8d 50 01             	lea    0x1(%eax),%edx
c01002b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002bf:	88 90 20 b0 12 c0    	mov    %dl,-0x3fed4fe0(%eax)
c01002c5:	eb 45                	jmp    c010030c <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002c7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002cb:	75 16                	jne    c01002e3 <readline+0x85>
c01002cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002d1:	7e 10                	jle    c01002e3 <readline+0x85>
            cputchar(c);
c01002d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d6:	89 04 24             	mov    %eax,(%esp)
c01002d9:	e8 b7 00 00 00       	call   c0100395 <cputchar>
            i --;
c01002de:	ff 4d f4             	decl   -0xc(%ebp)
c01002e1:	eb 29                	jmp    c010030c <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002e3:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002e7:	74 06                	je     c01002ef <readline+0x91>
c01002e9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002ed:	75 95                	jne    c0100284 <readline+0x26>
            cputchar(c);
c01002ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002f2:	89 04 24             	mov    %eax,(%esp)
c01002f5:	e8 9b 00 00 00       	call   c0100395 <cputchar>
            buf[i] = '\0';
c01002fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002fd:	05 20 b0 12 c0       	add    $0xc012b020,%eax
c0100302:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100305:	b8 20 b0 12 c0       	mov    $0xc012b020,%eax
c010030a:	eb 05                	jmp    c0100311 <readline+0xb3>
        c = getchar();
c010030c:	e9 73 ff ff ff       	jmp    c0100284 <readline+0x26>
        }
    }
}
c0100311:	89 ec                	mov    %ebp,%esp
c0100313:	5d                   	pop    %ebp
c0100314:	c3                   	ret    

c0100315 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010031b:	8b 45 08             	mov    0x8(%ebp),%eax
c010031e:	89 04 24             	mov    %eax,(%esp)
c0100321:	e8 91 13 00 00       	call   c01016b7 <cons_putc>
    (*cnt) ++;
c0100326:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100329:	8b 00                	mov    (%eax),%eax
c010032b:	8d 50 01             	lea    0x1(%eax),%edx
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 10                	mov    %edx,(%eax)
}
c0100333:	90                   	nop
c0100334:	89 ec                	mov    %ebp,%esp
c0100336:	5d                   	pop    %ebp
c0100337:	c3                   	ret    

c0100338 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100338:	55                   	push   %ebp
c0100339:	89 e5                	mov    %esp,%ebp
c010033b:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010033e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100345:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100348:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010034c:	8b 45 08             	mov    0x8(%ebp),%eax
c010034f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100353:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100356:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035a:	c7 04 24 15 03 10 c0 	movl   $0xc0100315,(%esp)
c0100361:	e8 70 93 00 00       	call   c01096d6 <vprintfmt>
    return cnt;
c0100366:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100369:	89 ec                	mov    %ebp,%esp
c010036b:	5d                   	pop    %ebp
c010036c:	c3                   	ret    

c010036d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010036d:	55                   	push   %ebp
c010036e:	89 e5                	mov    %esp,%ebp
c0100370:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100373:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100376:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100379:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010037c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100380:	8b 45 08             	mov    0x8(%ebp),%eax
c0100383:	89 04 24             	mov    %eax,(%esp)
c0100386:	e8 ad ff ff ff       	call   c0100338 <vcprintf>
c010038b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010038e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100391:	89 ec                	mov    %ebp,%esp
c0100393:	5d                   	pop    %ebp
c0100394:	c3                   	ret    

c0100395 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100395:	55                   	push   %ebp
c0100396:	89 e5                	mov    %esp,%ebp
c0100398:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010039b:	8b 45 08             	mov    0x8(%ebp),%eax
c010039e:	89 04 24             	mov    %eax,(%esp)
c01003a1:	e8 11 13 00 00       	call   c01016b7 <cons_putc>
}
c01003a6:	90                   	nop
c01003a7:	89 ec                	mov    %ebp,%esp
c01003a9:	5d                   	pop    %ebp
c01003aa:	c3                   	ret    

c01003ab <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003ab:	55                   	push   %ebp
c01003ac:	89 e5                	mov    %esp,%ebp
c01003ae:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003b8:	eb 13                	jmp    c01003cd <cputs+0x22>
        cputch(c, &cnt);
c01003ba:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003be:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003c5:	89 04 24             	mov    %eax,(%esp)
c01003c8:	e8 48 ff ff ff       	call   c0100315 <cputch>
    while ((c = *str ++) != '\0') {
c01003cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01003d0:	8d 50 01             	lea    0x1(%eax),%edx
c01003d3:	89 55 08             	mov    %edx,0x8(%ebp)
c01003d6:	0f b6 00             	movzbl (%eax),%eax
c01003d9:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003dc:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003e0:	75 d8                	jne    c01003ba <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003e9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003f0:	e8 20 ff ff ff       	call   c0100315 <cputch>
    return cnt;
c01003f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003f8:	89 ec                	mov    %ebp,%esp
c01003fa:	5d                   	pop    %ebp
c01003fb:	c3                   	ret    

c01003fc <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003fc:	55                   	push   %ebp
c01003fd:	89 e5                	mov    %esp,%ebp
c01003ff:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100402:	90                   	nop
c0100403:	e8 ee 12 00 00       	call   c01016f6 <cons_getc>
c0100408:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010040b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010040f:	74 f2                	je     c0100403 <getchar+0x7>
        /* do nothing */;
    return c;
c0100411:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100414:	89 ec                	mov    %ebp,%esp
c0100416:	5d                   	pop    %ebp
c0100417:	c3                   	ret    

c0100418 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100418:	55                   	push   %ebp
c0100419:	89 e5                	mov    %esp,%ebp
c010041b:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010041e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100421:	8b 00                	mov    (%eax),%eax
c0100423:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100426:	8b 45 10             	mov    0x10(%ebp),%eax
c0100429:	8b 00                	mov    (%eax),%eax
c010042b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010042e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100435:	e9 ca 00 00 00       	jmp    c0100504 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c010043a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010043d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100440:	01 d0                	add    %edx,%eax
c0100442:	89 c2                	mov    %eax,%edx
c0100444:	c1 ea 1f             	shr    $0x1f,%edx
c0100447:	01 d0                	add    %edx,%eax
c0100449:	d1 f8                	sar    %eax
c010044b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010044e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100451:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100454:	eb 03                	jmp    c0100459 <stab_binsearch+0x41>
            m --;
c0100456:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100459:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010045c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010045f:	7c 1f                	jl     c0100480 <stab_binsearch+0x68>
c0100461:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100464:	89 d0                	mov    %edx,%eax
c0100466:	01 c0                	add    %eax,%eax
c0100468:	01 d0                	add    %edx,%eax
c010046a:	c1 e0 02             	shl    $0x2,%eax
c010046d:	89 c2                	mov    %eax,%edx
c010046f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100472:	01 d0                	add    %edx,%eax
c0100474:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100478:	0f b6 c0             	movzbl %al,%eax
c010047b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010047e:	75 d6                	jne    c0100456 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100480:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100483:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100486:	7d 09                	jge    c0100491 <stab_binsearch+0x79>
            l = true_m + 1;
c0100488:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010048b:	40                   	inc    %eax
c010048c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010048f:	eb 73                	jmp    c0100504 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100491:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100498:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049b:	89 d0                	mov    %edx,%eax
c010049d:	01 c0                	add    %eax,%eax
c010049f:	01 d0                	add    %edx,%eax
c01004a1:	c1 e0 02             	shl    $0x2,%eax
c01004a4:	89 c2                	mov    %eax,%edx
c01004a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01004a9:	01 d0                	add    %edx,%eax
c01004ab:	8b 40 08             	mov    0x8(%eax),%eax
c01004ae:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004b1:	76 11                	jbe    c01004c4 <stab_binsearch+0xac>
            *region_left = m;
c01004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b9:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004be:	40                   	inc    %eax
c01004bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c2:	eb 40                	jmp    c0100504 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004c7:	89 d0                	mov    %edx,%eax
c01004c9:	01 c0                	add    %eax,%eax
c01004cb:	01 d0                	add    %edx,%eax
c01004cd:	c1 e0 02             	shl    $0x2,%eax
c01004d0:	89 c2                	mov    %eax,%edx
c01004d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d5:	01 d0                	add    %edx,%eax
c01004d7:	8b 40 08             	mov    0x8(%eax),%eax
c01004da:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004dd:	73 14                	jae    c01004f3 <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e8:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ed:	48                   	dec    %eax
c01004ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004f1:	eb 11                	jmp    c0100504 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f9:	89 10                	mov    %edx,(%eax)
            l = m;
c01004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100501:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100504:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100507:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010050a:	0f 8e 2a ff ff ff    	jle    c010043a <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100514:	75 0f                	jne    c0100525 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c0100516:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100519:	8b 00                	mov    (%eax),%eax
c010051b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010051e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100521:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100523:	eb 3e                	jmp    c0100563 <stab_binsearch+0x14b>
        l = *region_right;
c0100525:	8b 45 10             	mov    0x10(%ebp),%eax
c0100528:	8b 00                	mov    (%eax),%eax
c010052a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010052d:	eb 03                	jmp    c0100532 <stab_binsearch+0x11a>
c010052f:	ff 4d fc             	decl   -0x4(%ebp)
c0100532:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100535:	8b 00                	mov    (%eax),%eax
c0100537:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010053a:	7e 1f                	jle    c010055b <stab_binsearch+0x143>
c010053c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053f:	89 d0                	mov    %edx,%eax
c0100541:	01 c0                	add    %eax,%eax
c0100543:	01 d0                	add    %edx,%eax
c0100545:	c1 e0 02             	shl    $0x2,%eax
c0100548:	89 c2                	mov    %eax,%edx
c010054a:	8b 45 08             	mov    0x8(%ebp),%eax
c010054d:	01 d0                	add    %edx,%eax
c010054f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100553:	0f b6 c0             	movzbl %al,%eax
c0100556:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100559:	75 d4                	jne    c010052f <stab_binsearch+0x117>
        *region_left = l;
c010055b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100561:	89 10                	mov    %edx,(%eax)
}
c0100563:	90                   	nop
c0100564:	89 ec                	mov    %ebp,%esp
c0100566:	5d                   	pop    %ebp
c0100567:	c3                   	ret    

c0100568 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100568:	55                   	push   %ebp
c0100569:	89 e5                	mov    %esp,%ebp
c010056b:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010056e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100571:	c7 00 cc a1 10 c0    	movl   $0xc010a1cc,(%eax)
    info->eip_line = 0;
c0100577:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100581:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100584:	c7 40 08 cc a1 10 c0 	movl   $0xc010a1cc,0x8(%eax)
    info->eip_fn_namelen = 9;
c010058b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058e:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100595:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100598:	8b 55 08             	mov    0x8(%ebp),%edx
c010059b:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010059e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01005a8:	c7 45 f4 90 c4 10 c0 	movl   $0xc010c490,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005af:	c7 45 f0 3c f3 11 c0 	movl   $0xc011f33c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005b6:	c7 45 ec 3d f3 11 c0 	movl   $0xc011f33d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005bd:	c7 45 e8 1b 58 12 c0 	movl   $0xc012581b,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005ca:	76 0b                	jbe    c01005d7 <debuginfo_eip+0x6f>
c01005cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005cf:	48                   	dec    %eax
c01005d0:	0f b6 00             	movzbl (%eax),%eax
c01005d3:	84 c0                	test   %al,%al
c01005d5:	74 0a                	je     c01005e1 <debuginfo_eip+0x79>
        return -1;
c01005d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005dc:	e9 ab 02 00 00       	jmp    c010088c <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005eb:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005ee:	c1 f8 02             	sar    $0x2,%eax
c01005f1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005f7:	48                   	dec    %eax
c01005f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fe:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100602:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100609:	00 
c010060a:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010060d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100611:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100614:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100618:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010061b:	89 04 24             	mov    %eax,(%esp)
c010061e:	e8 f5 fd ff ff       	call   c0100418 <stab_binsearch>
    if (lfile == 0)
c0100623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100626:	85 c0                	test   %eax,%eax
c0100628:	75 0a                	jne    c0100634 <debuginfo_eip+0xcc>
        return -1;
c010062a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010062f:	e9 58 02 00 00       	jmp    c010088c <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100637:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010063a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100640:	8b 45 08             	mov    0x8(%ebp),%eax
c0100643:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100647:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010064e:	00 
c010064f:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100652:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100656:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100659:	89 44 24 04          	mov    %eax,0x4(%esp)
c010065d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100660:	89 04 24             	mov    %eax,(%esp)
c0100663:	e8 b0 fd ff ff       	call   c0100418 <stab_binsearch>

    if (lfun <= rfun) {
c0100668:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010066b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010066e:	39 c2                	cmp    %eax,%edx
c0100670:	7f 78                	jg     c01006ea <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100672:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100675:	89 c2                	mov    %eax,%edx
c0100677:	89 d0                	mov    %edx,%eax
c0100679:	01 c0                	add    %eax,%eax
c010067b:	01 d0                	add    %edx,%eax
c010067d:	c1 e0 02             	shl    $0x2,%eax
c0100680:	89 c2                	mov    %eax,%edx
c0100682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100685:	01 d0                	add    %edx,%eax
c0100687:	8b 10                	mov    (%eax),%edx
c0100689:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010068c:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010068f:	39 c2                	cmp    %eax,%edx
c0100691:	73 22                	jae    c01006b5 <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100693:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100696:	89 c2                	mov    %eax,%edx
c0100698:	89 d0                	mov    %edx,%eax
c010069a:	01 c0                	add    %eax,%eax
c010069c:	01 d0                	add    %edx,%eax
c010069e:	c1 e0 02             	shl    $0x2,%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a6:	01 d0                	add    %edx,%eax
c01006a8:	8b 10                	mov    (%eax),%edx
c01006aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006ad:	01 c2                	add    %eax,%edx
c01006af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b2:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006b8:	89 c2                	mov    %eax,%edx
c01006ba:	89 d0                	mov    %edx,%eax
c01006bc:	01 c0                	add    %eax,%eax
c01006be:	01 d0                	add    %edx,%eax
c01006c0:	c1 e0 02             	shl    $0x2,%eax
c01006c3:	89 c2                	mov    %eax,%edx
c01006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c8:	01 d0                	add    %edx,%eax
c01006ca:	8b 50 08             	mov    0x8(%eax),%edx
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d6:	8b 40 10             	mov    0x10(%eax),%eax
c01006d9:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006e8:	eb 15                	jmp    c01006ff <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ed:	8b 55 08             	mov    0x8(%ebp),%edx
c01006f0:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100702:	8b 40 08             	mov    0x8(%eax),%eax
c0100705:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010070c:	00 
c010070d:	89 04 24             	mov    %eax,(%esp)
c0100710:	e8 e6 96 00 00       	call   c0109dfb <strfind>
c0100715:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100718:	8b 4a 08             	mov    0x8(%edx),%ecx
c010071b:	29 c8                	sub    %ecx,%eax
c010071d:	89 c2                	mov    %eax,%edx
c010071f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100722:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100725:	8b 45 08             	mov    0x8(%ebp),%eax
c0100728:	89 44 24 10          	mov    %eax,0x10(%esp)
c010072c:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100733:	00 
c0100734:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100737:	89 44 24 08          	mov    %eax,0x8(%esp)
c010073b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010073e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100745:	89 04 24             	mov    %eax,(%esp)
c0100748:	e8 cb fc ff ff       	call   c0100418 <stab_binsearch>
    if (lline <= rline) {
c010074d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100750:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100753:	39 c2                	cmp    %eax,%edx
c0100755:	7f 23                	jg     c010077a <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100757:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010075a:	89 c2                	mov    %eax,%edx
c010075c:	89 d0                	mov    %edx,%eax
c010075e:	01 c0                	add    %eax,%eax
c0100760:	01 d0                	add    %edx,%eax
c0100762:	c1 e0 02             	shl    $0x2,%eax
c0100765:	89 c2                	mov    %eax,%edx
c0100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076a:	01 d0                	add    %edx,%eax
c010076c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100770:	89 c2                	mov    %eax,%edx
c0100772:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100775:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100778:	eb 11                	jmp    c010078b <debuginfo_eip+0x223>
        return -1;
c010077a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010077f:	e9 08 01 00 00       	jmp    c010088c <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100784:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100787:	48                   	dec    %eax
c0100788:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c010078b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010078e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100791:	39 c2                	cmp    %eax,%edx
c0100793:	7c 56                	jl     c01007eb <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c0100795:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100798:	89 c2                	mov    %eax,%edx
c010079a:	89 d0                	mov    %edx,%eax
c010079c:	01 c0                	add    %eax,%eax
c010079e:	01 d0                	add    %edx,%eax
c01007a0:	c1 e0 02             	shl    $0x2,%eax
c01007a3:	89 c2                	mov    %eax,%edx
c01007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a8:	01 d0                	add    %edx,%eax
c01007aa:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007ae:	3c 84                	cmp    $0x84,%al
c01007b0:	74 39                	je     c01007eb <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b5:	89 c2                	mov    %eax,%edx
c01007b7:	89 d0                	mov    %edx,%eax
c01007b9:	01 c0                	add    %eax,%eax
c01007bb:	01 d0                	add    %edx,%eax
c01007bd:	c1 e0 02             	shl    $0x2,%eax
c01007c0:	89 c2                	mov    %eax,%edx
c01007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c5:	01 d0                	add    %edx,%eax
c01007c7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007cb:	3c 64                	cmp    $0x64,%al
c01007cd:	75 b5                	jne    c0100784 <debuginfo_eip+0x21c>
c01007cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	89 d0                	mov    %edx,%eax
c01007d6:	01 c0                	add    %eax,%eax
c01007d8:	01 d0                	add    %edx,%eax
c01007da:	c1 e0 02             	shl    $0x2,%eax
c01007dd:	89 c2                	mov    %eax,%edx
c01007df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007e2:	01 d0                	add    %edx,%eax
c01007e4:	8b 40 08             	mov    0x8(%eax),%eax
c01007e7:	85 c0                	test   %eax,%eax
c01007e9:	74 99                	je     c0100784 <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007f1:	39 c2                	cmp    %eax,%edx
c01007f3:	7c 42                	jl     c0100837 <debuginfo_eip+0x2cf>
c01007f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007f8:	89 c2                	mov    %eax,%edx
c01007fa:	89 d0                	mov    %edx,%eax
c01007fc:	01 c0                	add    %eax,%eax
c01007fe:	01 d0                	add    %edx,%eax
c0100800:	c1 e0 02             	shl    $0x2,%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	8b 10                	mov    (%eax),%edx
c010080c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010080f:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100812:	39 c2                	cmp    %eax,%edx
c0100814:	73 21                	jae    c0100837 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100816:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100819:	89 c2                	mov    %eax,%edx
c010081b:	89 d0                	mov    %edx,%eax
c010081d:	01 c0                	add    %eax,%eax
c010081f:	01 d0                	add    %edx,%eax
c0100821:	c1 e0 02             	shl    $0x2,%eax
c0100824:	89 c2                	mov    %eax,%edx
c0100826:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100829:	01 d0                	add    %edx,%eax
c010082b:	8b 10                	mov    (%eax),%edx
c010082d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100830:	01 c2                	add    %eax,%edx
c0100832:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100835:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100837:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010083a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010083d:	39 c2                	cmp    %eax,%edx
c010083f:	7d 46                	jge    c0100887 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c0100841:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100844:	40                   	inc    %eax
c0100845:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100848:	eb 16                	jmp    c0100860 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010084a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010084d:	8b 40 14             	mov    0x14(%eax),%eax
c0100850:	8d 50 01             	lea    0x1(%eax),%edx
c0100853:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100856:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100859:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085c:	40                   	inc    %eax
c010085d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100860:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100863:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100866:	39 c2                	cmp    %eax,%edx
c0100868:	7d 1d                	jge    c0100887 <debuginfo_eip+0x31f>
c010086a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086d:	89 c2                	mov    %eax,%edx
c010086f:	89 d0                	mov    %edx,%eax
c0100871:	01 c0                	add    %eax,%eax
c0100873:	01 d0                	add    %edx,%eax
c0100875:	c1 e0 02             	shl    $0x2,%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087d:	01 d0                	add    %edx,%eax
c010087f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100883:	3c a0                	cmp    $0xa0,%al
c0100885:	74 c3                	je     c010084a <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100887:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010088c:	89 ec                	mov    %ebp,%esp
c010088e:	5d                   	pop    %ebp
c010088f:	c3                   	ret    

c0100890 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100890:	55                   	push   %ebp
c0100891:	89 e5                	mov    %esp,%ebp
c0100893:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100896:	c7 04 24 d6 a1 10 c0 	movl   $0xc010a1d6,(%esp)
c010089d:	e8 cb fa ff ff       	call   c010036d <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01008a2:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 ef a1 10 c0 	movl   $0xc010a1ef,(%esp)
c01008b1:	e8 b7 fa ff ff       	call   c010036d <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008b6:	c7 44 24 04 0f a1 10 	movl   $0xc010a10f,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 07 a2 10 c0 	movl   $0xc010a207,(%esp)
c01008c5:	e8 a3 fa ff ff       	call   c010036d <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008ca:	c7 44 24 04 00 b0 12 	movl   $0xc012b000,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 1f a2 10 c0 	movl   $0xc010a21f,(%esp)
c01008d9:	e8 8f fa ff ff       	call   c010036d <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008de:	c7 44 24 04 54 e1 12 	movl   $0xc012e154,0x4(%esp)
c01008e5:	c0 
c01008e6:	c7 04 24 37 a2 10 c0 	movl   $0xc010a237,(%esp)
c01008ed:	e8 7b fa ff ff       	call   c010036d <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008f2:	b8 54 e1 12 c0       	mov    $0xc012e154,%eax
c01008f7:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008fc:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100901:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100907:	85 c0                	test   %eax,%eax
c0100909:	0f 48 c2             	cmovs  %edx,%eax
c010090c:	c1 f8 0a             	sar    $0xa,%eax
c010090f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100913:	c7 04 24 50 a2 10 c0 	movl   $0xc010a250,(%esp)
c010091a:	e8 4e fa ff ff       	call   c010036d <cprintf>
}
c010091f:	90                   	nop
c0100920:	89 ec                	mov    %ebp,%esp
c0100922:	5d                   	pop    %ebp
c0100923:	c3                   	ret    

c0100924 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100924:	55                   	push   %ebp
c0100925:	89 e5                	mov    %esp,%ebp
c0100927:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010092d:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100930:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100934:	8b 45 08             	mov    0x8(%ebp),%eax
c0100937:	89 04 24             	mov    %eax,(%esp)
c010093a:	e8 29 fc ff ff       	call   c0100568 <debuginfo_eip>
c010093f:	85 c0                	test   %eax,%eax
c0100941:	74 15                	je     c0100958 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100943:	8b 45 08             	mov    0x8(%ebp),%eax
c0100946:	89 44 24 04          	mov    %eax,0x4(%esp)
c010094a:	c7 04 24 7a a2 10 c0 	movl   $0xc010a27a,(%esp)
c0100951:	e8 17 fa ff ff       	call   c010036d <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100956:	eb 6c                	jmp    c01009c4 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100958:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010095f:	eb 1b                	jmp    c010097c <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100961:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100964:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100967:	01 d0                	add    %edx,%eax
c0100969:	0f b6 10             	movzbl (%eax),%edx
c010096c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100972:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100975:	01 c8                	add    %ecx,%eax
c0100977:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100979:	ff 45 f4             	incl   -0xc(%ebp)
c010097c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010097f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100982:	7c dd                	jl     c0100961 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100984:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c010098a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098d:	01 d0                	add    %edx,%eax
c010098f:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100992:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100995:	8b 45 08             	mov    0x8(%ebp),%eax
c0100998:	29 d0                	sub    %edx,%eax
c010099a:	89 c1                	mov    %eax,%ecx
c010099c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010099f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a6:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009ac:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b8:	c7 04 24 96 a2 10 c0 	movl   $0xc010a296,(%esp)
c01009bf:	e8 a9 f9 ff ff       	call   c010036d <cprintf>
}
c01009c4:	90                   	nop
c01009c5:	89 ec                	mov    %ebp,%esp
c01009c7:	5d                   	pop    %ebp
c01009c8:	c3                   	ret    

c01009c9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c9:	55                   	push   %ebp
c01009ca:	89 e5                	mov    %esp,%ebp
c01009cc:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009cf:	8b 45 04             	mov    0x4(%ebp),%eax
c01009d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d8:	89 ec                	mov    %ebp,%esp
c01009da:	5d                   	pop    %ebp
c01009db:	c3                   	ret    

c01009dc <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009dc:	55                   	push   %ebp
c01009dd:	89 e5                	mov    %esp,%ebp
c01009df:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009e2:	89 e8                	mov    %ebp,%eax
c01009e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
c01009ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
c01009ed:	e8 d7 ff ff ff       	call   c01009c9 <read_eip>
c01009f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i,j;
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
c01009f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009fc:	e9 a8 00 00 00       	jmp    c0100aa9 <print_stackframe+0xcd>
      {
        cprintf("%08x",ebp);
c0100a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a08:	c7 04 24 a8 a2 10 c0 	movl   $0xc010a2a8,(%esp)
c0100a0f:	e8 59 f9 ff ff       	call   c010036d <cprintf>
        cprintf(" ");
c0100a14:	c7 04 24 ad a2 10 c0 	movl   $0xc010a2ad,(%esp)
c0100a1b:	e8 4d f9 ff ff       	call   c010036d <cprintf>
        cprintf("%08x",eip);
c0100a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a27:	c7 04 24 a8 a2 10 c0 	movl   $0xc010a2a8,(%esp)
c0100a2e:	e8 3a f9 ff ff       	call   c010036d <cprintf>
        uint32_t* a=(uint32_t*)ebp+2;
c0100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a36:	83 c0 08             	add    $0x8,%eax
c0100a39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j=0;j<4;j++)
c0100a3c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a43:	eb 30                	jmp    c0100a75 <print_stackframe+0x99>
        {
            cprintf(" ");
c0100a45:	c7 04 24 ad a2 10 c0 	movl   $0xc010a2ad,(%esp)
c0100a4c:	e8 1c f9 ff ff       	call   c010036d <cprintf>
            cprintf("%08x",a[j]);
c0100a51:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a5e:	01 d0                	add    %edx,%eax
c0100a60:	8b 00                	mov    (%eax),%eax
c0100a62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a66:	c7 04 24 a8 a2 10 c0 	movl   $0xc010a2a8,(%esp)
c0100a6d:	e8 fb f8 ff ff       	call   c010036d <cprintf>
        for(j=0;j<4;j++)
c0100a72:	ff 45 e8             	incl   -0x18(%ebp)
c0100a75:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a79:	7e ca                	jle    c0100a45 <print_stackframe+0x69>
        }
        cprintf("\n");
c0100a7b:	c7 04 24 af a2 10 c0 	movl   $0xc010a2af,(%esp)
c0100a82:	e8 e6 f8 ff ff       	call   c010036d <cprintf>

        print_debuginfo(eip-1);
c0100a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a8a:	48                   	dec    %eax
c0100a8b:	89 04 24             	mov    %eax,(%esp)
c0100a8e:	e8 91 fe ff ff       	call   c0100924 <print_debuginfo>

        eip=((uint32_t*)ebp)[1];
c0100a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a96:	83 c0 04             	add    $0x4,%eax
c0100a99:	8b 00                	mov    (%eax),%eax
c0100a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp=((uint32_t*)ebp)[0];
c0100a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa1:	8b 00                	mov    (%eax),%eax
c0100aa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
c0100aa6:	ff 45 ec             	incl   -0x14(%ebp)
c0100aa9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100aad:	74 0a                	je     c0100ab9 <print_stackframe+0xdd>
c0100aaf:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100ab3:	0f 8e 48 ff ff ff    	jle    c0100a01 <print_stackframe+0x25>


      }
}
c0100ab9:	90                   	nop
c0100aba:	89 ec                	mov    %ebp,%esp
c0100abc:	5d                   	pop    %ebp
c0100abd:	c3                   	ret    

c0100abe <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100abe:	55                   	push   %ebp
c0100abf:	89 e5                	mov    %esp,%ebp
c0100ac1:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100acb:	eb 0c                	jmp    c0100ad9 <parse+0x1b>
            *buf ++ = '\0';
c0100acd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad0:	8d 50 01             	lea    0x1(%eax),%edx
c0100ad3:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ad6:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ad9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100adc:	0f b6 00             	movzbl (%eax),%eax
c0100adf:	84 c0                	test   %al,%al
c0100ae1:	74 1d                	je     c0100b00 <parse+0x42>
c0100ae3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae6:	0f b6 00             	movzbl (%eax),%eax
c0100ae9:	0f be c0             	movsbl %al,%eax
c0100aec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100af0:	c7 04 24 34 a3 10 c0 	movl   $0xc010a334,(%esp)
c0100af7:	e8 cb 92 00 00       	call   c0109dc7 <strchr>
c0100afc:	85 c0                	test   %eax,%eax
c0100afe:	75 cd                	jne    c0100acd <parse+0xf>
        }
        if (*buf == '\0') {
c0100b00:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b03:	0f b6 00             	movzbl (%eax),%eax
c0100b06:	84 c0                	test   %al,%al
c0100b08:	74 65                	je     c0100b6f <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b0a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b0e:	75 14                	jne    c0100b24 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b10:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b17:	00 
c0100b18:	c7 04 24 39 a3 10 c0 	movl   $0xc010a339,(%esp)
c0100b1f:	e8 49 f8 ff ff       	call   c010036d <cprintf>
        }
        argv[argc ++] = buf;
c0100b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b27:	8d 50 01             	lea    0x1(%eax),%edx
c0100b2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b37:	01 c2                	add    %eax,%edx
c0100b39:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b3c:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b3e:	eb 03                	jmp    c0100b43 <parse+0x85>
            buf ++;
c0100b40:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b43:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b46:	0f b6 00             	movzbl (%eax),%eax
c0100b49:	84 c0                	test   %al,%al
c0100b4b:	74 8c                	je     c0100ad9 <parse+0x1b>
c0100b4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b50:	0f b6 00             	movzbl (%eax),%eax
c0100b53:	0f be c0             	movsbl %al,%eax
c0100b56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b5a:	c7 04 24 34 a3 10 c0 	movl   $0xc010a334,(%esp)
c0100b61:	e8 61 92 00 00       	call   c0109dc7 <strchr>
c0100b66:	85 c0                	test   %eax,%eax
c0100b68:	74 d6                	je     c0100b40 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b6a:	e9 6a ff ff ff       	jmp    c0100ad9 <parse+0x1b>
            break;
c0100b6f:	90                   	nop
        }
    }
    return argc;
c0100b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b73:	89 ec                	mov    %ebp,%esp
c0100b75:	5d                   	pop    %ebp
c0100b76:	c3                   	ret    

c0100b77 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b77:	55                   	push   %ebp
c0100b78:	89 e5                	mov    %esp,%ebp
c0100b7a:	83 ec 68             	sub    $0x68,%esp
c0100b7d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b80:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b87:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b8a:	89 04 24             	mov    %eax,(%esp)
c0100b8d:	e8 2c ff ff ff       	call   c0100abe <parse>
c0100b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b99:	75 0a                	jne    c0100ba5 <runcmd+0x2e>
        return 0;
c0100b9b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100ba0:	e9 83 00 00 00       	jmp    c0100c28 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ba5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100bac:	eb 5a                	jmp    c0100c08 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100bae:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100bb1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100bb4:	89 c8                	mov    %ecx,%eax
c0100bb6:	01 c0                	add    %eax,%eax
c0100bb8:	01 c8                	add    %ecx,%eax
c0100bba:	c1 e0 02             	shl    $0x2,%eax
c0100bbd:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0100bc2:	8b 00                	mov    (%eax),%eax
c0100bc4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc8:	89 04 24             	mov    %eax,(%esp)
c0100bcb:	e8 5b 91 00 00       	call   c0109d2b <strcmp>
c0100bd0:	85 c0                	test   %eax,%eax
c0100bd2:	75 31                	jne    c0100c05 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bd7:	89 d0                	mov    %edx,%eax
c0100bd9:	01 c0                	add    %eax,%eax
c0100bdb:	01 d0                	add    %edx,%eax
c0100bdd:	c1 e0 02             	shl    $0x2,%eax
c0100be0:	05 08 80 12 c0       	add    $0xc0128008,%eax
c0100be5:	8b 10                	mov    (%eax),%edx
c0100be7:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bea:	83 c0 04             	add    $0x4,%eax
c0100bed:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bf0:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bf6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bfe:	89 1c 24             	mov    %ebx,(%esp)
c0100c01:	ff d2                	call   *%edx
c0100c03:	eb 23                	jmp    c0100c28 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c05:	ff 45 f4             	incl   -0xc(%ebp)
c0100c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c0b:	83 f8 02             	cmp    $0x2,%eax
c0100c0e:	76 9e                	jbe    c0100bae <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c10:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c17:	c7 04 24 57 a3 10 c0 	movl   $0xc010a357,(%esp)
c0100c1e:	e8 4a f7 ff ff       	call   c010036d <cprintf>
    return 0;
c0100c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c2b:	89 ec                	mov    %ebp,%esp
c0100c2d:	5d                   	pop    %ebp
c0100c2e:	c3                   	ret    

c0100c2f <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c2f:	55                   	push   %ebp
c0100c30:	89 e5                	mov    %esp,%ebp
c0100c32:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c35:	c7 04 24 70 a3 10 c0 	movl   $0xc010a370,(%esp)
c0100c3c:	e8 2c f7 ff ff       	call   c010036d <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c41:	c7 04 24 98 a3 10 c0 	movl   $0xc010a398,(%esp)
c0100c48:	e8 20 f7 ff ff       	call   c010036d <cprintf>

    if (tf != NULL) {
c0100c4d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c51:	74 0b                	je     c0100c5e <kmonitor+0x2f>
        print_trapframe(tf);
c0100c53:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c56:	89 04 24             	mov    %eax,(%esp)
c0100c59:	e8 4e 17 00 00       	call   c01023ac <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c5e:	c7 04 24 bd a3 10 c0 	movl   $0xc010a3bd,(%esp)
c0100c65:	e8 f4 f5 ff ff       	call   c010025e <readline>
c0100c6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c71:	74 eb                	je     c0100c5e <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c7d:	89 04 24             	mov    %eax,(%esp)
c0100c80:	e8 f2 fe ff ff       	call   c0100b77 <runcmd>
c0100c85:	85 c0                	test   %eax,%eax
c0100c87:	78 02                	js     c0100c8b <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c89:	eb d3                	jmp    c0100c5e <kmonitor+0x2f>
                break;
c0100c8b:	90                   	nop
            }
        }
    }
}
c0100c8c:	90                   	nop
c0100c8d:	89 ec                	mov    %ebp,%esp
c0100c8f:	5d                   	pop    %ebp
c0100c90:	c3                   	ret    

c0100c91 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c91:	55                   	push   %ebp
c0100c92:	89 e5                	mov    %esp,%ebp
c0100c94:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c9e:	eb 3d                	jmp    c0100cdd <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ca3:	89 d0                	mov    %edx,%eax
c0100ca5:	01 c0                	add    %eax,%eax
c0100ca7:	01 d0                	add    %edx,%eax
c0100ca9:	c1 e0 02             	shl    $0x2,%eax
c0100cac:	05 04 80 12 c0       	add    $0xc0128004,%eax
c0100cb1:	8b 10                	mov    (%eax),%edx
c0100cb3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100cb6:	89 c8                	mov    %ecx,%eax
c0100cb8:	01 c0                	add    %eax,%eax
c0100cba:	01 c8                	add    %ecx,%eax
c0100cbc:	c1 e0 02             	shl    $0x2,%eax
c0100cbf:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0100cc4:	8b 00                	mov    (%eax),%eax
c0100cc6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cca:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cce:	c7 04 24 c1 a3 10 c0 	movl   $0xc010a3c1,(%esp)
c0100cd5:	e8 93 f6 ff ff       	call   c010036d <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cda:	ff 45 f4             	incl   -0xc(%ebp)
c0100cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ce0:	83 f8 02             	cmp    $0x2,%eax
c0100ce3:	76 bb                	jbe    c0100ca0 <mon_help+0xf>
    }
    return 0;
c0100ce5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cea:	89 ec                	mov    %ebp,%esp
c0100cec:	5d                   	pop    %ebp
c0100ced:	c3                   	ret    

c0100cee <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cee:	55                   	push   %ebp
c0100cef:	89 e5                	mov    %esp,%ebp
c0100cf1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cf4:	e8 97 fb ff ff       	call   c0100890 <print_kerninfo>
    return 0;
c0100cf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cfe:	89 ec                	mov    %ebp,%esp
c0100d00:	5d                   	pop    %ebp
c0100d01:	c3                   	ret    

c0100d02 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d02:	55                   	push   %ebp
c0100d03:	89 e5                	mov    %esp,%ebp
c0100d05:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d08:	e8 cf fc ff ff       	call   c01009dc <print_stackframe>
    return 0;
c0100d0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d12:	89 ec                	mov    %ebp,%esp
c0100d14:	5d                   	pop    %ebp
c0100d15:	c3                   	ret    

c0100d16 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100d16:	55                   	push   %ebp
c0100d17:	89 e5                	mov    %esp,%ebp
c0100d19:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100d1c:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
c0100d21:	85 c0                	test   %eax,%eax
c0100d23:	75 5b                	jne    c0100d80 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100d25:	c7 05 20 b4 12 c0 01 	movl   $0x1,0xc012b420
c0100d2c:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d2f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d38:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d43:	c7 04 24 ca a3 10 c0 	movl   $0xc010a3ca,(%esp)
c0100d4a:	e8 1e f6 ff ff       	call   c010036d <cprintf>
    vcprintf(fmt, ap);
c0100d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d56:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d59:	89 04 24             	mov    %eax,(%esp)
c0100d5c:	e8 d7 f5 ff ff       	call   c0100338 <vcprintf>
    cprintf("\n");
c0100d61:	c7 04 24 e6 a3 10 c0 	movl   $0xc010a3e6,(%esp)
c0100d68:	e8 00 f6 ff ff       	call   c010036d <cprintf>
    
    cprintf("stack trackback:\n");
c0100d6d:	c7 04 24 e8 a3 10 c0 	movl   $0xc010a3e8,(%esp)
c0100d74:	e8 f4 f5 ff ff       	call   c010036d <cprintf>
    print_stackframe();
c0100d79:	e8 5e fc ff ff       	call   c01009dc <print_stackframe>
c0100d7e:	eb 01                	jmp    c0100d81 <__panic+0x6b>
        goto panic_dead;
c0100d80:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d81:	e8 46 12 00 00       	call   c0101fcc <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d8d:	e8 9d fe ff ff       	call   c0100c2f <kmonitor>
c0100d92:	eb f2                	jmp    c0100d86 <__panic+0x70>

c0100d94 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d94:	55                   	push   %ebp
c0100d95:	89 e5                	mov    %esp,%ebp
c0100d97:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d9a:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100da0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100da3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100da7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100daa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dae:	c7 04 24 fa a3 10 c0 	movl   $0xc010a3fa,(%esp)
c0100db5:	e8 b3 f5 ff ff       	call   c010036d <cprintf>
    vcprintf(fmt, ap);
c0100dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dc1:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dc4:	89 04 24             	mov    %eax,(%esp)
c0100dc7:	e8 6c f5 ff ff       	call   c0100338 <vcprintf>
    cprintf("\n");
c0100dcc:	c7 04 24 e6 a3 10 c0 	movl   $0xc010a3e6,(%esp)
c0100dd3:	e8 95 f5 ff ff       	call   c010036d <cprintf>
    va_end(ap);
}
c0100dd8:	90                   	nop
c0100dd9:	89 ec                	mov    %ebp,%esp
c0100ddb:	5d                   	pop    %ebp
c0100ddc:	c3                   	ret    

c0100ddd <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100ddd:	55                   	push   %ebp
c0100dde:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100de0:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
}
c0100de5:	5d                   	pop    %ebp
c0100de6:	c3                   	ret    

c0100de7 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100de7:	55                   	push   %ebp
c0100de8:	89 e5                	mov    %esp,%ebp
c0100dea:	83 ec 28             	sub    $0x28,%esp
c0100ded:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100df3:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100df7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dfb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dff:	ee                   	out    %al,(%dx)
}
c0100e00:	90                   	nop
c0100e01:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e07:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e0b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e0f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e13:	ee                   	out    %al,(%dx)
}
c0100e14:	90                   	nop
c0100e15:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e1b:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e1f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e23:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e27:	ee                   	out    %al,(%dx)
}
c0100e28:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e29:	c7 05 24 b4 12 c0 00 	movl   $0x0,0xc012b424
c0100e30:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e33:	c7 04 24 18 a4 10 c0 	movl   $0xc010a418,(%esp)
c0100e3a:	e8 2e f5 ff ff       	call   c010036d <cprintf>
    pic_enable(IRQ_TIMER);
c0100e3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e46:	e8 e6 11 00 00       	call   c0102031 <pic_enable>
}
c0100e4b:	90                   	nop
c0100e4c:	89 ec                	mov    %ebp,%esp
c0100e4e:	5d                   	pop    %ebp
c0100e4f:	c3                   	ret    

c0100e50 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e50:	55                   	push   %ebp
c0100e51:	89 e5                	mov    %esp,%ebp
c0100e53:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e56:	9c                   	pushf  
c0100e57:	58                   	pop    %eax
c0100e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e5e:	25 00 02 00 00       	and    $0x200,%eax
c0100e63:	85 c0                	test   %eax,%eax
c0100e65:	74 0c                	je     c0100e73 <__intr_save+0x23>
        intr_disable();
c0100e67:	e8 60 11 00 00       	call   c0101fcc <intr_disable>
        return 1;
c0100e6c:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e71:	eb 05                	jmp    c0100e78 <__intr_save+0x28>
    }
    return 0;
c0100e73:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e78:	89 ec                	mov    %ebp,%esp
c0100e7a:	5d                   	pop    %ebp
c0100e7b:	c3                   	ret    

c0100e7c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e7c:	55                   	push   %ebp
c0100e7d:	89 e5                	mov    %esp,%ebp
c0100e7f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e82:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e86:	74 05                	je     c0100e8d <__intr_restore+0x11>
        intr_enable();
c0100e88:	e8 37 11 00 00       	call   c0101fc4 <intr_enable>
    }
}
c0100e8d:	90                   	nop
c0100e8e:	89 ec                	mov    %ebp,%esp
c0100e90:	5d                   	pop    %ebp
c0100e91:	c3                   	ret    

c0100e92 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e92:	55                   	push   %ebp
c0100e93:	89 e5                	mov    %esp,%ebp
c0100e95:	83 ec 10             	sub    $0x10,%esp
c0100e98:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e9e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ea2:	89 c2                	mov    %eax,%edx
c0100ea4:	ec                   	in     (%dx),%al
c0100ea5:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100ea8:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100eae:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100eb2:	89 c2                	mov    %eax,%edx
c0100eb4:	ec                   	in     (%dx),%al
c0100eb5:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100eb8:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100ebe:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ec2:	89 c2                	mov    %eax,%edx
c0100ec4:	ec                   	in     (%dx),%al
c0100ec5:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100ec8:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ece:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ed2:	89 c2                	mov    %eax,%edx
c0100ed4:	ec                   	in     (%dx),%al
c0100ed5:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ed8:	90                   	nop
c0100ed9:	89 ec                	mov    %ebp,%esp
c0100edb:	5d                   	pop    %ebp
c0100edc:	c3                   	ret    

c0100edd <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100edd:	55                   	push   %ebp
c0100ede:	89 e5                	mov    %esp,%ebp
c0100ee0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ee3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100eea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eed:	0f b7 00             	movzwl (%eax),%eax
c0100ef0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ef4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ef7:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eff:	0f b7 00             	movzwl (%eax),%eax
c0100f02:	0f b7 c0             	movzwl %ax,%eax
c0100f05:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f0a:	74 12                	je     c0100f1e <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f0c:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f13:	66 c7 05 46 b4 12 c0 	movw   $0x3b4,0xc012b446
c0100f1a:	b4 03 
c0100f1c:	eb 13                	jmp    c0100f31 <cga_init+0x54>
    } else {
        *cp = was;
c0100f1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f21:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f25:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f28:	66 c7 05 46 b4 12 c0 	movw   $0x3d4,0xc012b446
c0100f2f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f31:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f38:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f3c:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f40:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f44:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f48:	ee                   	out    %al,(%dx)
}
c0100f49:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f4a:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f51:	40                   	inc    %eax
c0100f52:	0f b7 c0             	movzwl %ax,%eax
c0100f55:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f59:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f5d:	89 c2                	mov    %eax,%edx
c0100f5f:	ec                   	in     (%dx),%al
c0100f60:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f63:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f67:	0f b6 c0             	movzbl %al,%eax
c0100f6a:	c1 e0 08             	shl    $0x8,%eax
c0100f6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f70:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f77:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f7b:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f7f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f83:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f87:	ee                   	out    %al,(%dx)
}
c0100f88:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f89:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f90:	40                   	inc    %eax
c0100f91:	0f b7 c0             	movzwl %ax,%eax
c0100f94:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f98:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f9c:	89 c2                	mov    %eax,%edx
c0100f9e:	ec                   	in     (%dx),%al
c0100f9f:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fa2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fa6:	0f b6 c0             	movzbl %al,%eax
c0100fa9:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100faf:	a3 40 b4 12 c0       	mov    %eax,0xc012b440
    crt_pos = pos;
c0100fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fb7:	0f b7 c0             	movzwl %ax,%eax
c0100fba:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
}
c0100fc0:	90                   	nop
c0100fc1:	89 ec                	mov    %ebp,%esp
c0100fc3:	5d                   	pop    %ebp
c0100fc4:	c3                   	ret    

c0100fc5 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fc5:	55                   	push   %ebp
c0100fc6:	89 e5                	mov    %esp,%ebp
c0100fc8:	83 ec 48             	sub    $0x48,%esp
c0100fcb:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fd1:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fd5:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fd9:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fdd:	ee                   	out    %al,(%dx)
}
c0100fde:	90                   	nop
c0100fdf:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100fe5:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe9:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fed:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100ff1:	ee                   	out    %al,(%dx)
}
c0100ff2:	90                   	nop
c0100ff3:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100ff9:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ffd:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101001:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101005:	ee                   	out    %al,(%dx)
}
c0101006:	90                   	nop
c0101007:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010100d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101011:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101015:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101019:	ee                   	out    %al,(%dx)
}
c010101a:	90                   	nop
c010101b:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101021:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101025:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101029:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010102d:	ee                   	out    %al,(%dx)
}
c010102e:	90                   	nop
c010102f:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101035:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101039:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010103d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101041:	ee                   	out    %al,(%dx)
}
c0101042:	90                   	nop
c0101043:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101049:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010104d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101051:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101055:	ee                   	out    %al,(%dx)
}
c0101056:	90                   	nop
c0101057:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010105d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101061:	89 c2                	mov    %eax,%edx
c0101063:	ec                   	in     (%dx),%al
c0101064:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101067:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010106b:	3c ff                	cmp    $0xff,%al
c010106d:	0f 95 c0             	setne  %al
c0101070:	0f b6 c0             	movzbl %al,%eax
c0101073:	a3 48 b4 12 c0       	mov    %eax,0xc012b448
c0101078:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010107e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101082:	89 c2                	mov    %eax,%edx
c0101084:	ec                   	in     (%dx),%al
c0101085:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101088:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010108e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101092:	89 c2                	mov    %eax,%edx
c0101094:	ec                   	in     (%dx),%al
c0101095:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101098:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c010109d:	85 c0                	test   %eax,%eax
c010109f:	74 0c                	je     c01010ad <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c01010a1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010a8:	e8 84 0f 00 00       	call   c0102031 <pic_enable>
    }
}
c01010ad:	90                   	nop
c01010ae:	89 ec                	mov    %ebp,%esp
c01010b0:	5d                   	pop    %ebp
c01010b1:	c3                   	ret    

c01010b2 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010b2:	55                   	push   %ebp
c01010b3:	89 e5                	mov    %esp,%ebp
c01010b5:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010bf:	eb 08                	jmp    c01010c9 <lpt_putc_sub+0x17>
        delay();
c01010c1:	e8 cc fd ff ff       	call   c0100e92 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010c6:	ff 45 fc             	incl   -0x4(%ebp)
c01010c9:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010cf:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010d3:	89 c2                	mov    %eax,%edx
c01010d5:	ec                   	in     (%dx),%al
c01010d6:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010d9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010dd:	84 c0                	test   %al,%al
c01010df:	78 09                	js     c01010ea <lpt_putc_sub+0x38>
c01010e1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010e8:	7e d7                	jle    c01010c1 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01010ed:	0f b6 c0             	movzbl %al,%eax
c01010f0:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010f6:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010f9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010fd:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101101:	ee                   	out    %al,(%dx)
}
c0101102:	90                   	nop
c0101103:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101109:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010110d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101111:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101115:	ee                   	out    %al,(%dx)
}
c0101116:	90                   	nop
c0101117:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010111d:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101121:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101125:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101129:	ee                   	out    %al,(%dx)
}
c010112a:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010112b:	90                   	nop
c010112c:	89 ec                	mov    %ebp,%esp
c010112e:	5d                   	pop    %ebp
c010112f:	c3                   	ret    

c0101130 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101130:	55                   	push   %ebp
c0101131:	89 e5                	mov    %esp,%ebp
c0101133:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101136:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010113a:	74 0d                	je     c0101149 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010113c:	8b 45 08             	mov    0x8(%ebp),%eax
c010113f:	89 04 24             	mov    %eax,(%esp)
c0101142:	e8 6b ff ff ff       	call   c01010b2 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101147:	eb 24                	jmp    c010116d <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101149:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101150:	e8 5d ff ff ff       	call   c01010b2 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101155:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010115c:	e8 51 ff ff ff       	call   c01010b2 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101161:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101168:	e8 45 ff ff ff       	call   c01010b2 <lpt_putc_sub>
}
c010116d:	90                   	nop
c010116e:	89 ec                	mov    %ebp,%esp
c0101170:	5d                   	pop    %ebp
c0101171:	c3                   	ret    

c0101172 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101172:	55                   	push   %ebp
c0101173:	89 e5                	mov    %esp,%ebp
c0101175:	83 ec 38             	sub    $0x38,%esp
c0101178:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c010117b:	8b 45 08             	mov    0x8(%ebp),%eax
c010117e:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101183:	85 c0                	test   %eax,%eax
c0101185:	75 07                	jne    c010118e <cga_putc+0x1c>
        c |= 0x0700;
c0101187:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010118e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101191:	0f b6 c0             	movzbl %al,%eax
c0101194:	83 f8 0d             	cmp    $0xd,%eax
c0101197:	74 72                	je     c010120b <cga_putc+0x99>
c0101199:	83 f8 0d             	cmp    $0xd,%eax
c010119c:	0f 8f a3 00 00 00    	jg     c0101245 <cga_putc+0xd3>
c01011a2:	83 f8 08             	cmp    $0x8,%eax
c01011a5:	74 0a                	je     c01011b1 <cga_putc+0x3f>
c01011a7:	83 f8 0a             	cmp    $0xa,%eax
c01011aa:	74 4c                	je     c01011f8 <cga_putc+0x86>
c01011ac:	e9 94 00 00 00       	jmp    c0101245 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c01011b1:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01011b8:	85 c0                	test   %eax,%eax
c01011ba:	0f 84 af 00 00 00    	je     c010126f <cga_putc+0xfd>
            crt_pos --;
c01011c0:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01011c7:	48                   	dec    %eax
c01011c8:	0f b7 c0             	movzwl %ax,%eax
c01011cb:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01011d4:	98                   	cwtl   
c01011d5:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011da:	98                   	cwtl   
c01011db:	83 c8 20             	or     $0x20,%eax
c01011de:	98                   	cwtl   
c01011df:	8b 0d 40 b4 12 c0    	mov    0xc012b440,%ecx
c01011e5:	0f b7 15 44 b4 12 c0 	movzwl 0xc012b444,%edx
c01011ec:	01 d2                	add    %edx,%edx
c01011ee:	01 ca                	add    %ecx,%edx
c01011f0:	0f b7 c0             	movzwl %ax,%eax
c01011f3:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011f6:	eb 77                	jmp    c010126f <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011f8:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01011ff:	83 c0 50             	add    $0x50,%eax
c0101202:	0f b7 c0             	movzwl %ax,%eax
c0101205:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010120b:	0f b7 1d 44 b4 12 c0 	movzwl 0xc012b444,%ebx
c0101212:	0f b7 0d 44 b4 12 c0 	movzwl 0xc012b444,%ecx
c0101219:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c010121e:	89 c8                	mov    %ecx,%eax
c0101220:	f7 e2                	mul    %edx
c0101222:	c1 ea 06             	shr    $0x6,%edx
c0101225:	89 d0                	mov    %edx,%eax
c0101227:	c1 e0 02             	shl    $0x2,%eax
c010122a:	01 d0                	add    %edx,%eax
c010122c:	c1 e0 04             	shl    $0x4,%eax
c010122f:	29 c1                	sub    %eax,%ecx
c0101231:	89 ca                	mov    %ecx,%edx
c0101233:	0f b7 d2             	movzwl %dx,%edx
c0101236:	89 d8                	mov    %ebx,%eax
c0101238:	29 d0                	sub    %edx,%eax
c010123a:	0f b7 c0             	movzwl %ax,%eax
c010123d:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
        break;
c0101243:	eb 2b                	jmp    c0101270 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101245:	8b 0d 40 b4 12 c0    	mov    0xc012b440,%ecx
c010124b:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0101252:	8d 50 01             	lea    0x1(%eax),%edx
c0101255:	0f b7 d2             	movzwl %dx,%edx
c0101258:	66 89 15 44 b4 12 c0 	mov    %dx,0xc012b444
c010125f:	01 c0                	add    %eax,%eax
c0101261:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101264:	8b 45 08             	mov    0x8(%ebp),%eax
c0101267:	0f b7 c0             	movzwl %ax,%eax
c010126a:	66 89 02             	mov    %ax,(%edx)
        break;
c010126d:	eb 01                	jmp    c0101270 <cga_putc+0xfe>
        break;
c010126f:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101270:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0101277:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c010127c:	76 5e                	jbe    c01012dc <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010127e:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c0101283:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101289:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c010128e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101295:	00 
c0101296:	89 54 24 04          	mov    %edx,0x4(%esp)
c010129a:	89 04 24             	mov    %eax,(%esp)
c010129d:	e8 23 8d 00 00       	call   c0109fc5 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012a2:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012a9:	eb 15                	jmp    c01012c0 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c01012ab:	8b 15 40 b4 12 c0    	mov    0xc012b440,%edx
c01012b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012b4:	01 c0                	add    %eax,%eax
c01012b6:	01 d0                	add    %edx,%eax
c01012b8:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012bd:	ff 45 f4             	incl   -0xc(%ebp)
c01012c0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012c7:	7e e2                	jle    c01012ab <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012c9:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01012d0:	83 e8 50             	sub    $0x50,%eax
c01012d3:	0f b7 c0             	movzwl %ax,%eax
c01012d6:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012dc:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c01012e3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012e7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012eb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012ef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012f3:	ee                   	out    %al,(%dx)
}
c01012f4:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012f5:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01012fc:	c1 e8 08             	shr    $0x8,%eax
c01012ff:	0f b7 c0             	movzwl %ax,%eax
c0101302:	0f b6 c0             	movzbl %al,%eax
c0101305:	0f b7 15 46 b4 12 c0 	movzwl 0xc012b446,%edx
c010130c:	42                   	inc    %edx
c010130d:	0f b7 d2             	movzwl %dx,%edx
c0101310:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101314:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101317:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010131b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010131f:	ee                   	out    %al,(%dx)
}
c0101320:	90                   	nop
    outb(addr_6845, 15);
c0101321:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0101328:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010132c:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101330:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101334:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101338:	ee                   	out    %al,(%dx)
}
c0101339:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010133a:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0101341:	0f b6 c0             	movzbl %al,%eax
c0101344:	0f b7 15 46 b4 12 c0 	movzwl 0xc012b446,%edx
c010134b:	42                   	inc    %edx
c010134c:	0f b7 d2             	movzwl %dx,%edx
c010134f:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101353:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101356:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010135a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010135e:	ee                   	out    %al,(%dx)
}
c010135f:	90                   	nop
}
c0101360:	90                   	nop
c0101361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101364:	89 ec                	mov    %ebp,%esp
c0101366:	5d                   	pop    %ebp
c0101367:	c3                   	ret    

c0101368 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101368:	55                   	push   %ebp
c0101369:	89 e5                	mov    %esp,%ebp
c010136b:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010136e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101375:	eb 08                	jmp    c010137f <serial_putc_sub+0x17>
        delay();
c0101377:	e8 16 fb ff ff       	call   c0100e92 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010137c:	ff 45 fc             	incl   -0x4(%ebp)
c010137f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101385:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101389:	89 c2                	mov    %eax,%edx
c010138b:	ec                   	in     (%dx),%al
c010138c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010138f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101393:	0f b6 c0             	movzbl %al,%eax
c0101396:	83 e0 20             	and    $0x20,%eax
c0101399:	85 c0                	test   %eax,%eax
c010139b:	75 09                	jne    c01013a6 <serial_putc_sub+0x3e>
c010139d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013a4:	7e d1                	jle    c0101377 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c01013a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a9:	0f b6 c0             	movzbl %al,%eax
c01013ac:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013b2:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013b5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013b9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013bd:	ee                   	out    %al,(%dx)
}
c01013be:	90                   	nop
}
c01013bf:	90                   	nop
c01013c0:	89 ec                	mov    %ebp,%esp
c01013c2:	5d                   	pop    %ebp
c01013c3:	c3                   	ret    

c01013c4 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013c4:	55                   	push   %ebp
c01013c5:	89 e5                	mov    %esp,%ebp
c01013c7:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013ca:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013ce:	74 0d                	je     c01013dd <serial_putc+0x19>
        serial_putc_sub(c);
c01013d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01013d3:	89 04 24             	mov    %eax,(%esp)
c01013d6:	e8 8d ff ff ff       	call   c0101368 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013db:	eb 24                	jmp    c0101401 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013e4:	e8 7f ff ff ff       	call   c0101368 <serial_putc_sub>
        serial_putc_sub(' ');
c01013e9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013f0:	e8 73 ff ff ff       	call   c0101368 <serial_putc_sub>
        serial_putc_sub('\b');
c01013f5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013fc:	e8 67 ff ff ff       	call   c0101368 <serial_putc_sub>
}
c0101401:	90                   	nop
c0101402:	89 ec                	mov    %ebp,%esp
c0101404:	5d                   	pop    %ebp
c0101405:	c3                   	ret    

c0101406 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101406:	55                   	push   %ebp
c0101407:	89 e5                	mov    %esp,%ebp
c0101409:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010140c:	eb 33                	jmp    c0101441 <cons_intr+0x3b>
        if (c != 0) {
c010140e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101412:	74 2d                	je     c0101441 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101414:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0101419:	8d 50 01             	lea    0x1(%eax),%edx
c010141c:	89 15 64 b6 12 c0    	mov    %edx,0xc012b664
c0101422:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101425:	88 90 60 b4 12 c0    	mov    %dl,-0x3fed4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010142b:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0101430:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101435:	75 0a                	jne    c0101441 <cons_intr+0x3b>
                cons.wpos = 0;
c0101437:	c7 05 64 b6 12 c0 00 	movl   $0x0,0xc012b664
c010143e:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101441:	8b 45 08             	mov    0x8(%ebp),%eax
c0101444:	ff d0                	call   *%eax
c0101446:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101449:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c010144d:	75 bf                	jne    c010140e <cons_intr+0x8>
            }
        }
    }
}
c010144f:	90                   	nop
c0101450:	90                   	nop
c0101451:	89 ec                	mov    %ebp,%esp
c0101453:	5d                   	pop    %ebp
c0101454:	c3                   	ret    

c0101455 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101455:	55                   	push   %ebp
c0101456:	89 e5                	mov    %esp,%ebp
c0101458:	83 ec 10             	sub    $0x10,%esp
c010145b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101461:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101465:	89 c2                	mov    %eax,%edx
c0101467:	ec                   	in     (%dx),%al
c0101468:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010146b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010146f:	0f b6 c0             	movzbl %al,%eax
c0101472:	83 e0 01             	and    $0x1,%eax
c0101475:	85 c0                	test   %eax,%eax
c0101477:	75 07                	jne    c0101480 <serial_proc_data+0x2b>
        return -1;
c0101479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010147e:	eb 2a                	jmp    c01014aa <serial_proc_data+0x55>
c0101480:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101486:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010148a:	89 c2                	mov    %eax,%edx
c010148c:	ec                   	in     (%dx),%al
c010148d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101490:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101494:	0f b6 c0             	movzbl %al,%eax
c0101497:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010149a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010149e:	75 07                	jne    c01014a7 <serial_proc_data+0x52>
        c = '\b';
c01014a0:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014aa:	89 ec                	mov    %ebp,%esp
c01014ac:	5d                   	pop    %ebp
c01014ad:	c3                   	ret    

c01014ae <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014ae:	55                   	push   %ebp
c01014af:	89 e5                	mov    %esp,%ebp
c01014b1:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014b4:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01014b9:	85 c0                	test   %eax,%eax
c01014bb:	74 0c                	je     c01014c9 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01014bd:	c7 04 24 55 14 10 c0 	movl   $0xc0101455,(%esp)
c01014c4:	e8 3d ff ff ff       	call   c0101406 <cons_intr>
    }
}
c01014c9:	90                   	nop
c01014ca:	89 ec                	mov    %ebp,%esp
c01014cc:	5d                   	pop    %ebp
c01014cd:	c3                   	ret    

c01014ce <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014ce:	55                   	push   %ebp
c01014cf:	89 e5                	mov    %esp,%ebp
c01014d1:	83 ec 38             	sub    $0x38,%esp
c01014d4:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014dd:	89 c2                	mov    %eax,%edx
c01014df:	ec                   	in     (%dx),%al
c01014e0:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014e7:	0f b6 c0             	movzbl %al,%eax
c01014ea:	83 e0 01             	and    $0x1,%eax
c01014ed:	85 c0                	test   %eax,%eax
c01014ef:	75 0a                	jne    c01014fb <kbd_proc_data+0x2d>
        return -1;
c01014f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014f6:	e9 56 01 00 00       	jmp    c0101651 <kbd_proc_data+0x183>
c01014fb:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101501:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101504:	89 c2                	mov    %eax,%edx
c0101506:	ec                   	in     (%dx),%al
c0101507:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010150a:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010150e:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101511:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101515:	75 17                	jne    c010152e <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101517:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010151c:	83 c8 40             	or     $0x40,%eax
c010151f:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
        return 0;
c0101524:	b8 00 00 00 00       	mov    $0x0,%eax
c0101529:	e9 23 01 00 00       	jmp    c0101651 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c010152e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101532:	84 c0                	test   %al,%al
c0101534:	79 45                	jns    c010157b <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101536:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010153b:	83 e0 40             	and    $0x40,%eax
c010153e:	85 c0                	test   %eax,%eax
c0101540:	75 08                	jne    c010154a <kbd_proc_data+0x7c>
c0101542:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101546:	24 7f                	and    $0x7f,%al
c0101548:	eb 04                	jmp    c010154e <kbd_proc_data+0x80>
c010154a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010154e:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101551:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101555:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c010155c:	0c 40                	or     $0x40,%al
c010155e:	0f b6 c0             	movzbl %al,%eax
c0101561:	f7 d0                	not    %eax
c0101563:	89 c2                	mov    %eax,%edx
c0101565:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010156a:	21 d0                	and    %edx,%eax
c010156c:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
        return 0;
c0101571:	b8 00 00 00 00       	mov    $0x0,%eax
c0101576:	e9 d6 00 00 00       	jmp    c0101651 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c010157b:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c0101580:	83 e0 40             	and    $0x40,%eax
c0101583:	85 c0                	test   %eax,%eax
c0101585:	74 11                	je     c0101598 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101587:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010158b:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c0101590:	83 e0 bf             	and    $0xffffffbf,%eax
c0101593:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
    }

    shift |= shiftcode[data];
c0101598:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010159c:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c01015a3:	0f b6 d0             	movzbl %al,%edx
c01015a6:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015ab:	09 d0                	or     %edx,%eax
c01015ad:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
    shift ^= togglecode[data];
c01015b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b6:	0f b6 80 40 81 12 c0 	movzbl -0x3fed7ec0(%eax),%eax
c01015bd:	0f b6 d0             	movzbl %al,%edx
c01015c0:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015c5:	31 d0                	xor    %edx,%eax
c01015c7:	a3 68 b6 12 c0       	mov    %eax,0xc012b668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015cc:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015d1:	83 e0 03             	and    $0x3,%eax
c01015d4:	8b 14 85 40 85 12 c0 	mov    -0x3fed7ac0(,%eax,4),%edx
c01015db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015df:	01 d0                	add    %edx,%eax
c01015e1:	0f b6 00             	movzbl (%eax),%eax
c01015e4:	0f b6 c0             	movzbl %al,%eax
c01015e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015ea:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015ef:	83 e0 08             	and    $0x8,%eax
c01015f2:	85 c0                	test   %eax,%eax
c01015f4:	74 22                	je     c0101618 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015f6:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015fa:	7e 0c                	jle    c0101608 <kbd_proc_data+0x13a>
c01015fc:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101600:	7f 06                	jg     c0101608 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101602:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101606:	eb 10                	jmp    c0101618 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101608:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010160c:	7e 0a                	jle    c0101618 <kbd_proc_data+0x14a>
c010160e:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101612:	7f 04                	jg     c0101618 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101614:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101618:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010161d:	f7 d0                	not    %eax
c010161f:	83 e0 06             	and    $0x6,%eax
c0101622:	85 c0                	test   %eax,%eax
c0101624:	75 28                	jne    c010164e <kbd_proc_data+0x180>
c0101626:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c010162d:	75 1f                	jne    c010164e <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c010162f:	c7 04 24 33 a4 10 c0 	movl   $0xc010a433,(%esp)
c0101636:	e8 32 ed ff ff       	call   c010036d <cprintf>
c010163b:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101641:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101645:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101649:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010164c:	ee                   	out    %al,(%dx)
}
c010164d:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101651:	89 ec                	mov    %ebp,%esp
c0101653:	5d                   	pop    %ebp
c0101654:	c3                   	ret    

c0101655 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101655:	55                   	push   %ebp
c0101656:	89 e5                	mov    %esp,%ebp
c0101658:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c010165b:	c7 04 24 ce 14 10 c0 	movl   $0xc01014ce,(%esp)
c0101662:	e8 9f fd ff ff       	call   c0101406 <cons_intr>
}
c0101667:	90                   	nop
c0101668:	89 ec                	mov    %ebp,%esp
c010166a:	5d                   	pop    %ebp
c010166b:	c3                   	ret    

c010166c <kbd_init>:

static void
kbd_init(void) {
c010166c:	55                   	push   %ebp
c010166d:	89 e5                	mov    %esp,%ebp
c010166f:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101672:	e8 de ff ff ff       	call   c0101655 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010167e:	e8 ae 09 00 00       	call   c0102031 <pic_enable>
}
c0101683:	90                   	nop
c0101684:	89 ec                	mov    %ebp,%esp
c0101686:	5d                   	pop    %ebp
c0101687:	c3                   	ret    

c0101688 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101688:	55                   	push   %ebp
c0101689:	89 e5                	mov    %esp,%ebp
c010168b:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c010168e:	e8 4a f8 ff ff       	call   c0100edd <cga_init>
    serial_init();
c0101693:	e8 2d f9 ff ff       	call   c0100fc5 <serial_init>
    kbd_init();
c0101698:	e8 cf ff ff ff       	call   c010166c <kbd_init>
    if (!serial_exists) {
c010169d:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01016a2:	85 c0                	test   %eax,%eax
c01016a4:	75 0c                	jne    c01016b2 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01016a6:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c01016ad:	e8 bb ec ff ff       	call   c010036d <cprintf>
    }
}
c01016b2:	90                   	nop
c01016b3:	89 ec                	mov    %ebp,%esp
c01016b5:	5d                   	pop    %ebp
c01016b6:	c3                   	ret    

c01016b7 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016b7:	55                   	push   %ebp
c01016b8:	89 e5                	mov    %esp,%ebp
c01016ba:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016bd:	e8 8e f7 ff ff       	call   c0100e50 <__intr_save>
c01016c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c8:	89 04 24             	mov    %eax,(%esp)
c01016cb:	e8 60 fa ff ff       	call   c0101130 <lpt_putc>
        cga_putc(c);
c01016d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d3:	89 04 24             	mov    %eax,(%esp)
c01016d6:	e8 97 fa ff ff       	call   c0101172 <cga_putc>
        serial_putc(c);
c01016db:	8b 45 08             	mov    0x8(%ebp),%eax
c01016de:	89 04 24             	mov    %eax,(%esp)
c01016e1:	e8 de fc ff ff       	call   c01013c4 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016e9:	89 04 24             	mov    %eax,(%esp)
c01016ec:	e8 8b f7 ff ff       	call   c0100e7c <__intr_restore>
}
c01016f1:	90                   	nop
c01016f2:	89 ec                	mov    %ebp,%esp
c01016f4:	5d                   	pop    %ebp
c01016f5:	c3                   	ret    

c01016f6 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016f6:	55                   	push   %ebp
c01016f7:	89 e5                	mov    %esp,%ebp
c01016f9:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101703:	e8 48 f7 ff ff       	call   c0100e50 <__intr_save>
c0101708:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010170b:	e8 9e fd ff ff       	call   c01014ae <serial_intr>
        kbd_intr();
c0101710:	e8 40 ff ff ff       	call   c0101655 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101715:	8b 15 60 b6 12 c0    	mov    0xc012b660,%edx
c010171b:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0101720:	39 c2                	cmp    %eax,%edx
c0101722:	74 31                	je     c0101755 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101724:	a1 60 b6 12 c0       	mov    0xc012b660,%eax
c0101729:	8d 50 01             	lea    0x1(%eax),%edx
c010172c:	89 15 60 b6 12 c0    	mov    %edx,0xc012b660
c0101732:	0f b6 80 60 b4 12 c0 	movzbl -0x3fed4ba0(%eax),%eax
c0101739:	0f b6 c0             	movzbl %al,%eax
c010173c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010173f:	a1 60 b6 12 c0       	mov    0xc012b660,%eax
c0101744:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101749:	75 0a                	jne    c0101755 <cons_getc+0x5f>
                cons.rpos = 0;
c010174b:	c7 05 60 b6 12 c0 00 	movl   $0x0,0xc012b660
c0101752:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101755:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101758:	89 04 24             	mov    %eax,(%esp)
c010175b:	e8 1c f7 ff ff       	call   c0100e7c <__intr_restore>
    return c;
c0101760:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101763:	89 ec                	mov    %ebp,%esp
c0101765:	5d                   	pop    %ebp
c0101766:	c3                   	ret    

c0101767 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0101767:	55                   	push   %ebp
c0101768:	89 e5                	mov    %esp,%ebp
c010176a:	83 ec 14             	sub    $0x14,%esp
c010176d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101770:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101774:	90                   	nop
c0101775:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101778:	83 c0 07             	add    $0x7,%eax
c010177b:	0f b7 c0             	movzwl %ax,%eax
c010177e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101782:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101786:	89 c2                	mov    %eax,%edx
c0101788:	ec                   	in     (%dx),%al
c0101789:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010178c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101790:	0f b6 c0             	movzbl %al,%eax
c0101793:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101796:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101799:	25 80 00 00 00       	and    $0x80,%eax
c010179e:	85 c0                	test   %eax,%eax
c01017a0:	75 d3                	jne    c0101775 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01017a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01017a6:	74 11                	je     c01017b9 <ide_wait_ready+0x52>
c01017a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ab:	83 e0 21             	and    $0x21,%eax
c01017ae:	85 c0                	test   %eax,%eax
c01017b0:	74 07                	je     c01017b9 <ide_wait_ready+0x52>
        return -1;
c01017b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01017b7:	eb 05                	jmp    c01017be <ide_wait_ready+0x57>
    }
    return 0;
c01017b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017be:	89 ec                	mov    %ebp,%esp
c01017c0:	5d                   	pop    %ebp
c01017c1:	c3                   	ret    

c01017c2 <ide_init>:

void
ide_init(void) {
c01017c2:	55                   	push   %ebp
c01017c3:	89 e5                	mov    %esp,%ebp
c01017c5:	57                   	push   %edi
c01017c6:	53                   	push   %ebx
c01017c7:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01017cd:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01017d3:	e9 bd 02 00 00       	jmp    c0101a95 <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01017d8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017dc:	89 d0                	mov    %edx,%eax
c01017de:	c1 e0 03             	shl    $0x3,%eax
c01017e1:	29 d0                	sub    %edx,%eax
c01017e3:	c1 e0 03             	shl    $0x3,%eax
c01017e6:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c01017eb:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c01017ee:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017f2:	d1 e8                	shr    %eax
c01017f4:	0f b7 c0             	movzwl %ax,%eax
c01017f7:	8b 04 85 60 a4 10 c0 	mov    -0x3fef5ba0(,%eax,4),%eax
c01017fe:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101802:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101806:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010180d:	00 
c010180e:	89 04 24             	mov    %eax,(%esp)
c0101811:	e8 51 ff ff ff       	call   c0101767 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101816:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010181a:	c1 e0 04             	shl    $0x4,%eax
c010181d:	24 10                	and    $0x10,%al
c010181f:	0c e0                	or     $0xe0,%al
c0101821:	0f b6 c0             	movzbl %al,%eax
c0101824:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101828:	83 c2 06             	add    $0x6,%edx
c010182b:	0f b7 d2             	movzwl %dx,%edx
c010182e:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0101832:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101835:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101839:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010183d:	ee                   	out    %al,(%dx)
}
c010183e:	90                   	nop
        ide_wait_ready(iobase, 0);
c010183f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101843:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010184a:	00 
c010184b:	89 04 24             	mov    %eax,(%esp)
c010184e:	e8 14 ff ff ff       	call   c0101767 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0101853:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101857:	83 c0 07             	add    $0x7,%eax
c010185a:	0f b7 c0             	movzwl %ax,%eax
c010185d:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101861:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101865:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101869:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010186d:	ee                   	out    %al,(%dx)
}
c010186e:	90                   	nop
        ide_wait_ready(iobase, 0);
c010186f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101873:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010187a:	00 
c010187b:	89 04 24             	mov    %eax,(%esp)
c010187e:	e8 e4 fe ff ff       	call   c0101767 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101883:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101887:	83 c0 07             	add    $0x7,%eax
c010188a:	0f b7 c0             	movzwl %ax,%eax
c010188d:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101891:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101895:	89 c2                	mov    %eax,%edx
c0101897:	ec                   	in     (%dx),%al
c0101898:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c010189b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010189f:	84 c0                	test   %al,%al
c01018a1:	0f 84 e4 01 00 00    	je     c0101a8b <ide_init+0x2c9>
c01018a7:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01018b2:	00 
c01018b3:	89 04 24             	mov    %eax,(%esp)
c01018b6:	e8 ac fe ff ff       	call   c0101767 <ide_wait_ready>
c01018bb:	85 c0                	test   %eax,%eax
c01018bd:	0f 85 c8 01 00 00    	jne    c0101a8b <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c01018c3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018c7:	89 d0                	mov    %edx,%eax
c01018c9:	c1 e0 03             	shl    $0x3,%eax
c01018cc:	29 d0                	sub    %edx,%eax
c01018ce:	c1 e0 03             	shl    $0x3,%eax
c01018d1:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c01018d6:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01018d9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018dd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01018e0:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01018e6:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01018e9:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c01018f0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01018f3:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01018f6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01018f9:	89 cb                	mov    %ecx,%ebx
c01018fb:	89 df                	mov    %ebx,%edi
c01018fd:	89 c1                	mov    %eax,%ecx
c01018ff:	fc                   	cld    
c0101900:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101902:	89 c8                	mov    %ecx,%eax
c0101904:	89 fb                	mov    %edi,%ebx
c0101906:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101909:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c010190c:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c010190d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101913:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101919:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010191f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101922:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101925:	25 00 00 00 04       	and    $0x4000000,%eax
c010192a:	85 c0                	test   %eax,%eax
c010192c:	74 0e                	je     c010193c <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010192e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101931:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101937:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010193a:	eb 09                	jmp    c0101945 <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c010193c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010193f:	8b 40 78             	mov    0x78(%eax),%eax
c0101942:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101945:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101949:	89 d0                	mov    %edx,%eax
c010194b:	c1 e0 03             	shl    $0x3,%eax
c010194e:	29 d0                	sub    %edx,%eax
c0101950:	c1 e0 03             	shl    $0x3,%eax
c0101953:	8d 90 84 b6 12 c0    	lea    -0x3fed497c(%eax),%edx
c0101959:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010195c:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c010195e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101962:	89 d0                	mov    %edx,%eax
c0101964:	c1 e0 03             	shl    $0x3,%eax
c0101967:	29 d0                	sub    %edx,%eax
c0101969:	c1 e0 03             	shl    $0x3,%eax
c010196c:	8d 90 88 b6 12 c0    	lea    -0x3fed4978(%eax),%edx
c0101972:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101975:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010197a:	83 c0 62             	add    $0x62,%eax
c010197d:	0f b7 00             	movzwl (%eax),%eax
c0101980:	25 00 02 00 00       	and    $0x200,%eax
c0101985:	85 c0                	test   %eax,%eax
c0101987:	75 24                	jne    c01019ad <ide_init+0x1eb>
c0101989:	c7 44 24 0c 68 a4 10 	movl   $0xc010a468,0xc(%esp)
c0101990:	c0 
c0101991:	c7 44 24 08 ab a4 10 	movl   $0xc010a4ab,0x8(%esp)
c0101998:	c0 
c0101999:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01019a0:	00 
c01019a1:	c7 04 24 c0 a4 10 c0 	movl   $0xc010a4c0,(%esp)
c01019a8:	e8 69 f3 ff ff       	call   c0100d16 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01019ad:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01019b1:	89 d0                	mov    %edx,%eax
c01019b3:	c1 e0 03             	shl    $0x3,%eax
c01019b6:	29 d0                	sub    %edx,%eax
c01019b8:	c1 e0 03             	shl    $0x3,%eax
c01019bb:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c01019c0:	83 c0 0c             	add    $0xc,%eax
c01019c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01019c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019c9:	83 c0 36             	add    $0x36,%eax
c01019cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01019cf:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01019d6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01019dd:	eb 34                	jmp    c0101a13 <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01019df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019e2:	8d 50 01             	lea    0x1(%eax),%edx
c01019e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01019e8:	01 c2                	add    %eax,%edx
c01019ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01019ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019f0:	01 c8                	add    %ecx,%eax
c01019f2:	0f b6 12             	movzbl (%edx),%edx
c01019f5:	88 10                	mov    %dl,(%eax)
c01019f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01019fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019fd:	01 c2                	add    %eax,%edx
c01019ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a02:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a05:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a08:	01 c8                	add    %ecx,%eax
c0101a0a:	0f b6 12             	movzbl (%edx),%edx
c0101a0d:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0101a0f:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a16:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a19:	72 c4                	jb     c01019df <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c0101a1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a21:	01 d0                	add    %edx,%eax
c0101a23:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a29:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a2c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a2f:	85 c0                	test   %eax,%eax
c0101a31:	74 0f                	je     c0101a42 <ide_init+0x280>
c0101a33:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a39:	01 d0                	add    %edx,%eax
c0101a3b:	0f b6 00             	movzbl (%eax),%eax
c0101a3e:	3c 20                	cmp    $0x20,%al
c0101a40:	74 d9                	je     c0101a1b <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a42:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a46:	89 d0                	mov    %edx,%eax
c0101a48:	c1 e0 03             	shl    $0x3,%eax
c0101a4b:	29 d0                	sub    %edx,%eax
c0101a4d:	c1 e0 03             	shl    $0x3,%eax
c0101a50:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101a55:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101a58:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a5c:	89 d0                	mov    %edx,%eax
c0101a5e:	c1 e0 03             	shl    $0x3,%eax
c0101a61:	29 d0                	sub    %edx,%eax
c0101a63:	c1 e0 03             	shl    $0x3,%eax
c0101a66:	05 88 b6 12 c0       	add    $0xc012b688,%eax
c0101a6b:	8b 10                	mov    (%eax),%edx
c0101a6d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a75:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a7d:	c7 04 24 d2 a4 10 c0 	movl   $0xc010a4d2,(%esp)
c0101a84:	e8 e4 e8 ff ff       	call   c010036d <cprintf>
c0101a89:	eb 01                	jmp    c0101a8c <ide_init+0x2ca>
            continue ;
c0101a8b:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a8c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a90:	40                   	inc    %eax
c0101a91:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a95:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a99:	83 f8 03             	cmp    $0x3,%eax
c0101a9c:	0f 86 36 fd ff ff    	jbe    c01017d8 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101aa2:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101aa9:	e8 83 05 00 00       	call   c0102031 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101aae:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101ab5:	e8 77 05 00 00       	call   c0102031 <pic_enable>
}
c0101aba:	90                   	nop
c0101abb:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101ac1:	5b                   	pop    %ebx
c0101ac2:	5f                   	pop    %edi
c0101ac3:	5d                   	pop    %ebp
c0101ac4:	c3                   	ret    

c0101ac5 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101ac5:	55                   	push   %ebp
c0101ac6:	89 e5                	mov    %esp,%ebp
c0101ac8:	83 ec 04             	sub    $0x4,%esp
c0101acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ace:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101ad2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101ad6:	83 f8 03             	cmp    $0x3,%eax
c0101ad9:	77 21                	ja     c0101afc <ide_device_valid+0x37>
c0101adb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101adf:	89 d0                	mov    %edx,%eax
c0101ae1:	c1 e0 03             	shl    $0x3,%eax
c0101ae4:	29 d0                	sub    %edx,%eax
c0101ae6:	c1 e0 03             	shl    $0x3,%eax
c0101ae9:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101aee:	0f b6 00             	movzbl (%eax),%eax
c0101af1:	84 c0                	test   %al,%al
c0101af3:	74 07                	je     c0101afc <ide_device_valid+0x37>
c0101af5:	b8 01 00 00 00       	mov    $0x1,%eax
c0101afa:	eb 05                	jmp    c0101b01 <ide_device_valid+0x3c>
c0101afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b01:	89 ec                	mov    %ebp,%esp
c0101b03:	5d                   	pop    %ebp
c0101b04:	c3                   	ret    

c0101b05 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b05:	55                   	push   %ebp
c0101b06:	89 e5                	mov    %esp,%ebp
c0101b08:	83 ec 08             	sub    $0x8,%esp
c0101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b12:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b16:	89 04 24             	mov    %eax,(%esp)
c0101b19:	e8 a7 ff ff ff       	call   c0101ac5 <ide_device_valid>
c0101b1e:	85 c0                	test   %eax,%eax
c0101b20:	74 17                	je     c0101b39 <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101b22:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101b26:	89 d0                	mov    %edx,%eax
c0101b28:	c1 e0 03             	shl    $0x3,%eax
c0101b2b:	29 d0                	sub    %edx,%eax
c0101b2d:	c1 e0 03             	shl    $0x3,%eax
c0101b30:	05 88 b6 12 c0       	add    $0xc012b688,%eax
c0101b35:	8b 00                	mov    (%eax),%eax
c0101b37:	eb 05                	jmp    c0101b3e <ide_device_size+0x39>
    }
    return 0;
c0101b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b3e:	89 ec                	mov    %ebp,%esp
c0101b40:	5d                   	pop    %ebp
c0101b41:	c3                   	ret    

c0101b42 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101b42:	55                   	push   %ebp
c0101b43:	89 e5                	mov    %esp,%ebp
c0101b45:	57                   	push   %edi
c0101b46:	53                   	push   %ebx
c0101b47:	83 ec 50             	sub    $0x50,%esp
c0101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4d:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101b51:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101b58:	77 23                	ja     c0101b7d <ide_read_secs+0x3b>
c0101b5a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b5e:	83 f8 03             	cmp    $0x3,%eax
c0101b61:	77 1a                	ja     c0101b7d <ide_read_secs+0x3b>
c0101b63:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101b67:	89 d0                	mov    %edx,%eax
c0101b69:	c1 e0 03             	shl    $0x3,%eax
c0101b6c:	29 d0                	sub    %edx,%eax
c0101b6e:	c1 e0 03             	shl    $0x3,%eax
c0101b71:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101b76:	0f b6 00             	movzbl (%eax),%eax
c0101b79:	84 c0                	test   %al,%al
c0101b7b:	75 24                	jne    c0101ba1 <ide_read_secs+0x5f>
c0101b7d:	c7 44 24 0c f0 a4 10 	movl   $0xc010a4f0,0xc(%esp)
c0101b84:	c0 
c0101b85:	c7 44 24 08 ab a4 10 	movl   $0xc010a4ab,0x8(%esp)
c0101b8c:	c0 
c0101b8d:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b94:	00 
c0101b95:	c7 04 24 c0 a4 10 c0 	movl   $0xc010a4c0,(%esp)
c0101b9c:	e8 75 f1 ff ff       	call   c0100d16 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101ba1:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101ba8:	77 0f                	ja     c0101bb9 <ide_read_secs+0x77>
c0101baa:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101bad:	8b 45 14             	mov    0x14(%ebp),%eax
c0101bb0:	01 d0                	add    %edx,%eax
c0101bb2:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101bb7:	76 24                	jbe    c0101bdd <ide_read_secs+0x9b>
c0101bb9:	c7 44 24 0c 18 a5 10 	movl   $0xc010a518,0xc(%esp)
c0101bc0:	c0 
c0101bc1:	c7 44 24 08 ab a4 10 	movl   $0xc010a4ab,0x8(%esp)
c0101bc8:	c0 
c0101bc9:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101bd0:	00 
c0101bd1:	c7 04 24 c0 a4 10 c0 	movl   $0xc010a4c0,(%esp)
c0101bd8:	e8 39 f1 ff ff       	call   c0100d16 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bdd:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101be1:	d1 e8                	shr    %eax
c0101be3:	0f b7 c0             	movzwl %ax,%eax
c0101be6:	8b 04 85 60 a4 10 c0 	mov    -0x3fef5ba0(,%eax,4),%eax
c0101bed:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101bf1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bf5:	d1 e8                	shr    %eax
c0101bf7:	0f b7 c0             	movzwl %ax,%eax
c0101bfa:	0f b7 04 85 62 a4 10 	movzwl -0x3fef5b9e(,%eax,4),%eax
c0101c01:	c0 
c0101c02:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c06:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c11:	00 
c0101c12:	89 04 24             	mov    %eax,(%esp)
c0101c15:	e8 4d fb ff ff       	call   c0101767 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c1d:	83 c0 02             	add    $0x2,%eax
c0101c20:	0f b7 c0             	movzwl %ax,%eax
c0101c23:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c27:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c2b:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c2f:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c33:	ee                   	out    %al,(%dx)
}
c0101c34:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101c35:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c38:	0f b6 c0             	movzbl %al,%eax
c0101c3b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c3f:	83 c2 02             	add    $0x2,%edx
c0101c42:	0f b7 d2             	movzwl %dx,%edx
c0101c45:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c49:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c4c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c50:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c54:	ee                   	out    %al,(%dx)
}
c0101c55:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101c56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c59:	0f b6 c0             	movzbl %al,%eax
c0101c5c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c60:	83 c2 03             	add    $0x3,%edx
c0101c63:	0f b7 d2             	movzwl %dx,%edx
c0101c66:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c6a:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c6d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c71:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c75:	ee                   	out    %al,(%dx)
}
c0101c76:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c7a:	c1 e8 08             	shr    $0x8,%eax
c0101c7d:	0f b6 c0             	movzbl %al,%eax
c0101c80:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c84:	83 c2 04             	add    $0x4,%edx
c0101c87:	0f b7 d2             	movzwl %dx,%edx
c0101c8a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c8e:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c91:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c95:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c99:	ee                   	out    %al,(%dx)
}
c0101c9a:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c9e:	c1 e8 10             	shr    $0x10,%eax
c0101ca1:	0f b6 c0             	movzbl %al,%eax
c0101ca4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ca8:	83 c2 05             	add    $0x5,%edx
c0101cab:	0f b7 d2             	movzwl %dx,%edx
c0101cae:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cb2:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cb5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101cb9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101cbd:	ee                   	out    %al,(%dx)
}
c0101cbe:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101cbf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101cc2:	c0 e0 04             	shl    $0x4,%al
c0101cc5:	24 10                	and    $0x10,%al
c0101cc7:	88 c2                	mov    %al,%dl
c0101cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ccc:	c1 e8 18             	shr    $0x18,%eax
c0101ccf:	24 0f                	and    $0xf,%al
c0101cd1:	08 d0                	or     %dl,%al
c0101cd3:	0c e0                	or     $0xe0,%al
c0101cd5:	0f b6 c0             	movzbl %al,%eax
c0101cd8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cdc:	83 c2 06             	add    $0x6,%edx
c0101cdf:	0f b7 d2             	movzwl %dx,%edx
c0101ce2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ce6:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ce9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101ced:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101cf1:	ee                   	out    %al,(%dx)
}
c0101cf2:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101cf3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cf7:	83 c0 07             	add    $0x7,%eax
c0101cfa:	0f b7 c0             	movzwl %ax,%eax
c0101cfd:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101d01:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d05:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101d09:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101d0d:	ee                   	out    %al,(%dx)
}
c0101d0e:	90                   	nop

    int ret = 0;
c0101d0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d16:	eb 58                	jmp    c0101d70 <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101d18:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d1c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101d23:	00 
c0101d24:	89 04 24             	mov    %eax,(%esp)
c0101d27:	e8 3b fa ff ff       	call   c0101767 <ide_wait_ready>
c0101d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d33:	75 43                	jne    c0101d78 <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d35:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d39:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101d3c:	8b 45 10             	mov    0x10(%ebp),%eax
c0101d3f:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101d42:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101d49:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101d4c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101d4f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101d52:	89 cb                	mov    %ecx,%ebx
c0101d54:	89 df                	mov    %ebx,%edi
c0101d56:	89 c1                	mov    %eax,%ecx
c0101d58:	fc                   	cld    
c0101d59:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101d5b:	89 c8                	mov    %ecx,%eax
c0101d5d:	89 fb                	mov    %edi,%ebx
c0101d5f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101d62:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101d65:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d66:	ff 4d 14             	decl   0x14(%ebp)
c0101d69:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d70:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d74:	75 a2                	jne    c0101d18 <ide_read_secs+0x1d6>
    }

out:
c0101d76:	eb 01                	jmp    c0101d79 <ide_read_secs+0x237>
            goto out;
c0101d78:	90                   	nop
    return ret;
c0101d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d7c:	83 c4 50             	add    $0x50,%esp
c0101d7f:	5b                   	pop    %ebx
c0101d80:	5f                   	pop    %edi
c0101d81:	5d                   	pop    %ebp
c0101d82:	c3                   	ret    

c0101d83 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d83:	55                   	push   %ebp
c0101d84:	89 e5                	mov    %esp,%ebp
c0101d86:	56                   	push   %esi
c0101d87:	53                   	push   %ebx
c0101d88:	83 ec 50             	sub    $0x50,%esp
c0101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8e:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d92:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d99:	77 23                	ja     c0101dbe <ide_write_secs+0x3b>
c0101d9b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d9f:	83 f8 03             	cmp    $0x3,%eax
c0101da2:	77 1a                	ja     c0101dbe <ide_write_secs+0x3b>
c0101da4:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101da8:	89 d0                	mov    %edx,%eax
c0101daa:	c1 e0 03             	shl    $0x3,%eax
c0101dad:	29 d0                	sub    %edx,%eax
c0101daf:	c1 e0 03             	shl    $0x3,%eax
c0101db2:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101db7:	0f b6 00             	movzbl (%eax),%eax
c0101dba:	84 c0                	test   %al,%al
c0101dbc:	75 24                	jne    c0101de2 <ide_write_secs+0x5f>
c0101dbe:	c7 44 24 0c f0 a4 10 	movl   $0xc010a4f0,0xc(%esp)
c0101dc5:	c0 
c0101dc6:	c7 44 24 08 ab a4 10 	movl   $0xc010a4ab,0x8(%esp)
c0101dcd:	c0 
c0101dce:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101dd5:	00 
c0101dd6:	c7 04 24 c0 a4 10 c0 	movl   $0xc010a4c0,(%esp)
c0101ddd:	e8 34 ef ff ff       	call   c0100d16 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101de2:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101de9:	77 0f                	ja     c0101dfa <ide_write_secs+0x77>
c0101deb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101dee:	8b 45 14             	mov    0x14(%ebp),%eax
c0101df1:	01 d0                	add    %edx,%eax
c0101df3:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101df8:	76 24                	jbe    c0101e1e <ide_write_secs+0x9b>
c0101dfa:	c7 44 24 0c 18 a5 10 	movl   $0xc010a518,0xc(%esp)
c0101e01:	c0 
c0101e02:	c7 44 24 08 ab a4 10 	movl   $0xc010a4ab,0x8(%esp)
c0101e09:	c0 
c0101e0a:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e11:	00 
c0101e12:	c7 04 24 c0 a4 10 c0 	movl   $0xc010a4c0,(%esp)
c0101e19:	e8 f8 ee ff ff       	call   c0100d16 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e1e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e22:	d1 e8                	shr    %eax
c0101e24:	0f b7 c0             	movzwl %ax,%eax
c0101e27:	8b 04 85 60 a4 10 c0 	mov    -0x3fef5ba0(,%eax,4),%eax
c0101e2e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e32:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e36:	d1 e8                	shr    %eax
c0101e38:	0f b7 c0             	movzwl %ax,%eax
c0101e3b:	0f b7 04 85 62 a4 10 	movzwl -0x3fef5b9e(,%eax,4),%eax
c0101e42:	c0 
c0101e43:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101e47:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101e52:	00 
c0101e53:	89 04 24             	mov    %eax,(%esp)
c0101e56:	e8 0c f9 ff ff       	call   c0101767 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e5e:	83 c0 02             	add    $0x2,%eax
c0101e61:	0f b7 c0             	movzwl %ax,%eax
c0101e64:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e68:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e6c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e70:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e74:	ee                   	out    %al,(%dx)
}
c0101e75:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101e76:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e79:	0f b6 c0             	movzbl %al,%eax
c0101e7c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e80:	83 c2 02             	add    $0x2,%edx
c0101e83:	0f b7 d2             	movzwl %dx,%edx
c0101e86:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101e8a:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e8d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101e91:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101e95:	ee                   	out    %al,(%dx)
}
c0101e96:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e97:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e9a:	0f b6 c0             	movzbl %al,%eax
c0101e9d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ea1:	83 c2 03             	add    $0x3,%edx
c0101ea4:	0f b7 d2             	movzwl %dx,%edx
c0101ea7:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101eab:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eae:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101eb2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101eb6:	ee                   	out    %al,(%dx)
}
c0101eb7:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ebb:	c1 e8 08             	shr    $0x8,%eax
c0101ebe:	0f b6 c0             	movzbl %al,%eax
c0101ec1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ec5:	83 c2 04             	add    $0x4,%edx
c0101ec8:	0f b7 d2             	movzwl %dx,%edx
c0101ecb:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101ecf:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ed2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101ed6:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101eda:	ee                   	out    %al,(%dx)
}
c0101edb:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101edc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101edf:	c1 e8 10             	shr    $0x10,%eax
c0101ee2:	0f b6 c0             	movzbl %al,%eax
c0101ee5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ee9:	83 c2 05             	add    $0x5,%edx
c0101eec:	0f b7 d2             	movzwl %dx,%edx
c0101eef:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101ef3:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ef6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101efa:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101efe:	ee                   	out    %al,(%dx)
}
c0101eff:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f00:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101f03:	c0 e0 04             	shl    $0x4,%al
c0101f06:	24 10                	and    $0x10,%al
c0101f08:	88 c2                	mov    %al,%dl
c0101f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f0d:	c1 e8 18             	shr    $0x18,%eax
c0101f10:	24 0f                	and    $0xf,%al
c0101f12:	08 d0                	or     %dl,%al
c0101f14:	0c e0                	or     $0xe0,%al
c0101f16:	0f b6 c0             	movzbl %al,%eax
c0101f19:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f1d:	83 c2 06             	add    $0x6,%edx
c0101f20:	0f b7 d2             	movzwl %dx,%edx
c0101f23:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f27:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f2a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f2e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f32:	ee                   	out    %al,(%dx)
}
c0101f33:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f34:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f38:	83 c0 07             	add    $0x7,%eax
c0101f3b:	0f b7 c0             	movzwl %ax,%eax
c0101f3e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f42:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f46:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f4a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f4e:	ee                   	out    %al,(%dx)
}
c0101f4f:	90                   	nop

    int ret = 0;
c0101f50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f57:	eb 58                	jmp    c0101fb1 <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101f59:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f5d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101f64:	00 
c0101f65:	89 04 24             	mov    %eax,(%esp)
c0101f68:	e8 fa f7 ff ff       	call   c0101767 <ide_wait_ready>
c0101f6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f74:	75 43                	jne    c0101fb9 <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f76:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f7d:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f80:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f83:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101f8a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f8d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f90:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f93:	89 cb                	mov    %ecx,%ebx
c0101f95:	89 de                	mov    %ebx,%esi
c0101f97:	89 c1                	mov    %eax,%ecx
c0101f99:	fc                   	cld    
c0101f9a:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f9c:	89 c8                	mov    %ecx,%eax
c0101f9e:	89 f3                	mov    %esi,%ebx
c0101fa0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101fa3:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101fa6:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fa7:	ff 4d 14             	decl   0x14(%ebp)
c0101faa:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101fb1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101fb5:	75 a2                	jne    c0101f59 <ide_write_secs+0x1d6>
    }

out:
c0101fb7:	eb 01                	jmp    c0101fba <ide_write_secs+0x237>
            goto out;
c0101fb9:	90                   	nop
    return ret;
c0101fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fbd:	83 c4 50             	add    $0x50,%esp
c0101fc0:	5b                   	pop    %ebx
c0101fc1:	5e                   	pop    %esi
c0101fc2:	5d                   	pop    %ebp
c0101fc3:	c3                   	ret    

c0101fc4 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101fc4:	55                   	push   %ebp
c0101fc5:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101fc7:	fb                   	sti    
}
c0101fc8:	90                   	nop
    sti();
}
c0101fc9:	90                   	nop
c0101fca:	5d                   	pop    %ebp
c0101fcb:	c3                   	ret    

c0101fcc <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101fcc:	55                   	push   %ebp
c0101fcd:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101fcf:	fa                   	cli    
}
c0101fd0:	90                   	nop
    cli();
}
c0101fd1:	90                   	nop
c0101fd2:	5d                   	pop    %ebp
c0101fd3:	c3                   	ret    

c0101fd4 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101fd4:	55                   	push   %ebp
c0101fd5:	89 e5                	mov    %esp,%ebp
c0101fd7:	83 ec 14             	sub    $0x14,%esp
c0101fda:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fdd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101fe4:	66 a3 50 85 12 c0    	mov    %ax,0xc0128550
    if (did_init) {
c0101fea:	a1 60 b7 12 c0       	mov    0xc012b760,%eax
c0101fef:	85 c0                	test   %eax,%eax
c0101ff1:	74 39                	je     c010202c <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0101ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ff6:	0f b6 c0             	movzbl %al,%eax
c0101ff9:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101fff:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102002:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102006:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010200a:	ee                   	out    %al,(%dx)
}
c010200b:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c010200c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102010:	c1 e8 08             	shr    $0x8,%eax
c0102013:	0f b7 c0             	movzwl %ax,%eax
c0102016:	0f b6 c0             	movzbl %al,%eax
c0102019:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010201f:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102022:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102026:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010202a:	ee                   	out    %al,(%dx)
}
c010202b:	90                   	nop
    }
}
c010202c:	90                   	nop
c010202d:	89 ec                	mov    %ebp,%esp
c010202f:	5d                   	pop    %ebp
c0102030:	c3                   	ret    

c0102031 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102031:	55                   	push   %ebp
c0102032:	89 e5                	mov    %esp,%ebp
c0102034:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102037:	8b 45 08             	mov    0x8(%ebp),%eax
c010203a:	ba 01 00 00 00       	mov    $0x1,%edx
c010203f:	88 c1                	mov    %al,%cl
c0102041:	d3 e2                	shl    %cl,%edx
c0102043:	89 d0                	mov    %edx,%eax
c0102045:	98                   	cwtl   
c0102046:	f7 d0                	not    %eax
c0102048:	0f bf d0             	movswl %ax,%edx
c010204b:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c0102052:	98                   	cwtl   
c0102053:	21 d0                	and    %edx,%eax
c0102055:	98                   	cwtl   
c0102056:	0f b7 c0             	movzwl %ax,%eax
c0102059:	89 04 24             	mov    %eax,(%esp)
c010205c:	e8 73 ff ff ff       	call   c0101fd4 <pic_setmask>
}
c0102061:	90                   	nop
c0102062:	89 ec                	mov    %ebp,%esp
c0102064:	5d                   	pop    %ebp
c0102065:	c3                   	ret    

c0102066 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0102066:	55                   	push   %ebp
c0102067:	89 e5                	mov    %esp,%ebp
c0102069:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010206c:	c7 05 60 b7 12 c0 01 	movl   $0x1,0xc012b760
c0102073:	00 00 00 
c0102076:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c010207c:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102080:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102084:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102088:	ee                   	out    %al,(%dx)
}
c0102089:	90                   	nop
c010208a:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0102090:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102094:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0102098:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010209c:	ee                   	out    %al,(%dx)
}
c010209d:	90                   	nop
c010209e:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020a4:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020a8:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020ac:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020b0:	ee                   	out    %al,(%dx)
}
c01020b1:	90                   	nop
c01020b2:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01020b8:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020bc:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020c0:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020c4:	ee                   	out    %al,(%dx)
}
c01020c5:	90                   	nop
c01020c6:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01020cc:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020d0:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020d4:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020d8:	ee                   	out    %al,(%dx)
}
c01020d9:	90                   	nop
c01020da:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01020e0:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020e4:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01020e8:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01020ec:	ee                   	out    %al,(%dx)
}
c01020ed:	90                   	nop
c01020ee:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01020f4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020fc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102100:	ee                   	out    %al,(%dx)
}
c0102101:	90                   	nop
c0102102:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102108:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010210c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102110:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102114:	ee                   	out    %al,(%dx)
}
c0102115:	90                   	nop
c0102116:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010211c:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102120:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102124:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102128:	ee                   	out    %al,(%dx)
}
c0102129:	90                   	nop
c010212a:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102130:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102134:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102138:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010213c:	ee                   	out    %al,(%dx)
}
c010213d:	90                   	nop
c010213e:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0102144:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102148:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010214c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102150:	ee                   	out    %al,(%dx)
}
c0102151:	90                   	nop
c0102152:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102158:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010215c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102160:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102164:	ee                   	out    %al,(%dx)
}
c0102165:	90                   	nop
c0102166:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c010216c:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102170:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102174:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102178:	ee                   	out    %al,(%dx)
}
c0102179:	90                   	nop
c010217a:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102180:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102184:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102188:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010218c:	ee                   	out    %al,(%dx)
}
c010218d:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010218e:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c0102195:	3d ff ff 00 00       	cmp    $0xffff,%eax
c010219a:	74 0f                	je     c01021ab <pic_init+0x145>
        pic_setmask(irq_mask);
c010219c:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c01021a3:	89 04 24             	mov    %eax,(%esp)
c01021a6:	e8 29 fe ff ff       	call   c0101fd4 <pic_setmask>
    }
}
c01021ab:	90                   	nop
c01021ac:	89 ec                	mov    %ebp,%esp
c01021ae:	5d                   	pop    %ebp
c01021af:	c3                   	ret    

c01021b0 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01021b0:	55                   	push   %ebp
c01021b1:	89 e5                	mov    %esp,%ebp
c01021b3:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021b6:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01021bd:	00 
c01021be:	c7 04 24 60 a5 10 c0 	movl   $0xc010a560,(%esp)
c01021c5:	e8 a3 e1 ff ff       	call   c010036d <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01021ca:	c7 04 24 6a a5 10 c0 	movl   $0xc010a56a,(%esp)
c01021d1:	e8 97 e1 ff ff       	call   c010036d <cprintf>
    panic("EOT: kernel seems ok.");
c01021d6:	c7 44 24 08 78 a5 10 	movl   $0xc010a578,0x8(%esp)
c01021dd:	c0 
c01021de:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01021e5:	00 
c01021e6:	c7 04 24 8e a5 10 c0 	movl   $0xc010a58e,(%esp)
c01021ed:	e8 24 eb ff ff       	call   c0100d16 <__panic>

c01021f2 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01021f2:	55                   	push   %ebp
c01021f3:	89 e5                	mov    %esp,%ebp
c01021f5:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */

     extern uintptr_t __vectors[];
     int i;
     for(i=0;i<256;i++)
c01021f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01021ff:	e9 c4 00 00 00       	jmp    c01022c8 <idt_init+0xd6>
     {
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
c0102204:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102207:	8b 04 85 e0 85 12 c0 	mov    -0x3fed7a20(,%eax,4),%eax
c010220e:	0f b7 d0             	movzwl %ax,%edx
c0102211:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102214:	66 89 14 c5 80 b7 12 	mov    %dx,-0x3fed4880(,%eax,8)
c010221b:	c0 
c010221c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010221f:	66 c7 04 c5 82 b7 12 	movw   $0x8,-0x3fed487e(,%eax,8)
c0102226:	c0 08 00 
c0102229:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010222c:	0f b6 14 c5 84 b7 12 	movzbl -0x3fed487c(,%eax,8),%edx
c0102233:	c0 
c0102234:	80 e2 e0             	and    $0xe0,%dl
c0102237:	88 14 c5 84 b7 12 c0 	mov    %dl,-0x3fed487c(,%eax,8)
c010223e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102241:	0f b6 14 c5 84 b7 12 	movzbl -0x3fed487c(,%eax,8),%edx
c0102248:	c0 
c0102249:	80 e2 1f             	and    $0x1f,%dl
c010224c:	88 14 c5 84 b7 12 c0 	mov    %dl,-0x3fed487c(,%eax,8)
c0102253:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102256:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c010225d:	c0 
c010225e:	80 e2 f0             	and    $0xf0,%dl
c0102261:	80 ca 0e             	or     $0xe,%dl
c0102264:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c010226b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010226e:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c0102275:	c0 
c0102276:	80 e2 ef             	and    $0xef,%dl
c0102279:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c0102280:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102283:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c010228a:	c0 
c010228b:	80 e2 9f             	and    $0x9f,%dl
c010228e:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c0102295:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102298:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c010229f:	c0 
c01022a0:	80 ca 80             	or     $0x80,%dl
c01022a3:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c01022aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ad:	8b 04 85 e0 85 12 c0 	mov    -0x3fed7a20(,%eax,4),%eax
c01022b4:	c1 e8 10             	shr    $0x10,%eax
c01022b7:	0f b7 d0             	movzwl %ax,%edx
c01022ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022bd:	66 89 14 c5 86 b7 12 	mov    %dx,-0x3fed487a(,%eax,8)
c01022c4:	c0 
     for(i=0;i<256;i++)
c01022c5:	ff 45 fc             	incl   -0x4(%ebp)
c01022c8:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01022cf:	0f 8e 2f ff ff ff    	jle    c0102204 <idt_init+0x12>
     }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], 3);
c01022d5:	a1 c4 87 12 c0       	mov    0xc01287c4,%eax
c01022da:	0f b7 c0             	movzwl %ax,%eax
c01022dd:	66 a3 48 bb 12 c0    	mov    %ax,0xc012bb48
c01022e3:	66 c7 05 4a bb 12 c0 	movw   $0x8,0xc012bb4a
c01022ea:	08 00 
c01022ec:	0f b6 05 4c bb 12 c0 	movzbl 0xc012bb4c,%eax
c01022f3:	24 e0                	and    $0xe0,%al
c01022f5:	a2 4c bb 12 c0       	mov    %al,0xc012bb4c
c01022fa:	0f b6 05 4c bb 12 c0 	movzbl 0xc012bb4c,%eax
c0102301:	24 1f                	and    $0x1f,%al
c0102303:	a2 4c bb 12 c0       	mov    %al,0xc012bb4c
c0102308:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010230f:	24 f0                	and    $0xf0,%al
c0102311:	0c 0e                	or     $0xe,%al
c0102313:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102318:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010231f:	24 ef                	and    $0xef,%al
c0102321:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102326:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010232d:	0c 60                	or     $0x60,%al
c010232f:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102334:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010233b:	0c 80                	or     $0x80,%al
c010233d:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102342:	a1 c4 87 12 c0       	mov    0xc01287c4,%eax
c0102347:	c1 e8 10             	shr    $0x10,%eax
c010234a:	0f b7 c0             	movzwl %ax,%eax
c010234d:	66 a3 4e bb 12 c0    	mov    %ax,0xc012bb4e
c0102353:	c7 45 f8 60 85 12 c0 	movl   $0xc0128560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010235a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010235d:	0f 01 18             	lidtl  (%eax)
}
c0102360:	90                   	nop





}
c0102361:	90                   	nop
c0102362:	89 ec                	mov    %ebp,%esp
c0102364:	5d                   	pop    %ebp
c0102365:	c3                   	ret    

c0102366 <trapname>:

static const char *
trapname(int trapno) {
c0102366:	55                   	push   %ebp
c0102367:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102369:	8b 45 08             	mov    0x8(%ebp),%eax
c010236c:	83 f8 13             	cmp    $0x13,%eax
c010236f:	77 0c                	ja     c010237d <trapname+0x17>
        return excnames[trapno];
c0102371:	8b 45 08             	mov    0x8(%ebp),%eax
c0102374:	8b 04 85 e0 a9 10 c0 	mov    -0x3fef5620(,%eax,4),%eax
c010237b:	eb 18                	jmp    c0102395 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010237d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102381:	7e 0d                	jle    c0102390 <trapname+0x2a>
c0102383:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102387:	7f 07                	jg     c0102390 <trapname+0x2a>
        return "Hardware Interrupt";
c0102389:	b8 9f a5 10 c0       	mov    $0xc010a59f,%eax
c010238e:	eb 05                	jmp    c0102395 <trapname+0x2f>
    }
    return "(unknown trap)";
c0102390:	b8 b2 a5 10 c0       	mov    $0xc010a5b2,%eax
}
c0102395:	5d                   	pop    %ebp
c0102396:	c3                   	ret    

c0102397 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102397:	55                   	push   %ebp
c0102398:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010239a:	8b 45 08             	mov    0x8(%ebp),%eax
c010239d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023a1:	83 f8 08             	cmp    $0x8,%eax
c01023a4:	0f 94 c0             	sete   %al
c01023a7:	0f b6 c0             	movzbl %al,%eax
}
c01023aa:	5d                   	pop    %ebp
c01023ab:	c3                   	ret    

c01023ac <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023ac:	55                   	push   %ebp
c01023ad:	89 e5                	mov    %esp,%ebp
c01023af:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b9:	c7 04 24 f3 a5 10 c0 	movl   $0xc010a5f3,(%esp)
c01023c0:	e8 a8 df ff ff       	call   c010036d <cprintf>
    print_regs(&tf->tf_regs);
c01023c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c8:	89 04 24             	mov    %eax,(%esp)
c01023cb:	e8 8f 01 00 00       	call   c010255f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023db:	c7 04 24 04 a6 10 c0 	movl   $0xc010a604,(%esp)
c01023e2:	e8 86 df ff ff       	call   c010036d <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ea:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f2:	c7 04 24 17 a6 10 c0 	movl   $0xc010a617,(%esp)
c01023f9:	e8 6f df ff ff       	call   c010036d <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01023fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102401:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102405:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102409:	c7 04 24 2a a6 10 c0 	movl   $0xc010a62a,(%esp)
c0102410:	e8 58 df ff ff       	call   c010036d <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102415:	8b 45 08             	mov    0x8(%ebp),%eax
c0102418:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010241c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102420:	c7 04 24 3d a6 10 c0 	movl   $0xc010a63d,(%esp)
c0102427:	e8 41 df ff ff       	call   c010036d <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010242c:	8b 45 08             	mov    0x8(%ebp),%eax
c010242f:	8b 40 30             	mov    0x30(%eax),%eax
c0102432:	89 04 24             	mov    %eax,(%esp)
c0102435:	e8 2c ff ff ff       	call   c0102366 <trapname>
c010243a:	8b 55 08             	mov    0x8(%ebp),%edx
c010243d:	8b 52 30             	mov    0x30(%edx),%edx
c0102440:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102444:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102448:	c7 04 24 50 a6 10 c0 	movl   $0xc010a650,(%esp)
c010244f:	e8 19 df ff ff       	call   c010036d <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102454:	8b 45 08             	mov    0x8(%ebp),%eax
c0102457:	8b 40 34             	mov    0x34(%eax),%eax
c010245a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010245e:	c7 04 24 62 a6 10 c0 	movl   $0xc010a662,(%esp)
c0102465:	e8 03 df ff ff       	call   c010036d <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010246a:	8b 45 08             	mov    0x8(%ebp),%eax
c010246d:	8b 40 38             	mov    0x38(%eax),%eax
c0102470:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102474:	c7 04 24 71 a6 10 c0 	movl   $0xc010a671,(%esp)
c010247b:	e8 ed de ff ff       	call   c010036d <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102480:	8b 45 08             	mov    0x8(%ebp),%eax
c0102483:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102487:	89 44 24 04          	mov    %eax,0x4(%esp)
c010248b:	c7 04 24 80 a6 10 c0 	movl   $0xc010a680,(%esp)
c0102492:	e8 d6 de ff ff       	call   c010036d <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102497:	8b 45 08             	mov    0x8(%ebp),%eax
c010249a:	8b 40 40             	mov    0x40(%eax),%eax
c010249d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024a1:	c7 04 24 93 a6 10 c0 	movl   $0xc010a693,(%esp)
c01024a8:	e8 c0 de ff ff       	call   c010036d <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01024b4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01024bb:	eb 3d                	jmp    c01024fa <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01024bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c0:	8b 50 40             	mov    0x40(%eax),%edx
c01024c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01024c6:	21 d0                	and    %edx,%eax
c01024c8:	85 c0                	test   %eax,%eax
c01024ca:	74 28                	je     c01024f4 <print_trapframe+0x148>
c01024cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024cf:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c01024d6:	85 c0                	test   %eax,%eax
c01024d8:	74 1a                	je     c01024f4 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c01024da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024dd:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c01024e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e8:	c7 04 24 a2 a6 10 c0 	movl   $0xc010a6a2,(%esp)
c01024ef:	e8 79 de ff ff       	call   c010036d <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024f4:	ff 45 f4             	incl   -0xc(%ebp)
c01024f7:	d1 65 f0             	shll   -0x10(%ebp)
c01024fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024fd:	83 f8 17             	cmp    $0x17,%eax
c0102500:	76 bb                	jbe    c01024bd <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102502:	8b 45 08             	mov    0x8(%ebp),%eax
c0102505:	8b 40 40             	mov    0x40(%eax),%eax
c0102508:	c1 e8 0c             	shr    $0xc,%eax
c010250b:	83 e0 03             	and    $0x3,%eax
c010250e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102512:	c7 04 24 a6 a6 10 c0 	movl   $0xc010a6a6,(%esp)
c0102519:	e8 4f de ff ff       	call   c010036d <cprintf>

    if (!trap_in_kernel(tf)) {
c010251e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102521:	89 04 24             	mov    %eax,(%esp)
c0102524:	e8 6e fe ff ff       	call   c0102397 <trap_in_kernel>
c0102529:	85 c0                	test   %eax,%eax
c010252b:	75 2d                	jne    c010255a <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010252d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102530:	8b 40 44             	mov    0x44(%eax),%eax
c0102533:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102537:	c7 04 24 af a6 10 c0 	movl   $0xc010a6af,(%esp)
c010253e:	e8 2a de ff ff       	call   c010036d <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102543:	8b 45 08             	mov    0x8(%ebp),%eax
c0102546:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010254a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010254e:	c7 04 24 be a6 10 c0 	movl   $0xc010a6be,(%esp)
c0102555:	e8 13 de ff ff       	call   c010036d <cprintf>
    }
}
c010255a:	90                   	nop
c010255b:	89 ec                	mov    %ebp,%esp
c010255d:	5d                   	pop    %ebp
c010255e:	c3                   	ret    

c010255f <print_regs>:

void
print_regs(struct pushregs *regs) {
c010255f:	55                   	push   %ebp
c0102560:	89 e5                	mov    %esp,%ebp
c0102562:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102565:	8b 45 08             	mov    0x8(%ebp),%eax
c0102568:	8b 00                	mov    (%eax),%eax
c010256a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010256e:	c7 04 24 d1 a6 10 c0 	movl   $0xc010a6d1,(%esp)
c0102575:	e8 f3 dd ff ff       	call   c010036d <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010257a:	8b 45 08             	mov    0x8(%ebp),%eax
c010257d:	8b 40 04             	mov    0x4(%eax),%eax
c0102580:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102584:	c7 04 24 e0 a6 10 c0 	movl   $0xc010a6e0,(%esp)
c010258b:	e8 dd dd ff ff       	call   c010036d <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102590:	8b 45 08             	mov    0x8(%ebp),%eax
c0102593:	8b 40 08             	mov    0x8(%eax),%eax
c0102596:	89 44 24 04          	mov    %eax,0x4(%esp)
c010259a:	c7 04 24 ef a6 10 c0 	movl   $0xc010a6ef,(%esp)
c01025a1:	e8 c7 dd ff ff       	call   c010036d <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a9:	8b 40 0c             	mov    0xc(%eax),%eax
c01025ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025b0:	c7 04 24 fe a6 10 c0 	movl   $0xc010a6fe,(%esp)
c01025b7:	e8 b1 dd ff ff       	call   c010036d <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01025bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01025bf:	8b 40 10             	mov    0x10(%eax),%eax
c01025c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c6:	c7 04 24 0d a7 10 c0 	movl   $0xc010a70d,(%esp)
c01025cd:	e8 9b dd ff ff       	call   c010036d <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01025d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d5:	8b 40 14             	mov    0x14(%eax),%eax
c01025d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025dc:	c7 04 24 1c a7 10 c0 	movl   $0xc010a71c,(%esp)
c01025e3:	e8 85 dd ff ff       	call   c010036d <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01025e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01025eb:	8b 40 18             	mov    0x18(%eax),%eax
c01025ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025f2:	c7 04 24 2b a7 10 c0 	movl   $0xc010a72b,(%esp)
c01025f9:	e8 6f dd ff ff       	call   c010036d <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01025fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102601:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102604:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102608:	c7 04 24 3a a7 10 c0 	movl   $0xc010a73a,(%esp)
c010260f:	e8 59 dd ff ff       	call   c010036d <cprintf>
}
c0102614:	90                   	nop
c0102615:	89 ec                	mov    %ebp,%esp
c0102617:	5d                   	pop    %ebp
c0102618:	c3                   	ret    

c0102619 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102619:	55                   	push   %ebp
c010261a:	89 e5                	mov    %esp,%ebp
c010261c:	83 ec 38             	sub    $0x38,%esp
c010261f:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102622:	8b 45 08             	mov    0x8(%ebp),%eax
c0102625:	8b 40 34             	mov    0x34(%eax),%eax
c0102628:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010262b:	85 c0                	test   %eax,%eax
c010262d:	74 07                	je     c0102636 <print_pgfault+0x1d>
c010262f:	bb 49 a7 10 c0       	mov    $0xc010a749,%ebx
c0102634:	eb 05                	jmp    c010263b <print_pgfault+0x22>
c0102636:	bb 5a a7 10 c0       	mov    $0xc010a75a,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010263b:	8b 45 08             	mov    0x8(%ebp),%eax
c010263e:	8b 40 34             	mov    0x34(%eax),%eax
c0102641:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102644:	85 c0                	test   %eax,%eax
c0102646:	74 07                	je     c010264f <print_pgfault+0x36>
c0102648:	b9 57 00 00 00       	mov    $0x57,%ecx
c010264d:	eb 05                	jmp    c0102654 <print_pgfault+0x3b>
c010264f:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102654:	8b 45 08             	mov    0x8(%ebp),%eax
c0102657:	8b 40 34             	mov    0x34(%eax),%eax
c010265a:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010265d:	85 c0                	test   %eax,%eax
c010265f:	74 07                	je     c0102668 <print_pgfault+0x4f>
c0102661:	ba 55 00 00 00       	mov    $0x55,%edx
c0102666:	eb 05                	jmp    c010266d <print_pgfault+0x54>
c0102668:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010266d:	0f 20 d0             	mov    %cr2,%eax
c0102670:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102676:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010267a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010267e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102682:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102686:	c7 04 24 68 a7 10 c0 	movl   $0xc010a768,(%esp)
c010268d:	e8 db dc ff ff       	call   c010036d <cprintf>
}
c0102692:	90                   	nop
c0102693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102696:	89 ec                	mov    %ebp,%esp
c0102698:	5d                   	pop    %ebp
c0102699:	c3                   	ret    

c010269a <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010269a:	55                   	push   %ebp
c010269b:	89 e5                	mov    %esp,%ebp
c010269d:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01026a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01026a3:	89 04 24             	mov    %eax,(%esp)
c01026a6:	e8 6e ff ff ff       	call   c0102619 <print_pgfault>
    if (check_mm_struct != NULL) {
c01026ab:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01026b0:	85 c0                	test   %eax,%eax
c01026b2:	74 26                	je     c01026da <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026b4:	0f 20 d0             	mov    %cr2,%eax
c01026b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01026ba:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01026bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01026c0:	8b 50 34             	mov    0x34(%eax),%edx
c01026c3:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01026cc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01026d0:	89 04 24             	mov    %eax,(%esp)
c01026d3:	e8 f7 5d 00 00       	call   c01084cf <do_pgfault>
c01026d8:	eb 1c                	jmp    c01026f6 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c01026da:	c7 44 24 08 8b a7 10 	movl   $0xc010a78b,0x8(%esp)
c01026e1:	c0 
c01026e2:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
c01026e9:	00 
c01026ea:	c7 04 24 8e a5 10 c0 	movl   $0xc010a58e,(%esp)
c01026f1:	e8 20 e6 ff ff       	call   c0100d16 <__panic>
}
c01026f6:	89 ec                	mov    %ebp,%esp
c01026f8:	5d                   	pop    %ebp
c01026f9:	c3                   	ret    

c01026fa <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01026fa:	55                   	push   %ebp
c01026fb:	89 e5                	mov    %esp,%ebp
c01026fd:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102700:	8b 45 08             	mov    0x8(%ebp),%eax
c0102703:	8b 40 30             	mov    0x30(%eax),%eax
c0102706:	83 f8 2f             	cmp    $0x2f,%eax
c0102709:	77 1e                	ja     c0102729 <trap_dispatch+0x2f>
c010270b:	83 f8 0e             	cmp    $0xe,%eax
c010270e:	0f 82 1a 01 00 00    	jb     c010282e <trap_dispatch+0x134>
c0102714:	83 e8 0e             	sub    $0xe,%eax
c0102717:	83 f8 21             	cmp    $0x21,%eax
c010271a:	0f 87 0e 01 00 00    	ja     c010282e <trap_dispatch+0x134>
c0102720:	8b 04 85 0c a8 10 c0 	mov    -0x3fef57f4(,%eax,4),%eax
c0102727:	ff e0                	jmp    *%eax
c0102729:	83 e8 78             	sub    $0x78,%eax
c010272c:	83 f8 01             	cmp    $0x1,%eax
c010272f:	0f 87 f9 00 00 00    	ja     c010282e <trap_dispatch+0x134>
c0102735:	e9 d8 00 00 00       	jmp    c0102812 <trap_dispatch+0x118>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010273a:	8b 45 08             	mov    0x8(%ebp),%eax
c010273d:	89 04 24             	mov    %eax,(%esp)
c0102740:	e8 55 ff ff ff       	call   c010269a <pgfault_handler>
c0102745:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102748:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010274c:	0f 84 14 01 00 00    	je     c0102866 <trap_dispatch+0x16c>
            print_trapframe(tf);
c0102752:	8b 45 08             	mov    0x8(%ebp),%eax
c0102755:	89 04 24             	mov    %eax,(%esp)
c0102758:	e8 4f fc ff ff       	call   c01023ac <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c010275d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102760:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102764:	c7 44 24 08 a2 a7 10 	movl   $0xc010a7a2,0x8(%esp)
c010276b:	c0 
c010276c:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0102773:	00 
c0102774:	c7 04 24 8e a5 10 c0 	movl   $0xc010a58e,(%esp)
c010277b:	e8 96 e5 ff ff       	call   c0100d16 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    ticks+=1;
c0102780:	a1 24 b4 12 c0       	mov    0xc012b424,%eax
c0102785:	40                   	inc    %eax
c0102786:	a3 24 b4 12 c0       	mov    %eax,0xc012b424
        if (ticks % TICK_NUM == 0) {
c010278b:	8b 0d 24 b4 12 c0    	mov    0xc012b424,%ecx
c0102791:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102796:	89 c8                	mov    %ecx,%eax
c0102798:	f7 e2                	mul    %edx
c010279a:	c1 ea 05             	shr    $0x5,%edx
c010279d:	89 d0                	mov    %edx,%eax
c010279f:	c1 e0 02             	shl    $0x2,%eax
c01027a2:	01 d0                	add    %edx,%eax
c01027a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01027ab:	01 d0                	add    %edx,%eax
c01027ad:	c1 e0 02             	shl    $0x2,%eax
c01027b0:	29 c1                	sub    %eax,%ecx
c01027b2:	89 ca                	mov    %ecx,%edx
c01027b4:	85 d2                	test   %edx,%edx
c01027b6:	0f 85 ad 00 00 00    	jne    c0102869 <trap_dispatch+0x16f>
            print_ticks();
c01027bc:	e8 ef f9 ff ff       	call   c01021b0 <print_ticks>
        }
        break;
c01027c1:	e9 a3 00 00 00       	jmp    c0102869 <trap_dispatch+0x16f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01027c6:	e8 2b ef ff ff       	call   c01016f6 <cons_getc>
c01027cb:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01027ce:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027d2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027de:	c7 04 24 bd a7 10 c0 	movl   $0xc010a7bd,(%esp)
c01027e5:	e8 83 db ff ff       	call   c010036d <cprintf>
        break;
c01027ea:	eb 7e                	jmp    c010286a <trap_dispatch+0x170>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01027ec:	e8 05 ef ff ff       	call   c01016f6 <cons_getc>
c01027f1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01027f4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027f8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027fc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102800:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102804:	c7 04 24 cf a7 10 c0 	movl   $0xc010a7cf,(%esp)
c010280b:	e8 5d db ff ff       	call   c010036d <cprintf>
        break;
c0102810:	eb 58                	jmp    c010286a <trap_dispatch+0x170>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102812:	c7 44 24 08 de a7 10 	movl   $0xc010a7de,0x8(%esp)
c0102819:	c0 
c010281a:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0102821:	00 
c0102822:	c7 04 24 8e a5 10 c0 	movl   $0xc010a58e,(%esp)
c0102829:	e8 e8 e4 ff ff       	call   c0100d16 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c010282e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102831:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102835:	83 e0 03             	and    $0x3,%eax
c0102838:	85 c0                	test   %eax,%eax
c010283a:	75 2e                	jne    c010286a <trap_dispatch+0x170>
            print_trapframe(tf);
c010283c:	8b 45 08             	mov    0x8(%ebp),%eax
c010283f:	89 04 24             	mov    %eax,(%esp)
c0102842:	e8 65 fb ff ff       	call   c01023ac <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102847:	c7 44 24 08 ee a7 10 	movl   $0xc010a7ee,0x8(%esp)
c010284e:	c0 
c010284f:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0102856:	00 
c0102857:	c7 04 24 8e a5 10 c0 	movl   $0xc010a58e,(%esp)
c010285e:	e8 b3 e4 ff ff       	call   c0100d16 <__panic>
        break;
c0102863:	90                   	nop
c0102864:	eb 04                	jmp    c010286a <trap_dispatch+0x170>
        break;
c0102866:	90                   	nop
c0102867:	eb 01                	jmp    c010286a <trap_dispatch+0x170>
        break;
c0102869:	90                   	nop
        }
    }
}
c010286a:	90                   	nop
c010286b:	89 ec                	mov    %ebp,%esp
c010286d:	5d                   	pop    %ebp
c010286e:	c3                   	ret    

c010286f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c010286f:	55                   	push   %ebp
c0102870:	89 e5                	mov    %esp,%ebp
c0102872:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102875:	8b 45 08             	mov    0x8(%ebp),%eax
c0102878:	89 04 24             	mov    %eax,(%esp)
c010287b:	e8 7a fe ff ff       	call   c01026fa <trap_dispatch>
}
c0102880:	90                   	nop
c0102881:	89 ec                	mov    %ebp,%esp
c0102883:	5d                   	pop    %ebp
c0102884:	c3                   	ret    

c0102885 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102885:	1e                   	push   %ds
    pushl %es
c0102886:	06                   	push   %es
    pushl %fs
c0102887:	0f a0                	push   %fs
    pushl %gs
c0102889:	0f a8                	push   %gs
    pushal
c010288b:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010288c:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102891:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102893:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102895:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102896:	e8 d4 ff ff ff       	call   c010286f <trap>

    # pop the pushed stack pointer
    popl %esp
c010289b:	5c                   	pop    %esp

c010289c <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010289c:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010289d:	0f a9                	pop    %gs
    popl %fs
c010289f:	0f a1                	pop    %fs
    popl %es
c01028a1:	07                   	pop    %es
    popl %ds
c01028a2:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01028a3:	83 c4 08             	add    $0x8,%esp
    iret
c01028a6:	cf                   	iret   

c01028a7 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c01028a7:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01028ab:	eb ef                	jmp    c010289c <__trapret>

c01028ad <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $0
c01028af:	6a 00                	push   $0x0
  jmp __alltraps
c01028b1:	e9 cf ff ff ff       	jmp    c0102885 <__alltraps>

c01028b6 <vector1>:
.globl vector1
vector1:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $1
c01028b8:	6a 01                	push   $0x1
  jmp __alltraps
c01028ba:	e9 c6 ff ff ff       	jmp    c0102885 <__alltraps>

c01028bf <vector2>:
.globl vector2
vector2:
  pushl $0
c01028bf:	6a 00                	push   $0x0
  pushl $2
c01028c1:	6a 02                	push   $0x2
  jmp __alltraps
c01028c3:	e9 bd ff ff ff       	jmp    c0102885 <__alltraps>

c01028c8 <vector3>:
.globl vector3
vector3:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $3
c01028ca:	6a 03                	push   $0x3
  jmp __alltraps
c01028cc:	e9 b4 ff ff ff       	jmp    c0102885 <__alltraps>

c01028d1 <vector4>:
.globl vector4
vector4:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $4
c01028d3:	6a 04                	push   $0x4
  jmp __alltraps
c01028d5:	e9 ab ff ff ff       	jmp    c0102885 <__alltraps>

c01028da <vector5>:
.globl vector5
vector5:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $5
c01028dc:	6a 05                	push   $0x5
  jmp __alltraps
c01028de:	e9 a2 ff ff ff       	jmp    c0102885 <__alltraps>

c01028e3 <vector6>:
.globl vector6
vector6:
  pushl $0
c01028e3:	6a 00                	push   $0x0
  pushl $6
c01028e5:	6a 06                	push   $0x6
  jmp __alltraps
c01028e7:	e9 99 ff ff ff       	jmp    c0102885 <__alltraps>

c01028ec <vector7>:
.globl vector7
vector7:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $7
c01028ee:	6a 07                	push   $0x7
  jmp __alltraps
c01028f0:	e9 90 ff ff ff       	jmp    c0102885 <__alltraps>

c01028f5 <vector8>:
.globl vector8
vector8:
  pushl $8
c01028f5:	6a 08                	push   $0x8
  jmp __alltraps
c01028f7:	e9 89 ff ff ff       	jmp    c0102885 <__alltraps>

c01028fc <vector9>:
.globl vector9
vector9:
  pushl $0
c01028fc:	6a 00                	push   $0x0
  pushl $9
c01028fe:	6a 09                	push   $0x9
  jmp __alltraps
c0102900:	e9 80 ff ff ff       	jmp    c0102885 <__alltraps>

c0102905 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102905:	6a 0a                	push   $0xa
  jmp __alltraps
c0102907:	e9 79 ff ff ff       	jmp    c0102885 <__alltraps>

c010290c <vector11>:
.globl vector11
vector11:
  pushl $11
c010290c:	6a 0b                	push   $0xb
  jmp __alltraps
c010290e:	e9 72 ff ff ff       	jmp    c0102885 <__alltraps>

c0102913 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102913:	6a 0c                	push   $0xc
  jmp __alltraps
c0102915:	e9 6b ff ff ff       	jmp    c0102885 <__alltraps>

c010291a <vector13>:
.globl vector13
vector13:
  pushl $13
c010291a:	6a 0d                	push   $0xd
  jmp __alltraps
c010291c:	e9 64 ff ff ff       	jmp    c0102885 <__alltraps>

c0102921 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102921:	6a 0e                	push   $0xe
  jmp __alltraps
c0102923:	e9 5d ff ff ff       	jmp    c0102885 <__alltraps>

c0102928 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102928:	6a 00                	push   $0x0
  pushl $15
c010292a:	6a 0f                	push   $0xf
  jmp __alltraps
c010292c:	e9 54 ff ff ff       	jmp    c0102885 <__alltraps>

c0102931 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102931:	6a 00                	push   $0x0
  pushl $16
c0102933:	6a 10                	push   $0x10
  jmp __alltraps
c0102935:	e9 4b ff ff ff       	jmp    c0102885 <__alltraps>

c010293a <vector17>:
.globl vector17
vector17:
  pushl $17
c010293a:	6a 11                	push   $0x11
  jmp __alltraps
c010293c:	e9 44 ff ff ff       	jmp    c0102885 <__alltraps>

c0102941 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102941:	6a 00                	push   $0x0
  pushl $18
c0102943:	6a 12                	push   $0x12
  jmp __alltraps
c0102945:	e9 3b ff ff ff       	jmp    c0102885 <__alltraps>

c010294a <vector19>:
.globl vector19
vector19:
  pushl $0
c010294a:	6a 00                	push   $0x0
  pushl $19
c010294c:	6a 13                	push   $0x13
  jmp __alltraps
c010294e:	e9 32 ff ff ff       	jmp    c0102885 <__alltraps>

c0102953 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102953:	6a 00                	push   $0x0
  pushl $20
c0102955:	6a 14                	push   $0x14
  jmp __alltraps
c0102957:	e9 29 ff ff ff       	jmp    c0102885 <__alltraps>

c010295c <vector21>:
.globl vector21
vector21:
  pushl $0
c010295c:	6a 00                	push   $0x0
  pushl $21
c010295e:	6a 15                	push   $0x15
  jmp __alltraps
c0102960:	e9 20 ff ff ff       	jmp    c0102885 <__alltraps>

c0102965 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102965:	6a 00                	push   $0x0
  pushl $22
c0102967:	6a 16                	push   $0x16
  jmp __alltraps
c0102969:	e9 17 ff ff ff       	jmp    c0102885 <__alltraps>

c010296e <vector23>:
.globl vector23
vector23:
  pushl $0
c010296e:	6a 00                	push   $0x0
  pushl $23
c0102970:	6a 17                	push   $0x17
  jmp __alltraps
c0102972:	e9 0e ff ff ff       	jmp    c0102885 <__alltraps>

c0102977 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102977:	6a 00                	push   $0x0
  pushl $24
c0102979:	6a 18                	push   $0x18
  jmp __alltraps
c010297b:	e9 05 ff ff ff       	jmp    c0102885 <__alltraps>

c0102980 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102980:	6a 00                	push   $0x0
  pushl $25
c0102982:	6a 19                	push   $0x19
  jmp __alltraps
c0102984:	e9 fc fe ff ff       	jmp    c0102885 <__alltraps>

c0102989 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102989:	6a 00                	push   $0x0
  pushl $26
c010298b:	6a 1a                	push   $0x1a
  jmp __alltraps
c010298d:	e9 f3 fe ff ff       	jmp    c0102885 <__alltraps>

c0102992 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $27
c0102994:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102996:	e9 ea fe ff ff       	jmp    c0102885 <__alltraps>

c010299b <vector28>:
.globl vector28
vector28:
  pushl $0
c010299b:	6a 00                	push   $0x0
  pushl $28
c010299d:	6a 1c                	push   $0x1c
  jmp __alltraps
c010299f:	e9 e1 fe ff ff       	jmp    c0102885 <__alltraps>

c01029a4 <vector29>:
.globl vector29
vector29:
  pushl $0
c01029a4:	6a 00                	push   $0x0
  pushl $29
c01029a6:	6a 1d                	push   $0x1d
  jmp __alltraps
c01029a8:	e9 d8 fe ff ff       	jmp    c0102885 <__alltraps>

c01029ad <vector30>:
.globl vector30
vector30:
  pushl $0
c01029ad:	6a 00                	push   $0x0
  pushl $30
c01029af:	6a 1e                	push   $0x1e
  jmp __alltraps
c01029b1:	e9 cf fe ff ff       	jmp    c0102885 <__alltraps>

c01029b6 <vector31>:
.globl vector31
vector31:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $31
c01029b8:	6a 1f                	push   $0x1f
  jmp __alltraps
c01029ba:	e9 c6 fe ff ff       	jmp    c0102885 <__alltraps>

c01029bf <vector32>:
.globl vector32
vector32:
  pushl $0
c01029bf:	6a 00                	push   $0x0
  pushl $32
c01029c1:	6a 20                	push   $0x20
  jmp __alltraps
c01029c3:	e9 bd fe ff ff       	jmp    c0102885 <__alltraps>

c01029c8 <vector33>:
.globl vector33
vector33:
  pushl $0
c01029c8:	6a 00                	push   $0x0
  pushl $33
c01029ca:	6a 21                	push   $0x21
  jmp __alltraps
c01029cc:	e9 b4 fe ff ff       	jmp    c0102885 <__alltraps>

c01029d1 <vector34>:
.globl vector34
vector34:
  pushl $0
c01029d1:	6a 00                	push   $0x0
  pushl $34
c01029d3:	6a 22                	push   $0x22
  jmp __alltraps
c01029d5:	e9 ab fe ff ff       	jmp    c0102885 <__alltraps>

c01029da <vector35>:
.globl vector35
vector35:
  pushl $0
c01029da:	6a 00                	push   $0x0
  pushl $35
c01029dc:	6a 23                	push   $0x23
  jmp __alltraps
c01029de:	e9 a2 fe ff ff       	jmp    c0102885 <__alltraps>

c01029e3 <vector36>:
.globl vector36
vector36:
  pushl $0
c01029e3:	6a 00                	push   $0x0
  pushl $36
c01029e5:	6a 24                	push   $0x24
  jmp __alltraps
c01029e7:	e9 99 fe ff ff       	jmp    c0102885 <__alltraps>

c01029ec <vector37>:
.globl vector37
vector37:
  pushl $0
c01029ec:	6a 00                	push   $0x0
  pushl $37
c01029ee:	6a 25                	push   $0x25
  jmp __alltraps
c01029f0:	e9 90 fe ff ff       	jmp    c0102885 <__alltraps>

c01029f5 <vector38>:
.globl vector38
vector38:
  pushl $0
c01029f5:	6a 00                	push   $0x0
  pushl $38
c01029f7:	6a 26                	push   $0x26
  jmp __alltraps
c01029f9:	e9 87 fe ff ff       	jmp    c0102885 <__alltraps>

c01029fe <vector39>:
.globl vector39
vector39:
  pushl $0
c01029fe:	6a 00                	push   $0x0
  pushl $39
c0102a00:	6a 27                	push   $0x27
  jmp __alltraps
c0102a02:	e9 7e fe ff ff       	jmp    c0102885 <__alltraps>

c0102a07 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102a07:	6a 00                	push   $0x0
  pushl $40
c0102a09:	6a 28                	push   $0x28
  jmp __alltraps
c0102a0b:	e9 75 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a10 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102a10:	6a 00                	push   $0x0
  pushl $41
c0102a12:	6a 29                	push   $0x29
  jmp __alltraps
c0102a14:	e9 6c fe ff ff       	jmp    c0102885 <__alltraps>

c0102a19 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102a19:	6a 00                	push   $0x0
  pushl $42
c0102a1b:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102a1d:	e9 63 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a22 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102a22:	6a 00                	push   $0x0
  pushl $43
c0102a24:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102a26:	e9 5a fe ff ff       	jmp    c0102885 <__alltraps>

c0102a2b <vector44>:
.globl vector44
vector44:
  pushl $0
c0102a2b:	6a 00                	push   $0x0
  pushl $44
c0102a2d:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102a2f:	e9 51 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a34 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102a34:	6a 00                	push   $0x0
  pushl $45
c0102a36:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102a38:	e9 48 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a3d <vector46>:
.globl vector46
vector46:
  pushl $0
c0102a3d:	6a 00                	push   $0x0
  pushl $46
c0102a3f:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102a41:	e9 3f fe ff ff       	jmp    c0102885 <__alltraps>

c0102a46 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102a46:	6a 00                	push   $0x0
  pushl $47
c0102a48:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102a4a:	e9 36 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a4f <vector48>:
.globl vector48
vector48:
  pushl $0
c0102a4f:	6a 00                	push   $0x0
  pushl $48
c0102a51:	6a 30                	push   $0x30
  jmp __alltraps
c0102a53:	e9 2d fe ff ff       	jmp    c0102885 <__alltraps>

c0102a58 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102a58:	6a 00                	push   $0x0
  pushl $49
c0102a5a:	6a 31                	push   $0x31
  jmp __alltraps
c0102a5c:	e9 24 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a61 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102a61:	6a 00                	push   $0x0
  pushl $50
c0102a63:	6a 32                	push   $0x32
  jmp __alltraps
c0102a65:	e9 1b fe ff ff       	jmp    c0102885 <__alltraps>

c0102a6a <vector51>:
.globl vector51
vector51:
  pushl $0
c0102a6a:	6a 00                	push   $0x0
  pushl $51
c0102a6c:	6a 33                	push   $0x33
  jmp __alltraps
c0102a6e:	e9 12 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a73 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102a73:	6a 00                	push   $0x0
  pushl $52
c0102a75:	6a 34                	push   $0x34
  jmp __alltraps
c0102a77:	e9 09 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a7c <vector53>:
.globl vector53
vector53:
  pushl $0
c0102a7c:	6a 00                	push   $0x0
  pushl $53
c0102a7e:	6a 35                	push   $0x35
  jmp __alltraps
c0102a80:	e9 00 fe ff ff       	jmp    c0102885 <__alltraps>

c0102a85 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102a85:	6a 00                	push   $0x0
  pushl $54
c0102a87:	6a 36                	push   $0x36
  jmp __alltraps
c0102a89:	e9 f7 fd ff ff       	jmp    c0102885 <__alltraps>

c0102a8e <vector55>:
.globl vector55
vector55:
  pushl $0
c0102a8e:	6a 00                	push   $0x0
  pushl $55
c0102a90:	6a 37                	push   $0x37
  jmp __alltraps
c0102a92:	e9 ee fd ff ff       	jmp    c0102885 <__alltraps>

c0102a97 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102a97:	6a 00                	push   $0x0
  pushl $56
c0102a99:	6a 38                	push   $0x38
  jmp __alltraps
c0102a9b:	e9 e5 fd ff ff       	jmp    c0102885 <__alltraps>

c0102aa0 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102aa0:	6a 00                	push   $0x0
  pushl $57
c0102aa2:	6a 39                	push   $0x39
  jmp __alltraps
c0102aa4:	e9 dc fd ff ff       	jmp    c0102885 <__alltraps>

c0102aa9 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102aa9:	6a 00                	push   $0x0
  pushl $58
c0102aab:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102aad:	e9 d3 fd ff ff       	jmp    c0102885 <__alltraps>

c0102ab2 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102ab2:	6a 00                	push   $0x0
  pushl $59
c0102ab4:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102ab6:	e9 ca fd ff ff       	jmp    c0102885 <__alltraps>

c0102abb <vector60>:
.globl vector60
vector60:
  pushl $0
c0102abb:	6a 00                	push   $0x0
  pushl $60
c0102abd:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102abf:	e9 c1 fd ff ff       	jmp    c0102885 <__alltraps>

c0102ac4 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102ac4:	6a 00                	push   $0x0
  pushl $61
c0102ac6:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102ac8:	e9 b8 fd ff ff       	jmp    c0102885 <__alltraps>

c0102acd <vector62>:
.globl vector62
vector62:
  pushl $0
c0102acd:	6a 00                	push   $0x0
  pushl $62
c0102acf:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102ad1:	e9 af fd ff ff       	jmp    c0102885 <__alltraps>

c0102ad6 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $63
c0102ad8:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102ada:	e9 a6 fd ff ff       	jmp    c0102885 <__alltraps>

c0102adf <vector64>:
.globl vector64
vector64:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $64
c0102ae1:	6a 40                	push   $0x40
  jmp __alltraps
c0102ae3:	e9 9d fd ff ff       	jmp    c0102885 <__alltraps>

c0102ae8 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $65
c0102aea:	6a 41                	push   $0x41
  jmp __alltraps
c0102aec:	e9 94 fd ff ff       	jmp    c0102885 <__alltraps>

c0102af1 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $66
c0102af3:	6a 42                	push   $0x42
  jmp __alltraps
c0102af5:	e9 8b fd ff ff       	jmp    c0102885 <__alltraps>

c0102afa <vector67>:
.globl vector67
vector67:
  pushl $0
c0102afa:	6a 00                	push   $0x0
  pushl $67
c0102afc:	6a 43                	push   $0x43
  jmp __alltraps
c0102afe:	e9 82 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b03 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102b03:	6a 00                	push   $0x0
  pushl $68
c0102b05:	6a 44                	push   $0x44
  jmp __alltraps
c0102b07:	e9 79 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b0c <vector69>:
.globl vector69
vector69:
  pushl $0
c0102b0c:	6a 00                	push   $0x0
  pushl $69
c0102b0e:	6a 45                	push   $0x45
  jmp __alltraps
c0102b10:	e9 70 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b15 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102b15:	6a 00                	push   $0x0
  pushl $70
c0102b17:	6a 46                	push   $0x46
  jmp __alltraps
c0102b19:	e9 67 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b1e <vector71>:
.globl vector71
vector71:
  pushl $0
c0102b1e:	6a 00                	push   $0x0
  pushl $71
c0102b20:	6a 47                	push   $0x47
  jmp __alltraps
c0102b22:	e9 5e fd ff ff       	jmp    c0102885 <__alltraps>

c0102b27 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102b27:	6a 00                	push   $0x0
  pushl $72
c0102b29:	6a 48                	push   $0x48
  jmp __alltraps
c0102b2b:	e9 55 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b30 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102b30:	6a 00                	push   $0x0
  pushl $73
c0102b32:	6a 49                	push   $0x49
  jmp __alltraps
c0102b34:	e9 4c fd ff ff       	jmp    c0102885 <__alltraps>

c0102b39 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102b39:	6a 00                	push   $0x0
  pushl $74
c0102b3b:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102b3d:	e9 43 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b42 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $75
c0102b44:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102b46:	e9 3a fd ff ff       	jmp    c0102885 <__alltraps>

c0102b4b <vector76>:
.globl vector76
vector76:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $76
c0102b4d:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102b4f:	e9 31 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b54 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $77
c0102b56:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102b58:	e9 28 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b5d <vector78>:
.globl vector78
vector78:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $78
c0102b5f:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102b61:	e9 1f fd ff ff       	jmp    c0102885 <__alltraps>

c0102b66 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $79
c0102b68:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102b6a:	e9 16 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b6f <vector80>:
.globl vector80
vector80:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $80
c0102b71:	6a 50                	push   $0x50
  jmp __alltraps
c0102b73:	e9 0d fd ff ff       	jmp    c0102885 <__alltraps>

c0102b78 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $81
c0102b7a:	6a 51                	push   $0x51
  jmp __alltraps
c0102b7c:	e9 04 fd ff ff       	jmp    c0102885 <__alltraps>

c0102b81 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $82
c0102b83:	6a 52                	push   $0x52
  jmp __alltraps
c0102b85:	e9 fb fc ff ff       	jmp    c0102885 <__alltraps>

c0102b8a <vector83>:
.globl vector83
vector83:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $83
c0102b8c:	6a 53                	push   $0x53
  jmp __alltraps
c0102b8e:	e9 f2 fc ff ff       	jmp    c0102885 <__alltraps>

c0102b93 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $84
c0102b95:	6a 54                	push   $0x54
  jmp __alltraps
c0102b97:	e9 e9 fc ff ff       	jmp    c0102885 <__alltraps>

c0102b9c <vector85>:
.globl vector85
vector85:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $85
c0102b9e:	6a 55                	push   $0x55
  jmp __alltraps
c0102ba0:	e9 e0 fc ff ff       	jmp    c0102885 <__alltraps>

c0102ba5 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $86
c0102ba7:	6a 56                	push   $0x56
  jmp __alltraps
c0102ba9:	e9 d7 fc ff ff       	jmp    c0102885 <__alltraps>

c0102bae <vector87>:
.globl vector87
vector87:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $87
c0102bb0:	6a 57                	push   $0x57
  jmp __alltraps
c0102bb2:	e9 ce fc ff ff       	jmp    c0102885 <__alltraps>

c0102bb7 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102bb7:	6a 00                	push   $0x0
  pushl $88
c0102bb9:	6a 58                	push   $0x58
  jmp __alltraps
c0102bbb:	e9 c5 fc ff ff       	jmp    c0102885 <__alltraps>

c0102bc0 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102bc0:	6a 00                	push   $0x0
  pushl $89
c0102bc2:	6a 59                	push   $0x59
  jmp __alltraps
c0102bc4:	e9 bc fc ff ff       	jmp    c0102885 <__alltraps>

c0102bc9 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $90
c0102bcb:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102bcd:	e9 b3 fc ff ff       	jmp    c0102885 <__alltraps>

c0102bd2 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $91
c0102bd4:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102bd6:	e9 aa fc ff ff       	jmp    c0102885 <__alltraps>

c0102bdb <vector92>:
.globl vector92
vector92:
  pushl $0
c0102bdb:	6a 00                	push   $0x0
  pushl $92
c0102bdd:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102bdf:	e9 a1 fc ff ff       	jmp    c0102885 <__alltraps>

c0102be4 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102be4:	6a 00                	push   $0x0
  pushl $93
c0102be6:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102be8:	e9 98 fc ff ff       	jmp    c0102885 <__alltraps>

c0102bed <vector94>:
.globl vector94
vector94:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $94
c0102bef:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102bf1:	e9 8f fc ff ff       	jmp    c0102885 <__alltraps>

c0102bf6 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $95
c0102bf8:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102bfa:	e9 86 fc ff ff       	jmp    c0102885 <__alltraps>

c0102bff <vector96>:
.globl vector96
vector96:
  pushl $0
c0102bff:	6a 00                	push   $0x0
  pushl $96
c0102c01:	6a 60                	push   $0x60
  jmp __alltraps
c0102c03:	e9 7d fc ff ff       	jmp    c0102885 <__alltraps>

c0102c08 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $97
c0102c0a:	6a 61                	push   $0x61
  jmp __alltraps
c0102c0c:	e9 74 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c11 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $98
c0102c13:	6a 62                	push   $0x62
  jmp __alltraps
c0102c15:	e9 6b fc ff ff       	jmp    c0102885 <__alltraps>

c0102c1a <vector99>:
.globl vector99
vector99:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $99
c0102c1c:	6a 63                	push   $0x63
  jmp __alltraps
c0102c1e:	e9 62 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c23 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $100
c0102c25:	6a 64                	push   $0x64
  jmp __alltraps
c0102c27:	e9 59 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c2c <vector101>:
.globl vector101
vector101:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $101
c0102c2e:	6a 65                	push   $0x65
  jmp __alltraps
c0102c30:	e9 50 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c35 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $102
c0102c37:	6a 66                	push   $0x66
  jmp __alltraps
c0102c39:	e9 47 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c3e <vector103>:
.globl vector103
vector103:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $103
c0102c40:	6a 67                	push   $0x67
  jmp __alltraps
c0102c42:	e9 3e fc ff ff       	jmp    c0102885 <__alltraps>

c0102c47 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $104
c0102c49:	6a 68                	push   $0x68
  jmp __alltraps
c0102c4b:	e9 35 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c50 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $105
c0102c52:	6a 69                	push   $0x69
  jmp __alltraps
c0102c54:	e9 2c fc ff ff       	jmp    c0102885 <__alltraps>

c0102c59 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $106
c0102c5b:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102c5d:	e9 23 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c62 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $107
c0102c64:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102c66:	e9 1a fc ff ff       	jmp    c0102885 <__alltraps>

c0102c6b <vector108>:
.globl vector108
vector108:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $108
c0102c6d:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102c6f:	e9 11 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c74 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $109
c0102c76:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102c78:	e9 08 fc ff ff       	jmp    c0102885 <__alltraps>

c0102c7d <vector110>:
.globl vector110
vector110:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $110
c0102c7f:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102c81:	e9 ff fb ff ff       	jmp    c0102885 <__alltraps>

c0102c86 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $111
c0102c88:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102c8a:	e9 f6 fb ff ff       	jmp    c0102885 <__alltraps>

c0102c8f <vector112>:
.globl vector112
vector112:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $112
c0102c91:	6a 70                	push   $0x70
  jmp __alltraps
c0102c93:	e9 ed fb ff ff       	jmp    c0102885 <__alltraps>

c0102c98 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $113
c0102c9a:	6a 71                	push   $0x71
  jmp __alltraps
c0102c9c:	e9 e4 fb ff ff       	jmp    c0102885 <__alltraps>

c0102ca1 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $114
c0102ca3:	6a 72                	push   $0x72
  jmp __alltraps
c0102ca5:	e9 db fb ff ff       	jmp    c0102885 <__alltraps>

c0102caa <vector115>:
.globl vector115
vector115:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $115
c0102cac:	6a 73                	push   $0x73
  jmp __alltraps
c0102cae:	e9 d2 fb ff ff       	jmp    c0102885 <__alltraps>

c0102cb3 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $116
c0102cb5:	6a 74                	push   $0x74
  jmp __alltraps
c0102cb7:	e9 c9 fb ff ff       	jmp    c0102885 <__alltraps>

c0102cbc <vector117>:
.globl vector117
vector117:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $117
c0102cbe:	6a 75                	push   $0x75
  jmp __alltraps
c0102cc0:	e9 c0 fb ff ff       	jmp    c0102885 <__alltraps>

c0102cc5 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $118
c0102cc7:	6a 76                	push   $0x76
  jmp __alltraps
c0102cc9:	e9 b7 fb ff ff       	jmp    c0102885 <__alltraps>

c0102cce <vector119>:
.globl vector119
vector119:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $119
c0102cd0:	6a 77                	push   $0x77
  jmp __alltraps
c0102cd2:	e9 ae fb ff ff       	jmp    c0102885 <__alltraps>

c0102cd7 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $120
c0102cd9:	6a 78                	push   $0x78
  jmp __alltraps
c0102cdb:	e9 a5 fb ff ff       	jmp    c0102885 <__alltraps>

c0102ce0 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $121
c0102ce2:	6a 79                	push   $0x79
  jmp __alltraps
c0102ce4:	e9 9c fb ff ff       	jmp    c0102885 <__alltraps>

c0102ce9 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $122
c0102ceb:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ced:	e9 93 fb ff ff       	jmp    c0102885 <__alltraps>

c0102cf2 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $123
c0102cf4:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102cf6:	e9 8a fb ff ff       	jmp    c0102885 <__alltraps>

c0102cfb <vector124>:
.globl vector124
vector124:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $124
c0102cfd:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102cff:	e9 81 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d04 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $125
c0102d06:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102d08:	e9 78 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d0d <vector126>:
.globl vector126
vector126:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $126
c0102d0f:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102d11:	e9 6f fb ff ff       	jmp    c0102885 <__alltraps>

c0102d16 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $127
c0102d18:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102d1a:	e9 66 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d1f <vector128>:
.globl vector128
vector128:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $128
c0102d21:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102d26:	e9 5a fb ff ff       	jmp    c0102885 <__alltraps>

c0102d2b <vector129>:
.globl vector129
vector129:
  pushl $0
c0102d2b:	6a 00                	push   $0x0
  pushl $129
c0102d2d:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102d32:	e9 4e fb ff ff       	jmp    c0102885 <__alltraps>

c0102d37 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102d37:	6a 00                	push   $0x0
  pushl $130
c0102d39:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102d3e:	e9 42 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d43 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $131
c0102d45:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102d4a:	e9 36 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d4f <vector132>:
.globl vector132
vector132:
  pushl $0
c0102d4f:	6a 00                	push   $0x0
  pushl $132
c0102d51:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102d56:	e9 2a fb ff ff       	jmp    c0102885 <__alltraps>

c0102d5b <vector133>:
.globl vector133
vector133:
  pushl $0
c0102d5b:	6a 00                	push   $0x0
  pushl $133
c0102d5d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102d62:	e9 1e fb ff ff       	jmp    c0102885 <__alltraps>

c0102d67 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102d67:	6a 00                	push   $0x0
  pushl $134
c0102d69:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102d6e:	e9 12 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d73 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102d73:	6a 00                	push   $0x0
  pushl $135
c0102d75:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102d7a:	e9 06 fb ff ff       	jmp    c0102885 <__alltraps>

c0102d7f <vector136>:
.globl vector136
vector136:
  pushl $0
c0102d7f:	6a 00                	push   $0x0
  pushl $136
c0102d81:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102d86:	e9 fa fa ff ff       	jmp    c0102885 <__alltraps>

c0102d8b <vector137>:
.globl vector137
vector137:
  pushl $0
c0102d8b:	6a 00                	push   $0x0
  pushl $137
c0102d8d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102d92:	e9 ee fa ff ff       	jmp    c0102885 <__alltraps>

c0102d97 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102d97:	6a 00                	push   $0x0
  pushl $138
c0102d99:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102d9e:	e9 e2 fa ff ff       	jmp    c0102885 <__alltraps>

c0102da3 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102da3:	6a 00                	push   $0x0
  pushl $139
c0102da5:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102daa:	e9 d6 fa ff ff       	jmp    c0102885 <__alltraps>

c0102daf <vector140>:
.globl vector140
vector140:
  pushl $0
c0102daf:	6a 00                	push   $0x0
  pushl $140
c0102db1:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102db6:	e9 ca fa ff ff       	jmp    c0102885 <__alltraps>

c0102dbb <vector141>:
.globl vector141
vector141:
  pushl $0
c0102dbb:	6a 00                	push   $0x0
  pushl $141
c0102dbd:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102dc2:	e9 be fa ff ff       	jmp    c0102885 <__alltraps>

c0102dc7 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102dc7:	6a 00                	push   $0x0
  pushl $142
c0102dc9:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102dce:	e9 b2 fa ff ff       	jmp    c0102885 <__alltraps>

c0102dd3 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102dd3:	6a 00                	push   $0x0
  pushl $143
c0102dd5:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102dda:	e9 a6 fa ff ff       	jmp    c0102885 <__alltraps>

c0102ddf <vector144>:
.globl vector144
vector144:
  pushl $0
c0102ddf:	6a 00                	push   $0x0
  pushl $144
c0102de1:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102de6:	e9 9a fa ff ff       	jmp    c0102885 <__alltraps>

c0102deb <vector145>:
.globl vector145
vector145:
  pushl $0
c0102deb:	6a 00                	push   $0x0
  pushl $145
c0102ded:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102df2:	e9 8e fa ff ff       	jmp    c0102885 <__alltraps>

c0102df7 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102df7:	6a 00                	push   $0x0
  pushl $146
c0102df9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102dfe:	e9 82 fa ff ff       	jmp    c0102885 <__alltraps>

c0102e03 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102e03:	6a 00                	push   $0x0
  pushl $147
c0102e05:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102e0a:	e9 76 fa ff ff       	jmp    c0102885 <__alltraps>

c0102e0f <vector148>:
.globl vector148
vector148:
  pushl $0
c0102e0f:	6a 00                	push   $0x0
  pushl $148
c0102e11:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102e16:	e9 6a fa ff ff       	jmp    c0102885 <__alltraps>

c0102e1b <vector149>:
.globl vector149
vector149:
  pushl $0
c0102e1b:	6a 00                	push   $0x0
  pushl $149
c0102e1d:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102e22:	e9 5e fa ff ff       	jmp    c0102885 <__alltraps>

c0102e27 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102e27:	6a 00                	push   $0x0
  pushl $150
c0102e29:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102e2e:	e9 52 fa ff ff       	jmp    c0102885 <__alltraps>

c0102e33 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102e33:	6a 00                	push   $0x0
  pushl $151
c0102e35:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102e3a:	e9 46 fa ff ff       	jmp    c0102885 <__alltraps>

c0102e3f <vector152>:
.globl vector152
vector152:
  pushl $0
c0102e3f:	6a 00                	push   $0x0
  pushl $152
c0102e41:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102e46:	e9 3a fa ff ff       	jmp    c0102885 <__alltraps>

c0102e4b <vector153>:
.globl vector153
vector153:
  pushl $0
c0102e4b:	6a 00                	push   $0x0
  pushl $153
c0102e4d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102e52:	e9 2e fa ff ff       	jmp    c0102885 <__alltraps>

c0102e57 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102e57:	6a 00                	push   $0x0
  pushl $154
c0102e59:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102e5e:	e9 22 fa ff ff       	jmp    c0102885 <__alltraps>

c0102e63 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102e63:	6a 00                	push   $0x0
  pushl $155
c0102e65:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102e6a:	e9 16 fa ff ff       	jmp    c0102885 <__alltraps>

c0102e6f <vector156>:
.globl vector156
vector156:
  pushl $0
c0102e6f:	6a 00                	push   $0x0
  pushl $156
c0102e71:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102e76:	e9 0a fa ff ff       	jmp    c0102885 <__alltraps>

c0102e7b <vector157>:
.globl vector157
vector157:
  pushl $0
c0102e7b:	6a 00                	push   $0x0
  pushl $157
c0102e7d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102e82:	e9 fe f9 ff ff       	jmp    c0102885 <__alltraps>

c0102e87 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102e87:	6a 00                	push   $0x0
  pushl $158
c0102e89:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102e8e:	e9 f2 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102e93 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102e93:	6a 00                	push   $0x0
  pushl $159
c0102e95:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102e9a:	e9 e6 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102e9f <vector160>:
.globl vector160
vector160:
  pushl $0
c0102e9f:	6a 00                	push   $0x0
  pushl $160
c0102ea1:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102ea6:	e9 da f9 ff ff       	jmp    c0102885 <__alltraps>

c0102eab <vector161>:
.globl vector161
vector161:
  pushl $0
c0102eab:	6a 00                	push   $0x0
  pushl $161
c0102ead:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102eb2:	e9 ce f9 ff ff       	jmp    c0102885 <__alltraps>

c0102eb7 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102eb7:	6a 00                	push   $0x0
  pushl $162
c0102eb9:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102ebe:	e9 c2 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102ec3 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102ec3:	6a 00                	push   $0x0
  pushl $163
c0102ec5:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102eca:	e9 b6 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102ecf <vector164>:
.globl vector164
vector164:
  pushl $0
c0102ecf:	6a 00                	push   $0x0
  pushl $164
c0102ed1:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102ed6:	e9 aa f9 ff ff       	jmp    c0102885 <__alltraps>

c0102edb <vector165>:
.globl vector165
vector165:
  pushl $0
c0102edb:	6a 00                	push   $0x0
  pushl $165
c0102edd:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102ee2:	e9 9e f9 ff ff       	jmp    c0102885 <__alltraps>

c0102ee7 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102ee7:	6a 00                	push   $0x0
  pushl $166
c0102ee9:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102eee:	e9 92 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102ef3 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102ef3:	6a 00                	push   $0x0
  pushl $167
c0102ef5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102efa:	e9 86 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102eff <vector168>:
.globl vector168
vector168:
  pushl $0
c0102eff:	6a 00                	push   $0x0
  pushl $168
c0102f01:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102f06:	e9 7a f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f0b <vector169>:
.globl vector169
vector169:
  pushl $0
c0102f0b:	6a 00                	push   $0x0
  pushl $169
c0102f0d:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102f12:	e9 6e f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f17 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102f17:	6a 00                	push   $0x0
  pushl $170
c0102f19:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102f1e:	e9 62 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f23 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102f23:	6a 00                	push   $0x0
  pushl $171
c0102f25:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102f2a:	e9 56 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f2f <vector172>:
.globl vector172
vector172:
  pushl $0
c0102f2f:	6a 00                	push   $0x0
  pushl $172
c0102f31:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102f36:	e9 4a f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f3b <vector173>:
.globl vector173
vector173:
  pushl $0
c0102f3b:	6a 00                	push   $0x0
  pushl $173
c0102f3d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102f42:	e9 3e f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f47 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102f47:	6a 00                	push   $0x0
  pushl $174
c0102f49:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102f4e:	e9 32 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f53 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102f53:	6a 00                	push   $0x0
  pushl $175
c0102f55:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102f5a:	e9 26 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f5f <vector176>:
.globl vector176
vector176:
  pushl $0
c0102f5f:	6a 00                	push   $0x0
  pushl $176
c0102f61:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102f66:	e9 1a f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f6b <vector177>:
.globl vector177
vector177:
  pushl $0
c0102f6b:	6a 00                	push   $0x0
  pushl $177
c0102f6d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102f72:	e9 0e f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f77 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102f77:	6a 00                	push   $0x0
  pushl $178
c0102f79:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102f7e:	e9 02 f9 ff ff       	jmp    c0102885 <__alltraps>

c0102f83 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102f83:	6a 00                	push   $0x0
  pushl $179
c0102f85:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102f8a:	e9 f6 f8 ff ff       	jmp    c0102885 <__alltraps>

c0102f8f <vector180>:
.globl vector180
vector180:
  pushl $0
c0102f8f:	6a 00                	push   $0x0
  pushl $180
c0102f91:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102f96:	e9 ea f8 ff ff       	jmp    c0102885 <__alltraps>

c0102f9b <vector181>:
.globl vector181
vector181:
  pushl $0
c0102f9b:	6a 00                	push   $0x0
  pushl $181
c0102f9d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102fa2:	e9 de f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fa7 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102fa7:	6a 00                	push   $0x0
  pushl $182
c0102fa9:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102fae:	e9 d2 f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fb3 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102fb3:	6a 00                	push   $0x0
  pushl $183
c0102fb5:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102fba:	e9 c6 f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fbf <vector184>:
.globl vector184
vector184:
  pushl $0
c0102fbf:	6a 00                	push   $0x0
  pushl $184
c0102fc1:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102fc6:	e9 ba f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fcb <vector185>:
.globl vector185
vector185:
  pushl $0
c0102fcb:	6a 00                	push   $0x0
  pushl $185
c0102fcd:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102fd2:	e9 ae f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fd7 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102fd7:	6a 00                	push   $0x0
  pushl $186
c0102fd9:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102fde:	e9 a2 f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fe3 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102fe3:	6a 00                	push   $0x0
  pushl $187
c0102fe5:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102fea:	e9 96 f8 ff ff       	jmp    c0102885 <__alltraps>

c0102fef <vector188>:
.globl vector188
vector188:
  pushl $0
c0102fef:	6a 00                	push   $0x0
  pushl $188
c0102ff1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102ff6:	e9 8a f8 ff ff       	jmp    c0102885 <__alltraps>

c0102ffb <vector189>:
.globl vector189
vector189:
  pushl $0
c0102ffb:	6a 00                	push   $0x0
  pushl $189
c0102ffd:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103002:	e9 7e f8 ff ff       	jmp    c0102885 <__alltraps>

c0103007 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103007:	6a 00                	push   $0x0
  pushl $190
c0103009:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010300e:	e9 72 f8 ff ff       	jmp    c0102885 <__alltraps>

c0103013 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103013:	6a 00                	push   $0x0
  pushl $191
c0103015:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010301a:	e9 66 f8 ff ff       	jmp    c0102885 <__alltraps>

c010301f <vector192>:
.globl vector192
vector192:
  pushl $0
c010301f:	6a 00                	push   $0x0
  pushl $192
c0103021:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103026:	e9 5a f8 ff ff       	jmp    c0102885 <__alltraps>

c010302b <vector193>:
.globl vector193
vector193:
  pushl $0
c010302b:	6a 00                	push   $0x0
  pushl $193
c010302d:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103032:	e9 4e f8 ff ff       	jmp    c0102885 <__alltraps>

c0103037 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103037:	6a 00                	push   $0x0
  pushl $194
c0103039:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010303e:	e9 42 f8 ff ff       	jmp    c0102885 <__alltraps>

c0103043 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103043:	6a 00                	push   $0x0
  pushl $195
c0103045:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010304a:	e9 36 f8 ff ff       	jmp    c0102885 <__alltraps>

c010304f <vector196>:
.globl vector196
vector196:
  pushl $0
c010304f:	6a 00                	push   $0x0
  pushl $196
c0103051:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103056:	e9 2a f8 ff ff       	jmp    c0102885 <__alltraps>

c010305b <vector197>:
.globl vector197
vector197:
  pushl $0
c010305b:	6a 00                	push   $0x0
  pushl $197
c010305d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103062:	e9 1e f8 ff ff       	jmp    c0102885 <__alltraps>

c0103067 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103067:	6a 00                	push   $0x0
  pushl $198
c0103069:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010306e:	e9 12 f8 ff ff       	jmp    c0102885 <__alltraps>

c0103073 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103073:	6a 00                	push   $0x0
  pushl $199
c0103075:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010307a:	e9 06 f8 ff ff       	jmp    c0102885 <__alltraps>

c010307f <vector200>:
.globl vector200
vector200:
  pushl $0
c010307f:	6a 00                	push   $0x0
  pushl $200
c0103081:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103086:	e9 fa f7 ff ff       	jmp    c0102885 <__alltraps>

c010308b <vector201>:
.globl vector201
vector201:
  pushl $0
c010308b:	6a 00                	push   $0x0
  pushl $201
c010308d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103092:	e9 ee f7 ff ff       	jmp    c0102885 <__alltraps>

c0103097 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103097:	6a 00                	push   $0x0
  pushl $202
c0103099:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010309e:	e9 e2 f7 ff ff       	jmp    c0102885 <__alltraps>

c01030a3 <vector203>:
.globl vector203
vector203:
  pushl $0
c01030a3:	6a 00                	push   $0x0
  pushl $203
c01030a5:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01030aa:	e9 d6 f7 ff ff       	jmp    c0102885 <__alltraps>

c01030af <vector204>:
.globl vector204
vector204:
  pushl $0
c01030af:	6a 00                	push   $0x0
  pushl $204
c01030b1:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01030b6:	e9 ca f7 ff ff       	jmp    c0102885 <__alltraps>

c01030bb <vector205>:
.globl vector205
vector205:
  pushl $0
c01030bb:	6a 00                	push   $0x0
  pushl $205
c01030bd:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01030c2:	e9 be f7 ff ff       	jmp    c0102885 <__alltraps>

c01030c7 <vector206>:
.globl vector206
vector206:
  pushl $0
c01030c7:	6a 00                	push   $0x0
  pushl $206
c01030c9:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01030ce:	e9 b2 f7 ff ff       	jmp    c0102885 <__alltraps>

c01030d3 <vector207>:
.globl vector207
vector207:
  pushl $0
c01030d3:	6a 00                	push   $0x0
  pushl $207
c01030d5:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01030da:	e9 a6 f7 ff ff       	jmp    c0102885 <__alltraps>

c01030df <vector208>:
.globl vector208
vector208:
  pushl $0
c01030df:	6a 00                	push   $0x0
  pushl $208
c01030e1:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01030e6:	e9 9a f7 ff ff       	jmp    c0102885 <__alltraps>

c01030eb <vector209>:
.globl vector209
vector209:
  pushl $0
c01030eb:	6a 00                	push   $0x0
  pushl $209
c01030ed:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01030f2:	e9 8e f7 ff ff       	jmp    c0102885 <__alltraps>

c01030f7 <vector210>:
.globl vector210
vector210:
  pushl $0
c01030f7:	6a 00                	push   $0x0
  pushl $210
c01030f9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01030fe:	e9 82 f7 ff ff       	jmp    c0102885 <__alltraps>

c0103103 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103103:	6a 00                	push   $0x0
  pushl $211
c0103105:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010310a:	e9 76 f7 ff ff       	jmp    c0102885 <__alltraps>

c010310f <vector212>:
.globl vector212
vector212:
  pushl $0
c010310f:	6a 00                	push   $0x0
  pushl $212
c0103111:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103116:	e9 6a f7 ff ff       	jmp    c0102885 <__alltraps>

c010311b <vector213>:
.globl vector213
vector213:
  pushl $0
c010311b:	6a 00                	push   $0x0
  pushl $213
c010311d:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103122:	e9 5e f7 ff ff       	jmp    c0102885 <__alltraps>

c0103127 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103127:	6a 00                	push   $0x0
  pushl $214
c0103129:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010312e:	e9 52 f7 ff ff       	jmp    c0102885 <__alltraps>

c0103133 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103133:	6a 00                	push   $0x0
  pushl $215
c0103135:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010313a:	e9 46 f7 ff ff       	jmp    c0102885 <__alltraps>

c010313f <vector216>:
.globl vector216
vector216:
  pushl $0
c010313f:	6a 00                	push   $0x0
  pushl $216
c0103141:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103146:	e9 3a f7 ff ff       	jmp    c0102885 <__alltraps>

c010314b <vector217>:
.globl vector217
vector217:
  pushl $0
c010314b:	6a 00                	push   $0x0
  pushl $217
c010314d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103152:	e9 2e f7 ff ff       	jmp    c0102885 <__alltraps>

c0103157 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103157:	6a 00                	push   $0x0
  pushl $218
c0103159:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010315e:	e9 22 f7 ff ff       	jmp    c0102885 <__alltraps>

c0103163 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103163:	6a 00                	push   $0x0
  pushl $219
c0103165:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010316a:	e9 16 f7 ff ff       	jmp    c0102885 <__alltraps>

c010316f <vector220>:
.globl vector220
vector220:
  pushl $0
c010316f:	6a 00                	push   $0x0
  pushl $220
c0103171:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103176:	e9 0a f7 ff ff       	jmp    c0102885 <__alltraps>

c010317b <vector221>:
.globl vector221
vector221:
  pushl $0
c010317b:	6a 00                	push   $0x0
  pushl $221
c010317d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103182:	e9 fe f6 ff ff       	jmp    c0102885 <__alltraps>

c0103187 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103187:	6a 00                	push   $0x0
  pushl $222
c0103189:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010318e:	e9 f2 f6 ff ff       	jmp    c0102885 <__alltraps>

c0103193 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103193:	6a 00                	push   $0x0
  pushl $223
c0103195:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010319a:	e9 e6 f6 ff ff       	jmp    c0102885 <__alltraps>

c010319f <vector224>:
.globl vector224
vector224:
  pushl $0
c010319f:	6a 00                	push   $0x0
  pushl $224
c01031a1:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01031a6:	e9 da f6 ff ff       	jmp    c0102885 <__alltraps>

c01031ab <vector225>:
.globl vector225
vector225:
  pushl $0
c01031ab:	6a 00                	push   $0x0
  pushl $225
c01031ad:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01031b2:	e9 ce f6 ff ff       	jmp    c0102885 <__alltraps>

c01031b7 <vector226>:
.globl vector226
vector226:
  pushl $0
c01031b7:	6a 00                	push   $0x0
  pushl $226
c01031b9:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01031be:	e9 c2 f6 ff ff       	jmp    c0102885 <__alltraps>

c01031c3 <vector227>:
.globl vector227
vector227:
  pushl $0
c01031c3:	6a 00                	push   $0x0
  pushl $227
c01031c5:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01031ca:	e9 b6 f6 ff ff       	jmp    c0102885 <__alltraps>

c01031cf <vector228>:
.globl vector228
vector228:
  pushl $0
c01031cf:	6a 00                	push   $0x0
  pushl $228
c01031d1:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01031d6:	e9 aa f6 ff ff       	jmp    c0102885 <__alltraps>

c01031db <vector229>:
.globl vector229
vector229:
  pushl $0
c01031db:	6a 00                	push   $0x0
  pushl $229
c01031dd:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01031e2:	e9 9e f6 ff ff       	jmp    c0102885 <__alltraps>

c01031e7 <vector230>:
.globl vector230
vector230:
  pushl $0
c01031e7:	6a 00                	push   $0x0
  pushl $230
c01031e9:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01031ee:	e9 92 f6 ff ff       	jmp    c0102885 <__alltraps>

c01031f3 <vector231>:
.globl vector231
vector231:
  pushl $0
c01031f3:	6a 00                	push   $0x0
  pushl $231
c01031f5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01031fa:	e9 86 f6 ff ff       	jmp    c0102885 <__alltraps>

c01031ff <vector232>:
.globl vector232
vector232:
  pushl $0
c01031ff:	6a 00                	push   $0x0
  pushl $232
c0103201:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103206:	e9 7a f6 ff ff       	jmp    c0102885 <__alltraps>

c010320b <vector233>:
.globl vector233
vector233:
  pushl $0
c010320b:	6a 00                	push   $0x0
  pushl $233
c010320d:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103212:	e9 6e f6 ff ff       	jmp    c0102885 <__alltraps>

c0103217 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103217:	6a 00                	push   $0x0
  pushl $234
c0103219:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010321e:	e9 62 f6 ff ff       	jmp    c0102885 <__alltraps>

c0103223 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103223:	6a 00                	push   $0x0
  pushl $235
c0103225:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010322a:	e9 56 f6 ff ff       	jmp    c0102885 <__alltraps>

c010322f <vector236>:
.globl vector236
vector236:
  pushl $0
c010322f:	6a 00                	push   $0x0
  pushl $236
c0103231:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103236:	e9 4a f6 ff ff       	jmp    c0102885 <__alltraps>

c010323b <vector237>:
.globl vector237
vector237:
  pushl $0
c010323b:	6a 00                	push   $0x0
  pushl $237
c010323d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103242:	e9 3e f6 ff ff       	jmp    c0102885 <__alltraps>

c0103247 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103247:	6a 00                	push   $0x0
  pushl $238
c0103249:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010324e:	e9 32 f6 ff ff       	jmp    c0102885 <__alltraps>

c0103253 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103253:	6a 00                	push   $0x0
  pushl $239
c0103255:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010325a:	e9 26 f6 ff ff       	jmp    c0102885 <__alltraps>

c010325f <vector240>:
.globl vector240
vector240:
  pushl $0
c010325f:	6a 00                	push   $0x0
  pushl $240
c0103261:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103266:	e9 1a f6 ff ff       	jmp    c0102885 <__alltraps>

c010326b <vector241>:
.globl vector241
vector241:
  pushl $0
c010326b:	6a 00                	push   $0x0
  pushl $241
c010326d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103272:	e9 0e f6 ff ff       	jmp    c0102885 <__alltraps>

c0103277 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103277:	6a 00                	push   $0x0
  pushl $242
c0103279:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010327e:	e9 02 f6 ff ff       	jmp    c0102885 <__alltraps>

c0103283 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103283:	6a 00                	push   $0x0
  pushl $243
c0103285:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010328a:	e9 f6 f5 ff ff       	jmp    c0102885 <__alltraps>

c010328f <vector244>:
.globl vector244
vector244:
  pushl $0
c010328f:	6a 00                	push   $0x0
  pushl $244
c0103291:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103296:	e9 ea f5 ff ff       	jmp    c0102885 <__alltraps>

c010329b <vector245>:
.globl vector245
vector245:
  pushl $0
c010329b:	6a 00                	push   $0x0
  pushl $245
c010329d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01032a2:	e9 de f5 ff ff       	jmp    c0102885 <__alltraps>

c01032a7 <vector246>:
.globl vector246
vector246:
  pushl $0
c01032a7:	6a 00                	push   $0x0
  pushl $246
c01032a9:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01032ae:	e9 d2 f5 ff ff       	jmp    c0102885 <__alltraps>

c01032b3 <vector247>:
.globl vector247
vector247:
  pushl $0
c01032b3:	6a 00                	push   $0x0
  pushl $247
c01032b5:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01032ba:	e9 c6 f5 ff ff       	jmp    c0102885 <__alltraps>

c01032bf <vector248>:
.globl vector248
vector248:
  pushl $0
c01032bf:	6a 00                	push   $0x0
  pushl $248
c01032c1:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01032c6:	e9 ba f5 ff ff       	jmp    c0102885 <__alltraps>

c01032cb <vector249>:
.globl vector249
vector249:
  pushl $0
c01032cb:	6a 00                	push   $0x0
  pushl $249
c01032cd:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01032d2:	e9 ae f5 ff ff       	jmp    c0102885 <__alltraps>

c01032d7 <vector250>:
.globl vector250
vector250:
  pushl $0
c01032d7:	6a 00                	push   $0x0
  pushl $250
c01032d9:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01032de:	e9 a2 f5 ff ff       	jmp    c0102885 <__alltraps>

c01032e3 <vector251>:
.globl vector251
vector251:
  pushl $0
c01032e3:	6a 00                	push   $0x0
  pushl $251
c01032e5:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01032ea:	e9 96 f5 ff ff       	jmp    c0102885 <__alltraps>

c01032ef <vector252>:
.globl vector252
vector252:
  pushl $0
c01032ef:	6a 00                	push   $0x0
  pushl $252
c01032f1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01032f6:	e9 8a f5 ff ff       	jmp    c0102885 <__alltraps>

c01032fb <vector253>:
.globl vector253
vector253:
  pushl $0
c01032fb:	6a 00                	push   $0x0
  pushl $253
c01032fd:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103302:	e9 7e f5 ff ff       	jmp    c0102885 <__alltraps>

c0103307 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103307:	6a 00                	push   $0x0
  pushl $254
c0103309:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010330e:	e9 72 f5 ff ff       	jmp    c0102885 <__alltraps>

c0103313 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103313:	6a 00                	push   $0x0
  pushl $255
c0103315:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010331a:	e9 66 f5 ff ff       	jmp    c0102885 <__alltraps>

c010331f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010331f:	55                   	push   %ebp
c0103320:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103322:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0103328:	8b 45 08             	mov    0x8(%ebp),%eax
c010332b:	29 d0                	sub    %edx,%eax
c010332d:	c1 f8 05             	sar    $0x5,%eax
}
c0103330:	5d                   	pop    %ebp
c0103331:	c3                   	ret    

c0103332 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103332:	55                   	push   %ebp
c0103333:	89 e5                	mov    %esp,%ebp
c0103335:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103338:	8b 45 08             	mov    0x8(%ebp),%eax
c010333b:	89 04 24             	mov    %eax,(%esp)
c010333e:	e8 dc ff ff ff       	call   c010331f <page2ppn>
c0103343:	c1 e0 0c             	shl    $0xc,%eax
}
c0103346:	89 ec                	mov    %ebp,%esp
c0103348:	5d                   	pop    %ebp
c0103349:	c3                   	ret    

c010334a <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010334a:	55                   	push   %ebp
c010334b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010334d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103350:	8b 00                	mov    (%eax),%eax
}
c0103352:	5d                   	pop    %ebp
c0103353:	c3                   	ret    

c0103354 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103354:	55                   	push   %ebp
c0103355:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103357:	8b 45 08             	mov    0x8(%ebp),%eax
c010335a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010335d:	89 10                	mov    %edx,(%eax)
}
c010335f:	90                   	nop
c0103360:	5d                   	pop    %ebp
c0103361:	c3                   	ret    

c0103362 <default_init>:
//free_list本身不会对应Page结构
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103362:	55                   	push   %ebp
c0103363:	89 e5                	mov    %esp,%ebp
c0103365:	83 ec 10             	sub    $0x10,%esp
c0103368:	c7 45 fc 84 bf 12 c0 	movl   $0xc012bf84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010336f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103372:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103375:	89 50 04             	mov    %edx,0x4(%eax)
c0103378:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010337b:	8b 50 04             	mov    0x4(%eax),%edx
c010337e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103381:	89 10                	mov    %edx,(%eax)
}
c0103383:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103384:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c010338b:	00 00 00 
}
c010338e:	90                   	nop
c010338f:	89 ec                	mov    %ebp,%esp
c0103391:	5d                   	pop    %ebp
c0103392:	c3                   	ret    

c0103393 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103393:	55                   	push   %ebp
c0103394:	89 e5                	mov    %esp,%ebp
c0103396:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0103399:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010339d:	75 24                	jne    c01033c3 <default_init_memmap+0x30>
c010339f:	c7 44 24 0c 30 aa 10 	movl   $0xc010aa30,0xc(%esp)
c01033a6:	c0 
c01033a7:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01033ae:	c0 
c01033af:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c01033b6:	00 
c01033b7:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01033be:	e8 53 d9 ff ff       	call   c0100d16 <__panic>
    struct Page *p = base;
c01033c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01033c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //相邻的page结构在内存上也是相邻的
    for (; p != base + n; p ++) {
c01033c9:	e9 97 00 00 00       	jmp    c0103465 <default_init_memmap+0xd2>
        //检查是否被保留,是否有问题，
        assert(PageReserved(p));
c01033ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d1:	83 c0 04             	add    $0x4,%eax
c01033d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01033db:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01033e4:	0f a3 10             	bt     %edx,(%eax)
c01033e7:	19 c0                	sbb    %eax,%eax
c01033e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01033ec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01033f0:	0f 95 c0             	setne  %al
c01033f3:	0f b6 c0             	movzbl %al,%eax
c01033f6:	85 c0                	test   %eax,%eax
c01033f8:	75 24                	jne    c010341e <default_init_memmap+0x8b>
c01033fa:	c7 44 24 0c 61 aa 10 	movl   $0xc010aa61,0xc(%esp)
c0103401:	c0 
c0103402:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103409:	c0 
c010340a:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0103411:	00 
c0103412:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103419:	e8 f8 d8 ff ff       	call   c0100d16 <__panic>
        p->flags = p->property = 0;
c010341e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103421:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103428:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010342b:	8b 50 08             	mov    0x8(%eax),%edx
c010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103431:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103434:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010343b:	00 
c010343c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010343f:	89 04 24             	mov    %eax,(%esp)
c0103442:	e8 0d ff ff ff       	call   c0103354 <set_page_ref>
        //my_add
        SetPageProperty(p);
c0103447:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010344a:	83 c0 04             	add    $0x4,%eax
c010344d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103454:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103457:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010345a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010345d:	0f ab 10             	bts    %edx,(%eax)
}
c0103460:	90                   	nop
    for (; p != base + n; p ++) {
c0103461:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103465:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103468:	c1 e0 05             	shl    $0x5,%eax
c010346b:	89 c2                	mov    %eax,%edx
c010346d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103470:	01 d0                	add    %edx,%eax
c0103472:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103475:	0f 85 53 ff ff ff    	jne    c01033ce <default_init_memmap+0x3b>

    }
    base->property = n;
c010347b:	8b 45 08             	mov    0x8(%ebp),%eax
c010347e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103481:	89 50 08             	mov    %edx,0x8(%eax)
    //置位标志位代表可以分配
   //SetPageProperty(base);
    nr_free += n;
c0103484:	8b 15 8c bf 12 c0    	mov    0xc012bf8c,%edx
c010348a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010348d:	01 d0                	add    %edx,%eax
c010348f:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
    list_add(&free_list, &(base->page_link));
c0103494:	8b 45 08             	mov    0x8(%ebp),%eax
c0103497:	83 c0 0c             	add    $0xc,%eax
c010349a:	c7 45 dc 84 bf 12 c0 	movl   $0xc012bf84,-0x24(%ebp)
c01034a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01034a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01034a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01034aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01034ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01034b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01034b3:	8b 40 04             	mov    0x4(%eax),%eax
c01034b6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034b9:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01034bc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01034bf:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01034c2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01034c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01034cb:	89 10                	mov    %edx,(%eax)
c01034cd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034d0:	8b 10                	mov    (%eax),%edx
c01034d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034d5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01034d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01034de:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01034e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034e4:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01034e7:	89 10                	mov    %edx,(%eax)
}
c01034e9:	90                   	nop
}
c01034ea:	90                   	nop
}
c01034eb:	90                   	nop
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
c01034ec:	90                   	nop
c01034ed:	89 ec                	mov    %ebp,%esp
c01034ef:	5d                   	pop    %ebp
c01034f0:	c3                   	ret    

c01034f1 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01034f1:	55                   	push   %ebp
c01034f2:	89 e5                	mov    %esp,%ebp
c01034f4:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01034f7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01034fb:	75 24                	jne    c0103521 <default_alloc_pages+0x30>
c01034fd:	c7 44 24 0c 30 aa 10 	movl   $0xc010aa30,0xc(%esp)
c0103504:	c0 
c0103505:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010350c:	c0 
c010350d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0103514:	00 
c0103515:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010351c:	e8 f5 d7 ff ff       	call   c0100d16 <__panic>
    if (n > nr_free) {
c0103521:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103526:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103529:	76 0a                	jbe    c0103535 <default_alloc_pages+0x44>
        return NULL;
c010352b:	b8 00 00 00 00       	mov    $0x0,%eax
c0103530:	e9 74 01 00 00       	jmp    c01036a9 <default_alloc_pages+0x1b8>
    }
    struct Page *page = NULL;
c0103535:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010353c:	c7 45 f0 84 bf 12 c0 	movl   $0xc012bf84,-0x10(%ebp)

    //遍历free_list
    while ((le = list_next(le)) != &free_list) {
c0103543:	eb 1c                	jmp    c0103561 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103545:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103548:	83 e8 0c             	sub    $0xc,%eax
c010354b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c010354e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103551:	8b 40 08             	mov    0x8(%eax),%eax
c0103554:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103557:	77 08                	ja     c0103561 <default_alloc_pages+0x70>
            page = p;
c0103559:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010355c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010355f:	eb 18                	jmp    c0103579 <default_alloc_pages+0x88>
c0103561:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103564:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103567:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010356a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010356d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103570:	81 7d f0 84 bf 12 c0 	cmpl   $0xc012bf84,-0x10(%ebp)
c0103577:	75 cc                	jne    c0103545 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0103579:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010357d:	0f 84 23 01 00 00    	je     c01036a6 <default_alloc_pages+0x1b5>
        struct Page *temp=page;
c0103583:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103586:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for(;temp!=page+n;temp++)
c0103589:	eb 1e                	jmp    c01035a9 <default_alloc_pages+0xb8>
            ClearPageProperty(temp);
c010358b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010358e:	83 c0 04             	add    $0x4,%eax
c0103591:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0103598:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010359b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010359e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01035a1:	0f b3 10             	btr    %edx,(%eax)
}
c01035a4:	90                   	nop
        for(;temp!=page+n;temp++)
c01035a5:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c01035a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ac:	c1 e0 05             	shl    $0x5,%eax
c01035af:	89 c2                	mov    %eax,%edx
c01035b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035b4:	01 d0                	add    %edx,%eax
c01035b6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01035b9:	75 d0                	jne    c010358b <default_alloc_pages+0x9a>
        if (page->property > n) {
c01035bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035be:	8b 40 08             	mov    0x8(%eax),%eax
c01035c1:	39 45 08             	cmp    %eax,0x8(%ebp)
c01035c4:	0f 83 88 00 00 00    	jae    c0103652 <default_alloc_pages+0x161>
            struct Page *p = page + n;
c01035ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01035cd:	c1 e0 05             	shl    $0x5,%eax
c01035d0:	89 c2                	mov    %eax,%edx
c01035d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035d5:	01 d0                	add    %edx,%eax
c01035d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c01035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035dd:	8b 40 08             	mov    0x8(%eax),%eax
c01035e0:	2b 45 08             	sub    0x8(%ebp),%eax
c01035e3:	89 c2                	mov    %eax,%edx
c01035e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035e8:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c01035eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035ee:	83 c0 04             	add    $0x4,%eax
c01035f1:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01035f8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035fb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01035fe:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103601:	0f ab 10             	bts    %edx,(%eax)
}
c0103604:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c0103605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103608:	83 c0 0c             	add    $0xc,%eax
c010360b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010360e:	83 c2 0c             	add    $0xc,%edx
c0103611:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103614:	89 45 d0             	mov    %eax,-0x30(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103617:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010361a:	8b 40 04             	mov    0x4(%eax),%eax
c010361d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103620:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103623:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103626:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0103629:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c010362c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010362f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103632:	89 10                	mov    %edx,(%eax)
c0103634:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103637:	8b 10                	mov    (%eax),%edx
c0103639:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010363c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010363f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103642:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103645:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103648:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010364b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010364e:	89 10                	mov    %edx,(%eax)
}
c0103650:	90                   	nop
}
c0103651:	90                   	nop
        }
        list_del(&(page->page_link));
c0103652:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103655:	83 c0 0c             	add    $0xc,%eax
c0103658:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010365b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010365e:	8b 40 04             	mov    0x4(%eax),%eax
c0103661:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103664:	8b 12                	mov    (%edx),%edx
c0103666:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0103669:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010366c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010366f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103672:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103675:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103678:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010367b:	89 10                	mov    %edx,(%eax)
}
c010367d:	90                   	nop
}
c010367e:	90                   	nop
        nr_free -= n;
c010367f:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103684:	2b 45 08             	sub    0x8(%ebp),%eax
c0103687:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
        ClearPageProperty(page);
c010368c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010368f:	83 c0 04             	add    $0x4,%eax
c0103692:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103699:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010369c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010369f:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01036a2:	0f b3 10             	btr    %edx,(%eax)
}
c01036a5:	90                   	nop
    }
    return page;
c01036a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;*/
}
c01036a9:	89 ec                	mov    %ebp,%esp
c01036ab:	5d                   	pop    %ebp
c01036ac:	c3                   	ret    

c01036ad <merge_backward>:

static bool merge_backward(struct  Page*base)
{
c01036ad:	55                   	push   %ebp
c01036ae:	89 e5                	mov    %esp,%ebp
c01036b0:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_next(&(base->page_link));
c01036b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01036b6:	83 c0 0c             	add    $0xc,%eax
c01036b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->next;
c01036bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036bf:	8b 40 04             	mov    0x4(%eax),%eax
c01036c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    //判断是否为头节点
    if (le==&free_list)
c01036c5:	81 7d fc 84 bf 12 c0 	cmpl   $0xc012bf84,-0x4(%ebp)
c01036cc:	75 0a                	jne    c01036d8 <merge_backward+0x2b>
    return 0;
c01036ce:	b8 00 00 00 00       	mov    $0x0,%eax
c01036d3:	e9 a5 00 00 00       	jmp    c010377d <merge_backward+0xd0>
    struct Page*p=le2page(le,page_link);
c01036d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036db:	83 e8 0c             	sub    $0xc,%eax
c01036de:	89 45 f8             	mov    %eax,-0x8(%ebp)
    
    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c01036e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01036e4:	83 c0 04             	add    $0x4,%eax
c01036e7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01036ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036f7:	0f a3 10             	bt     %edx,(%eax)
c01036fa:	19 c0                	sbb    %eax,%eax
c01036fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103703:	0f 95 c0             	setne  %al
c0103706:	0f b6 c0             	movzbl %al,%eax
c0103709:	85 c0                	test   %eax,%eax
c010370b:	75 07                	jne    c0103714 <merge_backward+0x67>
c010370d:	b8 00 00 00 00       	mov    $0x0,%eax
c0103712:	eb 69                	jmp    c010377d <merge_backward+0xd0>
    //判断地址是否连续
    if(base+base->property==p)
c0103714:	8b 45 08             	mov    0x8(%ebp),%eax
c0103717:	8b 40 08             	mov    0x8(%eax),%eax
c010371a:	c1 e0 05             	shl    $0x5,%eax
c010371d:	89 c2                	mov    %eax,%edx
c010371f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103722:	01 d0                	add    %edx,%eax
c0103724:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c0103727:	75 4f                	jne    c0103778 <merge_backward+0xcb>
    {
        base->property+=p->property;
c0103729:	8b 45 08             	mov    0x8(%ebp),%eax
c010372c:	8b 50 08             	mov    0x8(%eax),%edx
c010372f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103732:	8b 40 08             	mov    0x8(%eax),%eax
c0103735:	01 c2                	add    %eax,%edx
c0103737:	8b 45 08             	mov    0x8(%ebp),%eax
c010373a:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
c010373d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103740:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103747:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010374a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010374d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103750:	8b 40 04             	mov    0x4(%eax),%eax
c0103753:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103756:	8b 12                	mov    (%edx),%edx
c0103758:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010375b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c010375e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103761:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103764:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103767:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010376a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010376d:	89 10                	mov    %edx,(%eax)
}
c010376f:	90                   	nop
}
c0103770:	90                   	nop
        list_del(le);
        return 1;
c0103771:	b8 01 00 00 00       	mov    $0x1,%eax
c0103776:	eb 05                	jmp    c010377d <merge_backward+0xd0>
        
    }
    else
    {
        return 0;
c0103778:	b8 00 00 00 00       	mov    $0x0,%eax
    }

}
c010377d:	89 ec                	mov    %ebp,%esp
c010377f:	5d                   	pop    %ebp
c0103780:	c3                   	ret    

c0103781 <merge_beforeward>:
static bool merge_beforeward(struct Page*base)
{
c0103781:	55                   	push   %ebp
c0103782:	89 e5                	mov    %esp,%ebp
c0103784:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_prev(&(base->page_link));
c0103787:	8b 45 08             	mov    0x8(%ebp),%eax
c010378a:	83 c0 0c             	add    $0xc,%eax
c010378d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->prev;
c0103790:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103793:	8b 00                	mov    (%eax),%eax
c0103795:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le==&free_list)
c0103798:	81 7d fc 84 bf 12 c0 	cmpl   $0xc012bf84,-0x4(%ebp)
c010379f:	75 0a                	jne    c01037ab <merge_beforeward+0x2a>
    return 0;
c01037a1:	b8 00 00 00 00       	mov    $0x0,%eax
c01037a6:	e9 ae 00 00 00       	jmp    c0103859 <merge_beforeward+0xd8>
    struct Page*p=le2page(le,page_link);
c01037ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01037ae:	83 e8 0c             	sub    $0xc,%eax
c01037b1:	89 45 f8             	mov    %eax,-0x8(%ebp)

    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c01037b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037b7:	83 c0 04             	add    $0x4,%eax
c01037ba:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01037c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01037ca:	0f a3 10             	bt     %edx,(%eax)
c01037cd:	19 c0                	sbb    %eax,%eax
c01037cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01037d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01037d6:	0f 95 c0             	setne  %al
c01037d9:	0f b6 c0             	movzbl %al,%eax
c01037dc:	85 c0                	test   %eax,%eax
c01037de:	75 07                	jne    c01037e7 <merge_beforeward+0x66>
c01037e0:	b8 00 00 00 00       	mov    $0x0,%eax
c01037e5:	eb 72                	jmp    c0103859 <merge_beforeward+0xd8>
    //判断地址是否连续
    if(p+p->property==base)
c01037e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037ea:	8b 40 08             	mov    0x8(%eax),%eax
c01037ed:	c1 e0 05             	shl    $0x5,%eax
c01037f0:	89 c2                	mov    %eax,%edx
c01037f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037f5:	01 d0                	add    %edx,%eax
c01037f7:	39 45 08             	cmp    %eax,0x8(%ebp)
c01037fa:	75 58                	jne    c0103854 <merge_beforeward+0xd3>
    {
        p->property+=base->property;
c01037fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037ff:	8b 50 08             	mov    0x8(%eax),%edx
c0103802:	8b 45 08             	mov    0x8(%ebp),%eax
c0103805:	8b 40 08             	mov    0x8(%eax),%eax
c0103808:	01 c2                	add    %eax,%edx
c010380a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010380d:	89 50 08             	mov    %edx,0x8(%eax)
        base->property=0;
c0103810:	8b 45 08             	mov    0x8(%ebp),%eax
c0103813:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_del(&(base->page_link));
c010381a:	8b 45 08             	mov    0x8(%ebp),%eax
c010381d:	83 c0 0c             	add    $0xc,%eax
c0103820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103823:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103826:	8b 40 04             	mov    0x4(%eax),%eax
c0103829:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010382c:	8b 12                	mov    (%edx),%edx
c010382e:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0103831:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0103834:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103837:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010383a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010383d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103840:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103843:	89 10                	mov    %edx,(%eax)
}
c0103845:	90                   	nop
}
c0103846:	90                   	nop
        base=p;
c0103847:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010384a:	89 45 08             	mov    %eax,0x8(%ebp)
        return 1;   
c010384d:	b8 01 00 00 00       	mov    $0x1,%eax
c0103852:	eb 05                	jmp    c0103859 <merge_beforeward+0xd8>
    }
    else
    {
        return 0;
c0103854:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    

}
c0103859:	89 ec                	mov    %ebp,%esp
c010385b:	5d                   	pop    %ebp
c010385c:	c3                   	ret    

c010385d <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010385d:	55                   	push   %ebp
c010385e:	89 e5                	mov    %esp,%ebp
c0103860:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103863:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103867:	75 24                	jne    c010388d <default_free_pages+0x30>
c0103869:	c7 44 24 0c 30 aa 10 	movl   $0xc010aa30,0xc(%esp)
c0103870:	c0 
c0103871:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103878:	c0 
c0103879:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103880:	00 
c0103881:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103888:	e8 89 d4 ff ff       	call   c0100d16 <__panic>
    struct Page *p = base;
c010388d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103890:	89 45 f4             	mov    %eax,-0xc(%ebp)

    for (; p != base + n; p ++) {
c0103893:	e9 ad 00 00 00       	jmp    c0103945 <default_free_pages+0xe8>
        
        //需要满足不是给内核的且不是空闲的
        assert(!PageReserved(p) && !PageProperty(p));
c0103898:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389b:	83 c0 04             	add    $0x4,%eax
c010389e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01038a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01038ae:	0f a3 10             	bt     %edx,(%eax)
c01038b1:	19 c0                	sbb    %eax,%eax
c01038b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01038b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01038ba:	0f 95 c0             	setne  %al
c01038bd:	0f b6 c0             	movzbl %al,%eax
c01038c0:	85 c0                	test   %eax,%eax
c01038c2:	75 2c                	jne    c01038f0 <default_free_pages+0x93>
c01038c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038c7:	83 c0 04             	add    $0x4,%eax
c01038ca:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01038d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038da:	0f a3 10             	bt     %edx,(%eax)
c01038dd:	19 c0                	sbb    %eax,%eax
c01038df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01038e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01038e6:	0f 95 c0             	setne  %al
c01038e9:	0f b6 c0             	movzbl %al,%eax
c01038ec:	85 c0                	test   %eax,%eax
c01038ee:	74 24                	je     c0103914 <default_free_pages+0xb7>
c01038f0:	c7 44 24 0c 74 aa 10 	movl   $0xc010aa74,0xc(%esp)
c01038f7:	c0 
c01038f8:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01038ff:	c0 
c0103900:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0103907:	00 
c0103908:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010390f:	e8 02 d4 ff ff       	call   c0100d16 <__panic>
        //p->flags = 0;
        SetPageProperty(p);
c0103914:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103917:	83 c0 04             	add    $0x4,%eax
c010391a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103921:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103924:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103927:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010392a:	0f ab 10             	bts    %edx,(%eax)
}
c010392d:	90                   	nop
        set_page_ref(p, 0);
c010392e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103935:	00 
c0103936:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103939:	89 04 24             	mov    %eax,(%esp)
c010393c:	e8 13 fa ff ff       	call   c0103354 <set_page_ref>
    for (; p != base + n; p ++) {
c0103941:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103945:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103948:	c1 e0 05             	shl    $0x5,%eax
c010394b:	89 c2                	mov    %eax,%edx
c010394d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103950:	01 d0                	add    %edx,%eax
c0103952:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103955:	0f 85 3d ff ff ff    	jne    c0103898 <default_free_pages+0x3b>
    }

    base->property = n;
c010395b:	8b 45 08             	mov    0x8(%ebp),%eax
c010395e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103961:	89 50 08             	mov    %edx,0x8(%eax)
c0103964:	c7 45 cc 84 bf 12 c0 	movl   $0xc012bf84,-0x34(%ebp)
    return listelm->next;
c010396b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010396e:	8b 40 04             	mov    0x4(%eax),%eax
    //SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
c0103971:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    for(;le!=&free_list && le<&(base->page_link);le=list_next(le));
c0103974:	eb 0f                	jmp    c0103985 <default_free_pages+0x128>
c0103976:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103979:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010397c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010397f:	8b 40 04             	mov    0x4(%eax),%eax
c0103982:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103985:	81 7d f0 84 bf 12 c0 	cmpl   $0xc012bf84,-0x10(%ebp)
c010398c:	74 0b                	je     c0103999 <default_free_pages+0x13c>
c010398e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103991:	83 c0 0c             	add    $0xc,%eax
c0103994:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103997:	72 dd                	jb     c0103976 <default_free_pages+0x119>

     nr_free += n;
c0103999:	8b 15 8c bf 12 c0    	mov    0xc012bf8c,%edx
c010399f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039a2:	01 d0                	add    %edx,%eax
c01039a4:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
    list_add_before(le,&base->page_link);
c01039a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01039ac:	8d 50 0c             	lea    0xc(%eax),%edx
c01039af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01039b5:	89 55 c0             	mov    %edx,-0x40(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01039b8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01039bb:	8b 00                	mov    (%eax),%eax
c01039bd:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01039c0:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01039c3:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01039c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01039c9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next->prev = elm;
c01039cc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01039cf:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01039d2:	89 10                	mov    %edx,(%eax)
c01039d4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01039d7:	8b 10                	mov    (%eax),%edx
c01039d9:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01039dc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01039df:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039e2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01039e5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01039e8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039eb:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01039ee:	89 10                	mov    %edx,(%eax)
}
c01039f0:	90                   	nop
}
c01039f1:	90                   	nop
    while(merge_backward(base));
c01039f2:	90                   	nop
c01039f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01039f6:	89 04 24             	mov    %eax,(%esp)
c01039f9:	e8 af fc ff ff       	call   c01036ad <merge_backward>
c01039fe:	85 c0                	test   %eax,%eax
c0103a00:	75 f1                	jne    c01039f3 <default_free_pages+0x196>
    while(merge_beforeward(base));
c0103a02:	90                   	nop
c0103a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a06:	89 04 24             	mov    %eax,(%esp)
c0103a09:	e8 73 fd ff ff       	call   c0103781 <merge_beforeward>
c0103a0e:	85 c0                	test   %eax,%eax
c0103a10:	75 f1                	jne    c0103a03 <default_free_pages+0x1a6>
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));*/


}
c0103a12:	90                   	nop
c0103a13:	90                   	nop
c0103a14:	89 ec                	mov    %ebp,%esp
c0103a16:	5d                   	pop    %ebp
c0103a17:	c3                   	ret    

c0103a18 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103a18:	55                   	push   %ebp
c0103a19:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103a1b:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
}
c0103a20:	5d                   	pop    %ebp
c0103a21:	c3                   	ret    

c0103a22 <basic_check>:

static void
basic_check(void) {
c0103a22:	55                   	push   %ebp
c0103a23:	89 e5                	mov    %esp,%ebp
c0103a25:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103a28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a38:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103a3b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a42:	e8 55 16 00 00       	call   c010509c <alloc_pages>
c0103a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a4a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103a4e:	75 24                	jne    c0103a74 <basic_check+0x52>
c0103a50:	c7 44 24 0c 99 aa 10 	movl   $0xc010aa99,0xc(%esp)
c0103a57:	c0 
c0103a58:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103a5f:	c0 
c0103a60:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
c0103a67:	00 
c0103a68:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103a6f:	e8 a2 d2 ff ff       	call   c0100d16 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103a74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a7b:	e8 1c 16 00 00       	call   c010509c <alloc_pages>
c0103a80:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a87:	75 24                	jne    c0103aad <basic_check+0x8b>
c0103a89:	c7 44 24 0c b5 aa 10 	movl   $0xc010aab5,0xc(%esp)
c0103a90:	c0 
c0103a91:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103a98:	c0 
c0103a99:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0103aa0:	00 
c0103aa1:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103aa8:	e8 69 d2 ff ff       	call   c0100d16 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103aad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ab4:	e8 e3 15 00 00       	call   c010509c <alloc_pages>
c0103ab9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103abc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ac0:	75 24                	jne    c0103ae6 <basic_check+0xc4>
c0103ac2:	c7 44 24 0c d1 aa 10 	movl   $0xc010aad1,0xc(%esp)
c0103ac9:	c0 
c0103aca:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103ad1:	c0 
c0103ad2:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0103ad9:	00 
c0103ada:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103ae1:	e8 30 d2 ff ff       	call   c0100d16 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ae9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103aec:	74 10                	je     c0103afe <basic_check+0xdc>
c0103aee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103af1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103af4:	74 08                	je     c0103afe <basic_check+0xdc>
c0103af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103af9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103afc:	75 24                	jne    c0103b22 <basic_check+0x100>
c0103afe:	c7 44 24 0c f0 aa 10 	movl   $0xc010aaf0,0xc(%esp)
c0103b05:	c0 
c0103b06:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103b0d:	c0 
c0103b0e:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0103b15:	00 
c0103b16:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103b1d:	e8 f4 d1 ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103b22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b25:	89 04 24             	mov    %eax,(%esp)
c0103b28:	e8 1d f8 ff ff       	call   c010334a <page_ref>
c0103b2d:	85 c0                	test   %eax,%eax
c0103b2f:	75 1e                	jne    c0103b4f <basic_check+0x12d>
c0103b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b34:	89 04 24             	mov    %eax,(%esp)
c0103b37:	e8 0e f8 ff ff       	call   c010334a <page_ref>
c0103b3c:	85 c0                	test   %eax,%eax
c0103b3e:	75 0f                	jne    c0103b4f <basic_check+0x12d>
c0103b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b43:	89 04 24             	mov    %eax,(%esp)
c0103b46:	e8 ff f7 ff ff       	call   c010334a <page_ref>
c0103b4b:	85 c0                	test   %eax,%eax
c0103b4d:	74 24                	je     c0103b73 <basic_check+0x151>
c0103b4f:	c7 44 24 0c 14 ab 10 	movl   $0xc010ab14,0xc(%esp)
c0103b56:	c0 
c0103b57:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103b5e:	c0 
c0103b5f:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0103b66:	00 
c0103b67:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103b6e:	e8 a3 d1 ff ff       	call   c0100d16 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b76:	89 04 24             	mov    %eax,(%esp)
c0103b79:	e8 b4 f7 ff ff       	call   c0103332 <page2pa>
c0103b7e:	8b 15 a4 bf 12 c0    	mov    0xc012bfa4,%edx
c0103b84:	c1 e2 0c             	shl    $0xc,%edx
c0103b87:	39 d0                	cmp    %edx,%eax
c0103b89:	72 24                	jb     c0103baf <basic_check+0x18d>
c0103b8b:	c7 44 24 0c 50 ab 10 	movl   $0xc010ab50,0xc(%esp)
c0103b92:	c0 
c0103b93:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103b9a:	c0 
c0103b9b:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0103ba2:	00 
c0103ba3:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103baa:	e8 67 d1 ff ff       	call   c0100d16 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bb2:	89 04 24             	mov    %eax,(%esp)
c0103bb5:	e8 78 f7 ff ff       	call   c0103332 <page2pa>
c0103bba:	8b 15 a4 bf 12 c0    	mov    0xc012bfa4,%edx
c0103bc0:	c1 e2 0c             	shl    $0xc,%edx
c0103bc3:	39 d0                	cmp    %edx,%eax
c0103bc5:	72 24                	jb     c0103beb <basic_check+0x1c9>
c0103bc7:	c7 44 24 0c 6d ab 10 	movl   $0xc010ab6d,0xc(%esp)
c0103bce:	c0 
c0103bcf:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103bd6:	c0 
c0103bd7:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
c0103bde:	00 
c0103bdf:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103be6:	e8 2b d1 ff ff       	call   c0100d16 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bee:	89 04 24             	mov    %eax,(%esp)
c0103bf1:	e8 3c f7 ff ff       	call   c0103332 <page2pa>
c0103bf6:	8b 15 a4 bf 12 c0    	mov    0xc012bfa4,%edx
c0103bfc:	c1 e2 0c             	shl    $0xc,%edx
c0103bff:	39 d0                	cmp    %edx,%eax
c0103c01:	72 24                	jb     c0103c27 <basic_check+0x205>
c0103c03:	c7 44 24 0c 8a ab 10 	movl   $0xc010ab8a,0xc(%esp)
c0103c0a:	c0 
c0103c0b:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103c12:	c0 
c0103c13:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0103c1a:	00 
c0103c1b:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103c22:	e8 ef d0 ff ff       	call   c0100d16 <__panic>

    list_entry_t free_list_store = free_list;
c0103c27:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c0103c2c:	8b 15 88 bf 12 c0    	mov    0xc012bf88,%edx
c0103c32:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103c35:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103c38:	c7 45 dc 84 bf 12 c0 	movl   $0xc012bf84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103c3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c42:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103c45:	89 50 04             	mov    %edx,0x4(%eax)
c0103c48:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c4b:	8b 50 04             	mov    0x4(%eax),%edx
c0103c4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c51:	89 10                	mov    %edx,(%eax)
}
c0103c53:	90                   	nop
c0103c54:	c7 45 e0 84 bf 12 c0 	movl   $0xc012bf84,-0x20(%ebp)
    return list->next == list;
c0103c5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c5e:	8b 40 04             	mov    0x4(%eax),%eax
c0103c61:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c64:	0f 94 c0             	sete   %al
c0103c67:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103c6a:	85 c0                	test   %eax,%eax
c0103c6c:	75 24                	jne    c0103c92 <basic_check+0x270>
c0103c6e:	c7 44 24 0c a7 ab 10 	movl   $0xc010aba7,0xc(%esp)
c0103c75:	c0 
c0103c76:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103c7d:	c0 
c0103c7e:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c0103c85:	00 
c0103c86:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103c8d:	e8 84 d0 ff ff       	call   c0100d16 <__panic>

    unsigned int nr_free_store = nr_free;
c0103c92:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103c97:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103c9a:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0103ca1:	00 00 00 

    assert(alloc_page() == NULL);
c0103ca4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cab:	e8 ec 13 00 00       	call   c010509c <alloc_pages>
c0103cb0:	85 c0                	test   %eax,%eax
c0103cb2:	74 24                	je     c0103cd8 <basic_check+0x2b6>
c0103cb4:	c7 44 24 0c be ab 10 	movl   $0xc010abbe,0xc(%esp)
c0103cbb:	c0 
c0103cbc:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103cc3:	c0 
c0103cc4:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
c0103ccb:	00 
c0103ccc:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103cd3:	e8 3e d0 ff ff       	call   c0100d16 <__panic>

    free_page(p0);
c0103cd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cdf:	00 
c0103ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ce3:	89 04 24             	mov    %eax,(%esp)
c0103ce6:	e8 1e 14 00 00       	call   c0105109 <free_pages>
    free_page(p1);
c0103ceb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cf2:	00 
c0103cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cf6:	89 04 24             	mov    %eax,(%esp)
c0103cf9:	e8 0b 14 00 00       	call   c0105109 <free_pages>
    free_page(p2);
c0103cfe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d05:	00 
c0103d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d09:	89 04 24             	mov    %eax,(%esp)
c0103d0c:	e8 f8 13 00 00       	call   c0105109 <free_pages>
    assert(nr_free == 3);
c0103d11:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103d16:	83 f8 03             	cmp    $0x3,%eax
c0103d19:	74 24                	je     c0103d3f <basic_check+0x31d>
c0103d1b:	c7 44 24 0c d3 ab 10 	movl   $0xc010abd3,0xc(%esp)
c0103d22:	c0 
c0103d23:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103d2a:	c0 
c0103d2b:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c0103d32:	00 
c0103d33:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103d3a:	e8 d7 cf ff ff       	call   c0100d16 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d46:	e8 51 13 00 00       	call   c010509c <alloc_pages>
c0103d4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d4e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d52:	75 24                	jne    c0103d78 <basic_check+0x356>
c0103d54:	c7 44 24 0c 99 aa 10 	movl   $0xc010aa99,0xc(%esp)
c0103d5b:	c0 
c0103d5c:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103d63:	c0 
c0103d64:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0103d6b:	00 
c0103d6c:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103d73:	e8 9e cf ff ff       	call   c0100d16 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103d78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d7f:	e8 18 13 00 00       	call   c010509c <alloc_pages>
c0103d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d8b:	75 24                	jne    c0103db1 <basic_check+0x38f>
c0103d8d:	c7 44 24 0c b5 aa 10 	movl   $0xc010aab5,0xc(%esp)
c0103d94:	c0 
c0103d95:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103d9c:	c0 
c0103d9d:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
c0103da4:	00 
c0103da5:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103dac:	e8 65 cf ff ff       	call   c0100d16 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103db1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103db8:	e8 df 12 00 00       	call   c010509c <alloc_pages>
c0103dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103dc0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103dc4:	75 24                	jne    c0103dea <basic_check+0x3c8>
c0103dc6:	c7 44 24 0c d1 aa 10 	movl   $0xc010aad1,0xc(%esp)
c0103dcd:	c0 
c0103dce:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103dd5:	c0 
c0103dd6:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
c0103ddd:	00 
c0103dde:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103de5:	e8 2c cf ff ff       	call   c0100d16 <__panic>

    assert(alloc_page() == NULL);
c0103dea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103df1:	e8 a6 12 00 00       	call   c010509c <alloc_pages>
c0103df6:	85 c0                	test   %eax,%eax
c0103df8:	74 24                	je     c0103e1e <basic_check+0x3fc>
c0103dfa:	c7 44 24 0c be ab 10 	movl   $0xc010abbe,0xc(%esp)
c0103e01:	c0 
c0103e02:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103e09:	c0 
c0103e0a:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c0103e11:	00 
c0103e12:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103e19:	e8 f8 ce ff ff       	call   c0100d16 <__panic>

    free_page(p0);
c0103e1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e25:	00 
c0103e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e29:	89 04 24             	mov    %eax,(%esp)
c0103e2c:	e8 d8 12 00 00       	call   c0105109 <free_pages>
c0103e31:	c7 45 d8 84 bf 12 c0 	movl   $0xc012bf84,-0x28(%ebp)
c0103e38:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e3b:	8b 40 04             	mov    0x4(%eax),%eax
c0103e3e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e41:	0f 94 c0             	sete   %al
c0103e44:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e47:	85 c0                	test   %eax,%eax
c0103e49:	74 24                	je     c0103e6f <basic_check+0x44d>
c0103e4b:	c7 44 24 0c e0 ab 10 	movl   $0xc010abe0,0xc(%esp)
c0103e52:	c0 
c0103e53:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103e5a:	c0 
c0103e5b:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
c0103e62:	00 
c0103e63:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103e6a:	e8 a7 ce ff ff       	call   c0100d16 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e76:	e8 21 12 00 00       	call   c010509c <alloc_pages>
c0103e7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e81:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e84:	74 24                	je     c0103eaa <basic_check+0x488>
c0103e86:	c7 44 24 0c f8 ab 10 	movl   $0xc010abf8,0xc(%esp)
c0103e8d:	c0 
c0103e8e:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103e95:	c0 
c0103e96:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c0103e9d:	00 
c0103e9e:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103ea5:	e8 6c ce ff ff       	call   c0100d16 <__panic>
    assert(alloc_page() == NULL);
c0103eaa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103eb1:	e8 e6 11 00 00       	call   c010509c <alloc_pages>
c0103eb6:	85 c0                	test   %eax,%eax
c0103eb8:	74 24                	je     c0103ede <basic_check+0x4bc>
c0103eba:	c7 44 24 0c be ab 10 	movl   $0xc010abbe,0xc(%esp)
c0103ec1:	c0 
c0103ec2:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103ec9:	c0 
c0103eca:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c0103ed1:	00 
c0103ed2:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103ed9:	e8 38 ce ff ff       	call   c0100d16 <__panic>

    assert(nr_free == 0);
c0103ede:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103ee3:	85 c0                	test   %eax,%eax
c0103ee5:	74 24                	je     c0103f0b <basic_check+0x4e9>
c0103ee7:	c7 44 24 0c 11 ac 10 	movl   $0xc010ac11,0xc(%esp)
c0103eee:	c0 
c0103eef:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103ef6:	c0 
c0103ef7:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c0103efe:	00 
c0103eff:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103f06:	e8 0b ce ff ff       	call   c0100d16 <__panic>
    free_list = free_list_store;
c0103f0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103f0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f11:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
c0103f16:	89 15 88 bf 12 c0    	mov    %edx,0xc012bf88
    nr_free = nr_free_store;
c0103f1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f1f:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c

    free_page(p);
c0103f24:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f2b:	00 
c0103f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f2f:	89 04 24             	mov    %eax,(%esp)
c0103f32:	e8 d2 11 00 00       	call   c0105109 <free_pages>
    free_page(p1);
c0103f37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f3e:	00 
c0103f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f42:	89 04 24             	mov    %eax,(%esp)
c0103f45:	e8 bf 11 00 00       	call   c0105109 <free_pages>
    free_page(p2);
c0103f4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f51:	00 
c0103f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f55:	89 04 24             	mov    %eax,(%esp)
c0103f58:	e8 ac 11 00 00       	call   c0105109 <free_pages>
}
c0103f5d:	90                   	nop
c0103f5e:	89 ec                	mov    %ebp,%esp
c0103f60:	5d                   	pop    %ebp
c0103f61:	c3                   	ret    

c0103f62 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103f62:	55                   	push   %ebp
c0103f63:	89 e5                	mov    %esp,%ebp
c0103f65:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103f6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f72:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103f79:	c7 45 ec 84 bf 12 c0 	movl   $0xc012bf84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103f80:	eb 6a                	jmp    c0103fec <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0103f82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f85:	83 e8 0c             	sub    $0xc,%eax
c0103f88:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103f8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f8e:	83 c0 04             	add    $0x4,%eax
c0103f91:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f98:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f9b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f9e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103fa1:	0f a3 10             	bt     %edx,(%eax)
c0103fa4:	19 c0                	sbb    %eax,%eax
c0103fa6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103fa9:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103fad:	0f 95 c0             	setne  %al
c0103fb0:	0f b6 c0             	movzbl %al,%eax
c0103fb3:	85 c0                	test   %eax,%eax
c0103fb5:	75 24                	jne    c0103fdb <default_check+0x79>
c0103fb7:	c7 44 24 0c 1e ac 10 	movl   $0xc010ac1e,0xc(%esp)
c0103fbe:	c0 
c0103fbf:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0103fc6:	c0 
c0103fc7:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0103fce:	00 
c0103fcf:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0103fd6:	e8 3b cd ff ff       	call   c0100d16 <__panic>
        count ++, total += p->property;
c0103fdb:	ff 45 f4             	incl   -0xc(%ebp)
c0103fde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103fe1:	8b 50 08             	mov    0x8(%eax),%edx
c0103fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fe7:	01 d0                	add    %edx,%eax
c0103fe9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fef:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103ff2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103ff5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103ff8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103ffb:	81 7d ec 84 bf 12 c0 	cmpl   $0xc012bf84,-0x14(%ebp)
c0104002:	0f 85 7a ff ff ff    	jne    c0103f82 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104008:	e8 31 11 00 00       	call   c010513e <nr_free_pages>
c010400d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104010:	39 d0                	cmp    %edx,%eax
c0104012:	74 24                	je     c0104038 <default_check+0xd6>
c0104014:	c7 44 24 0c 2e ac 10 	movl   $0xc010ac2e,0xc(%esp)
c010401b:	c0 
c010401c:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0104023:	c0 
c0104024:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c010402b:	00 
c010402c:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0104033:	e8 de cc ff ff       	call   c0100d16 <__panic>

    basic_check();
c0104038:	e8 e5 f9 ff ff       	call   c0103a22 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010403d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104044:	e8 53 10 00 00       	call   c010509c <alloc_pages>
c0104049:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010404c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104050:	75 24                	jne    c0104076 <default_check+0x114>
c0104052:	c7 44 24 0c 47 ac 10 	movl   $0xc010ac47,0xc(%esp)
c0104059:	c0 
c010405a:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0104061:	c0 
c0104062:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0104069:	00 
c010406a:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0104071:	e8 a0 cc ff ff       	call   c0100d16 <__panic>
    assert(!PageProperty(p0));
c0104076:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104079:	83 c0 04             	add    $0x4,%eax
c010407c:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104083:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104086:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104089:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010408c:	0f a3 10             	bt     %edx,(%eax)
c010408f:	19 c0                	sbb    %eax,%eax
c0104091:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104094:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104098:	0f 95 c0             	setne  %al
c010409b:	0f b6 c0             	movzbl %al,%eax
c010409e:	85 c0                	test   %eax,%eax
c01040a0:	74 24                	je     c01040c6 <default_check+0x164>
c01040a2:	c7 44 24 0c 52 ac 10 	movl   $0xc010ac52,0xc(%esp)
c01040a9:	c0 
c01040aa:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01040b1:	c0 
c01040b2:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c01040b9:	00 
c01040ba:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01040c1:	e8 50 cc ff ff       	call   c0100d16 <__panic>

    list_entry_t free_list_store = free_list;
c01040c6:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c01040cb:	8b 15 88 bf 12 c0    	mov    0xc012bf88,%edx
c01040d1:	89 45 80             	mov    %eax,-0x80(%ebp)
c01040d4:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01040d7:	c7 45 b0 84 bf 12 c0 	movl   $0xc012bf84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01040de:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040e1:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01040e4:	89 50 04             	mov    %edx,0x4(%eax)
c01040e7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040ea:	8b 50 04             	mov    0x4(%eax),%edx
c01040ed:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040f0:	89 10                	mov    %edx,(%eax)
}
c01040f2:	90                   	nop
c01040f3:	c7 45 b4 84 bf 12 c0 	movl   $0xc012bf84,-0x4c(%ebp)
    return list->next == list;
c01040fa:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01040fd:	8b 40 04             	mov    0x4(%eax),%eax
c0104100:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104103:	0f 94 c0             	sete   %al
c0104106:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104109:	85 c0                	test   %eax,%eax
c010410b:	75 24                	jne    c0104131 <default_check+0x1cf>
c010410d:	c7 44 24 0c a7 ab 10 	movl   $0xc010aba7,0xc(%esp)
c0104114:	c0 
c0104115:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010411c:	c0 
c010411d:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c0104124:	00 
c0104125:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010412c:	e8 e5 cb ff ff       	call   c0100d16 <__panic>
    assert(alloc_page() == NULL);
c0104131:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104138:	e8 5f 0f 00 00       	call   c010509c <alloc_pages>
c010413d:	85 c0                	test   %eax,%eax
c010413f:	74 24                	je     c0104165 <default_check+0x203>
c0104141:	c7 44 24 0c be ab 10 	movl   $0xc010abbe,0xc(%esp)
c0104148:	c0 
c0104149:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0104150:	c0 
c0104151:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c0104158:	00 
c0104159:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0104160:	e8 b1 cb ff ff       	call   c0100d16 <__panic>

    unsigned int nr_free_store = nr_free;
c0104165:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c010416a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010416d:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0104174:	00 00 00 

    free_pages(p0 + 2, 3);
c0104177:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010417a:	83 c0 40             	add    $0x40,%eax
c010417d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104184:	00 
c0104185:	89 04 24             	mov    %eax,(%esp)
c0104188:	e8 7c 0f 00 00       	call   c0105109 <free_pages>
    assert(alloc_pages(4) == NULL);
c010418d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104194:	e8 03 0f 00 00       	call   c010509c <alloc_pages>
c0104199:	85 c0                	test   %eax,%eax
c010419b:	74 24                	je     c01041c1 <default_check+0x25f>
c010419d:	c7 44 24 0c 64 ac 10 	movl   $0xc010ac64,0xc(%esp)
c01041a4:	c0 
c01041a5:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01041ac:	c0 
c01041ad:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c01041b4:	00 
c01041b5:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01041bc:	e8 55 cb ff ff       	call   c0100d16 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01041c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041c4:	83 c0 40             	add    $0x40,%eax
c01041c7:	83 c0 04             	add    $0x4,%eax
c01041ca:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01041d1:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041d4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01041d7:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01041da:	0f a3 10             	bt     %edx,(%eax)
c01041dd:	19 c0                	sbb    %eax,%eax
c01041df:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01041e2:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01041e6:	0f 95 c0             	setne  %al
c01041e9:	0f b6 c0             	movzbl %al,%eax
c01041ec:	85 c0                	test   %eax,%eax
c01041ee:	74 0e                	je     c01041fe <default_check+0x29c>
c01041f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041f3:	83 c0 40             	add    $0x40,%eax
c01041f6:	8b 40 08             	mov    0x8(%eax),%eax
c01041f9:	83 f8 03             	cmp    $0x3,%eax
c01041fc:	74 24                	je     c0104222 <default_check+0x2c0>
c01041fe:	c7 44 24 0c 7c ac 10 	movl   $0xc010ac7c,0xc(%esp)
c0104205:	c0 
c0104206:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010420d:	c0 
c010420e:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
c0104215:	00 
c0104216:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010421d:	e8 f4 ca ff ff       	call   c0100d16 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104222:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104229:	e8 6e 0e 00 00       	call   c010509c <alloc_pages>
c010422e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104231:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104235:	75 24                	jne    c010425b <default_check+0x2f9>
c0104237:	c7 44 24 0c a8 ac 10 	movl   $0xc010aca8,0xc(%esp)
c010423e:	c0 
c010423f:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0104246:	c0 
c0104247:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
c010424e:	00 
c010424f:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0104256:	e8 bb ca ff ff       	call   c0100d16 <__panic>
    assert(alloc_page() == NULL);
c010425b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104262:	e8 35 0e 00 00       	call   c010509c <alloc_pages>
c0104267:	85 c0                	test   %eax,%eax
c0104269:	74 24                	je     c010428f <default_check+0x32d>
c010426b:	c7 44 24 0c be ab 10 	movl   $0xc010abbe,0xc(%esp)
c0104272:	c0 
c0104273:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010427a:	c0 
c010427b:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c0104282:	00 
c0104283:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010428a:	e8 87 ca ff ff       	call   c0100d16 <__panic>
    assert(p0 + 2 == p1);
c010428f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104292:	83 c0 40             	add    $0x40,%eax
c0104295:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104298:	74 24                	je     c01042be <default_check+0x35c>
c010429a:	c7 44 24 0c c6 ac 10 	movl   $0xc010acc6,0xc(%esp)
c01042a1:	c0 
c01042a2:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01042a9:	c0 
c01042aa:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
c01042b1:	00 
c01042b2:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01042b9:	e8 58 ca ff ff       	call   c0100d16 <__panic>

    p2 = p0 + 1;
c01042be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042c1:	83 c0 20             	add    $0x20,%eax
c01042c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01042c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01042ce:	00 
c01042cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042d2:	89 04 24             	mov    %eax,(%esp)
c01042d5:	e8 2f 0e 00 00       	call   c0105109 <free_pages>
    free_pages(p1, 3);
c01042da:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01042e1:	00 
c01042e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042e5:	89 04 24             	mov    %eax,(%esp)
c01042e8:	e8 1c 0e 00 00       	call   c0105109 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01042ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042f0:	83 c0 04             	add    $0x4,%eax
c01042f3:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01042fa:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042fd:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104300:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104303:	0f a3 10             	bt     %edx,(%eax)
c0104306:	19 c0                	sbb    %eax,%eax
c0104308:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010430b:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010430f:	0f 95 c0             	setne  %al
c0104312:	0f b6 c0             	movzbl %al,%eax
c0104315:	85 c0                	test   %eax,%eax
c0104317:	74 0b                	je     c0104324 <default_check+0x3c2>
c0104319:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010431c:	8b 40 08             	mov    0x8(%eax),%eax
c010431f:	83 f8 01             	cmp    $0x1,%eax
c0104322:	74 24                	je     c0104348 <default_check+0x3e6>
c0104324:	c7 44 24 0c d4 ac 10 	movl   $0xc010acd4,0xc(%esp)
c010432b:	c0 
c010432c:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0104333:	c0 
c0104334:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c010433b:	00 
c010433c:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0104343:	e8 ce c9 ff ff       	call   c0100d16 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104348:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010434b:	83 c0 04             	add    $0x4,%eax
c010434e:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104355:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104358:	8b 45 90             	mov    -0x70(%ebp),%eax
c010435b:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010435e:	0f a3 10             	bt     %edx,(%eax)
c0104361:	19 c0                	sbb    %eax,%eax
c0104363:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104366:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010436a:	0f 95 c0             	setne  %al
c010436d:	0f b6 c0             	movzbl %al,%eax
c0104370:	85 c0                	test   %eax,%eax
c0104372:	74 0b                	je     c010437f <default_check+0x41d>
c0104374:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104377:	8b 40 08             	mov    0x8(%eax),%eax
c010437a:	83 f8 03             	cmp    $0x3,%eax
c010437d:	74 24                	je     c01043a3 <default_check+0x441>
c010437f:	c7 44 24 0c fc ac 10 	movl   $0xc010acfc,0xc(%esp)
c0104386:	c0 
c0104387:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010438e:	c0 
c010438f:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
c0104396:	00 
c0104397:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010439e:	e8 73 c9 ff ff       	call   c0100d16 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01043a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043aa:	e8 ed 0c 00 00       	call   c010509c <alloc_pages>
c01043af:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043b5:	83 e8 20             	sub    $0x20,%eax
c01043b8:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01043bb:	74 24                	je     c01043e1 <default_check+0x47f>
c01043bd:	c7 44 24 0c 22 ad 10 	movl   $0xc010ad22,0xc(%esp)
c01043c4:	c0 
c01043c5:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01043cc:	c0 
c01043cd:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
c01043d4:	00 
c01043d5:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01043dc:	e8 35 c9 ff ff       	call   c0100d16 <__panic>
    free_page(p0);
c01043e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043e8:	00 
c01043e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043ec:	89 04 24             	mov    %eax,(%esp)
c01043ef:	e8 15 0d 00 00       	call   c0105109 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01043f4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01043fb:	e8 9c 0c 00 00       	call   c010509c <alloc_pages>
c0104400:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104403:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104406:	83 c0 20             	add    $0x20,%eax
c0104409:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010440c:	74 24                	je     c0104432 <default_check+0x4d0>
c010440e:	c7 44 24 0c 40 ad 10 	movl   $0xc010ad40,0xc(%esp)
c0104415:	c0 
c0104416:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010441d:	c0 
c010441e:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
c0104425:	00 
c0104426:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010442d:	e8 e4 c8 ff ff       	call   c0100d16 <__panic>

    free_pages(p0, 2);
c0104432:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104439:	00 
c010443a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010443d:	89 04 24             	mov    %eax,(%esp)
c0104440:	e8 c4 0c 00 00       	call   c0105109 <free_pages>
    free_page(p2);
c0104445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010444c:	00 
c010444d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104450:	89 04 24             	mov    %eax,(%esp)
c0104453:	e8 b1 0c 00 00       	call   c0105109 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104458:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010445f:	e8 38 0c 00 00       	call   c010509c <alloc_pages>
c0104464:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104467:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010446b:	75 24                	jne    c0104491 <default_check+0x52f>
c010446d:	c7 44 24 0c 60 ad 10 	movl   $0xc010ad60,0xc(%esp)
c0104474:	c0 
c0104475:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c010447c:	c0 
c010447d:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
c0104484:	00 
c0104485:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c010448c:	e8 85 c8 ff ff       	call   c0100d16 <__panic>
    assert(alloc_page() == NULL);
c0104491:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104498:	e8 ff 0b 00 00       	call   c010509c <alloc_pages>
c010449d:	85 c0                	test   %eax,%eax
c010449f:	74 24                	je     c01044c5 <default_check+0x563>
c01044a1:	c7 44 24 0c be ab 10 	movl   $0xc010abbe,0xc(%esp)
c01044a8:	c0 
c01044a9:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01044b0:	c0 
c01044b1:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c01044b8:	00 
c01044b9:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01044c0:	e8 51 c8 ff ff       	call   c0100d16 <__panic>

    assert(nr_free == 0);
c01044c5:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c01044ca:	85 c0                	test   %eax,%eax
c01044cc:	74 24                	je     c01044f2 <default_check+0x590>
c01044ce:	c7 44 24 0c 11 ac 10 	movl   $0xc010ac11,0xc(%esp)
c01044d5:	c0 
c01044d6:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01044dd:	c0 
c01044de:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c01044e5:	00 
c01044e6:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01044ed:	e8 24 c8 ff ff       	call   c0100d16 <__panic>
    nr_free = nr_free_store;
c01044f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044f5:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c

    free_list = free_list_store;
c01044fa:	8b 45 80             	mov    -0x80(%ebp),%eax
c01044fd:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104500:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
c0104505:	89 15 88 bf 12 c0    	mov    %edx,0xc012bf88
    free_pages(p0, 5);
c010450b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104512:	00 
c0104513:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104516:	89 04 24             	mov    %eax,(%esp)
c0104519:	e8 eb 0b 00 00       	call   c0105109 <free_pages>

    le = &free_list;
c010451e:	c7 45 ec 84 bf 12 c0 	movl   $0xc012bf84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104525:	eb 5a                	jmp    c0104581 <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c0104527:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010452a:	8b 40 04             	mov    0x4(%eax),%eax
c010452d:	8b 00                	mov    (%eax),%eax
c010452f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104532:	75 0d                	jne    c0104541 <default_check+0x5df>
c0104534:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104537:	8b 00                	mov    (%eax),%eax
c0104539:	8b 40 04             	mov    0x4(%eax),%eax
c010453c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010453f:	74 24                	je     c0104565 <default_check+0x603>
c0104541:	c7 44 24 0c 80 ad 10 	movl   $0xc010ad80,0xc(%esp)
c0104548:	c0 
c0104549:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c0104550:	c0 
c0104551:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
c0104558:	00 
c0104559:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c0104560:	e8 b1 c7 ff ff       	call   c0100d16 <__panic>
        struct Page *p = le2page(le, page_link);
c0104565:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104568:	83 e8 0c             	sub    $0xc,%eax
c010456b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c010456e:	ff 4d f4             	decl   -0xc(%ebp)
c0104571:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104574:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104577:	8b 48 08             	mov    0x8(%eax),%ecx
c010457a:	89 d0                	mov    %edx,%eax
c010457c:	29 c8                	sub    %ecx,%eax
c010457e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104581:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104584:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0104587:	8b 45 88             	mov    -0x78(%ebp),%eax
c010458a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010458d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104590:	81 7d ec 84 bf 12 c0 	cmpl   $0xc012bf84,-0x14(%ebp)
c0104597:	75 8e                	jne    c0104527 <default_check+0x5c5>
    }
    assert(count == 0);
c0104599:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010459d:	74 24                	je     c01045c3 <default_check+0x661>
c010459f:	c7 44 24 0c ad ad 10 	movl   $0xc010adad,0xc(%esp)
c01045a6:	c0 
c01045a7:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01045ae:	c0 
c01045af:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c01045b6:	00 
c01045b7:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01045be:	e8 53 c7 ff ff       	call   c0100d16 <__panic>
    assert(total == 0);
c01045c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01045c7:	74 24                	je     c01045ed <default_check+0x68b>
c01045c9:	c7 44 24 0c b8 ad 10 	movl   $0xc010adb8,0xc(%esp)
c01045d0:	c0 
c01045d1:	c7 44 24 08 36 aa 10 	movl   $0xc010aa36,0x8(%esp)
c01045d8:	c0 
c01045d9:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c01045e0:	00 
c01045e1:	c7 04 24 4b aa 10 c0 	movl   $0xc010aa4b,(%esp)
c01045e8:	e8 29 c7 ff ff       	call   c0100d16 <__panic>
}
c01045ed:	90                   	nop
c01045ee:	89 ec                	mov    %ebp,%esp
c01045f0:	5d                   	pop    %ebp
c01045f1:	c3                   	ret    

c01045f2 <__intr_save>:
__intr_save(void) {
c01045f2:	55                   	push   %ebp
c01045f3:	89 e5                	mov    %esp,%ebp
c01045f5:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01045f8:	9c                   	pushf  
c01045f9:	58                   	pop    %eax
c01045fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01045fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104600:	25 00 02 00 00       	and    $0x200,%eax
c0104605:	85 c0                	test   %eax,%eax
c0104607:	74 0c                	je     c0104615 <__intr_save+0x23>
        intr_disable();
c0104609:	e8 be d9 ff ff       	call   c0101fcc <intr_disable>
        return 1;
c010460e:	b8 01 00 00 00       	mov    $0x1,%eax
c0104613:	eb 05                	jmp    c010461a <__intr_save+0x28>
    return 0;
c0104615:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010461a:	89 ec                	mov    %ebp,%esp
c010461c:	5d                   	pop    %ebp
c010461d:	c3                   	ret    

c010461e <__intr_restore>:
__intr_restore(bool flag) {
c010461e:	55                   	push   %ebp
c010461f:	89 e5                	mov    %esp,%ebp
c0104621:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104624:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104628:	74 05                	je     c010462f <__intr_restore+0x11>
        intr_enable();
c010462a:	e8 95 d9 ff ff       	call   c0101fc4 <intr_enable>
}
c010462f:	90                   	nop
c0104630:	89 ec                	mov    %ebp,%esp
c0104632:	5d                   	pop    %ebp
c0104633:	c3                   	ret    

c0104634 <page2ppn>:
page2ppn(struct Page *page) {
c0104634:	55                   	push   %ebp
c0104635:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104637:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c010463d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104640:	29 d0                	sub    %edx,%eax
c0104642:	c1 f8 05             	sar    $0x5,%eax
}
c0104645:	5d                   	pop    %ebp
c0104646:	c3                   	ret    

c0104647 <page2pa>:
page2pa(struct Page *page) {
c0104647:	55                   	push   %ebp
c0104648:	89 e5                	mov    %esp,%ebp
c010464a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010464d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104650:	89 04 24             	mov    %eax,(%esp)
c0104653:	e8 dc ff ff ff       	call   c0104634 <page2ppn>
c0104658:	c1 e0 0c             	shl    $0xc,%eax
}
c010465b:	89 ec                	mov    %ebp,%esp
c010465d:	5d                   	pop    %ebp
c010465e:	c3                   	ret    

c010465f <pa2page>:
pa2page(uintptr_t pa) {
c010465f:	55                   	push   %ebp
c0104660:	89 e5                	mov    %esp,%ebp
c0104662:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104665:	8b 45 08             	mov    0x8(%ebp),%eax
c0104668:	c1 e8 0c             	shr    $0xc,%eax
c010466b:	89 c2                	mov    %eax,%edx
c010466d:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104672:	39 c2                	cmp    %eax,%edx
c0104674:	72 1c                	jb     c0104692 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104676:	c7 44 24 08 f4 ad 10 	movl   $0xc010adf4,0x8(%esp)
c010467d:	c0 
c010467e:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104685:	00 
c0104686:	c7 04 24 13 ae 10 c0 	movl   $0xc010ae13,(%esp)
c010468d:	e8 84 c6 ff ff       	call   c0100d16 <__panic>
    return &pages[PPN(pa)];
c0104692:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104698:	8b 45 08             	mov    0x8(%ebp),%eax
c010469b:	c1 e8 0c             	shr    $0xc,%eax
c010469e:	c1 e0 05             	shl    $0x5,%eax
c01046a1:	01 d0                	add    %edx,%eax
}
c01046a3:	89 ec                	mov    %ebp,%esp
c01046a5:	5d                   	pop    %ebp
c01046a6:	c3                   	ret    

c01046a7 <page2kva>:
page2kva(struct Page *page) {
c01046a7:	55                   	push   %ebp
c01046a8:	89 e5                	mov    %esp,%ebp
c01046aa:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01046ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b0:	89 04 24             	mov    %eax,(%esp)
c01046b3:	e8 8f ff ff ff       	call   c0104647 <page2pa>
c01046b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046be:	c1 e8 0c             	shr    $0xc,%eax
c01046c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046c4:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01046c9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01046cc:	72 23                	jb     c01046f1 <page2kva+0x4a>
c01046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046d5:	c7 44 24 08 24 ae 10 	movl   $0xc010ae24,0x8(%esp)
c01046dc:	c0 
c01046dd:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01046e4:	00 
c01046e5:	c7 04 24 13 ae 10 c0 	movl   $0xc010ae13,(%esp)
c01046ec:	e8 25 c6 ff ff       	call   c0100d16 <__panic>
c01046f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046f4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01046f9:	89 ec                	mov    %ebp,%esp
c01046fb:	5d                   	pop    %ebp
c01046fc:	c3                   	ret    

c01046fd <kva2page>:
kva2page(void *kva) {
c01046fd:	55                   	push   %ebp
c01046fe:	89 e5                	mov    %esp,%ebp
c0104700:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104703:	8b 45 08             	mov    0x8(%ebp),%eax
c0104706:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104709:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104710:	77 23                	ja     c0104735 <kva2page+0x38>
c0104712:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104715:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104719:	c7 44 24 08 48 ae 10 	movl   $0xc010ae48,0x8(%esp)
c0104720:	c0 
c0104721:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0104728:	00 
c0104729:	c7 04 24 13 ae 10 c0 	movl   $0xc010ae13,(%esp)
c0104730:	e8 e1 c5 ff ff       	call   c0100d16 <__panic>
c0104735:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104738:	05 00 00 00 40       	add    $0x40000000,%eax
c010473d:	89 04 24             	mov    %eax,(%esp)
c0104740:	e8 1a ff ff ff       	call   c010465f <pa2page>
}
c0104745:	89 ec                	mov    %ebp,%esp
c0104747:	5d                   	pop    %ebp
c0104748:	c3                   	ret    

c0104749 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104749:	55                   	push   %ebp
c010474a:	89 e5                	mov    %esp,%ebp
c010474c:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c010474f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104752:	ba 01 00 00 00       	mov    $0x1,%edx
c0104757:	88 c1                	mov    %al,%cl
c0104759:	d3 e2                	shl    %cl,%edx
c010475b:	89 d0                	mov    %edx,%eax
c010475d:	89 04 24             	mov    %eax,(%esp)
c0104760:	e8 37 09 00 00       	call   c010509c <alloc_pages>
c0104765:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104768:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010476c:	75 07                	jne    c0104775 <__slob_get_free_pages+0x2c>
    return NULL;
c010476e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104773:	eb 0b                	jmp    c0104780 <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104778:	89 04 24             	mov    %eax,(%esp)
c010477b:	e8 27 ff ff ff       	call   c01046a7 <page2kva>
}
c0104780:	89 ec                	mov    %ebp,%esp
c0104782:	5d                   	pop    %ebp
c0104783:	c3                   	ret    

c0104784 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104784:	55                   	push   %ebp
c0104785:	89 e5                	mov    %esp,%ebp
c0104787:	83 ec 18             	sub    $0x18,%esp
c010478a:	89 5d fc             	mov    %ebx,-0x4(%ebp)
  free_pages(kva2page(kva), 1 << order);
c010478d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104790:	ba 01 00 00 00       	mov    $0x1,%edx
c0104795:	88 c1                	mov    %al,%cl
c0104797:	d3 e2                	shl    %cl,%edx
c0104799:	89 d0                	mov    %edx,%eax
c010479b:	89 c3                	mov    %eax,%ebx
c010479d:	8b 45 08             	mov    0x8(%ebp),%eax
c01047a0:	89 04 24             	mov    %eax,(%esp)
c01047a3:	e8 55 ff ff ff       	call   c01046fd <kva2page>
c01047a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01047ac:	89 04 24             	mov    %eax,(%esp)
c01047af:	e8 55 09 00 00       	call   c0105109 <free_pages>
}
c01047b4:	90                   	nop
c01047b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01047b8:	89 ec                	mov    %ebp,%esp
c01047ba:	5d                   	pop    %ebp
c01047bb:	c3                   	ret    

c01047bc <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c01047bc:	55                   	push   %ebp
c01047bd:	89 e5                	mov    %esp,%ebp
c01047bf:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01047c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01047c5:	83 c0 08             	add    $0x8,%eax
c01047c8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01047cd:	76 24                	jbe    c01047f3 <slob_alloc+0x37>
c01047cf:	c7 44 24 0c 6c ae 10 	movl   $0xc010ae6c,0xc(%esp)
c01047d6:	c0 
c01047d7:	c7 44 24 08 8b ae 10 	movl   $0xc010ae8b,0x8(%esp)
c01047de:	c0 
c01047df:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01047e6:	00 
c01047e7:	c7 04 24 a0 ae 10 c0 	movl   $0xc010aea0,(%esp)
c01047ee:	e8 23 c5 ff ff       	call   c0100d16 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01047f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01047fa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104801:	8b 45 08             	mov    0x8(%ebp),%eax
c0104804:	83 c0 07             	add    $0x7,%eax
c0104807:	c1 e8 03             	shr    $0x3,%eax
c010480a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c010480d:	e8 e0 fd ff ff       	call   c01045f2 <__intr_save>
c0104812:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104815:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c010481a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010481d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104820:	8b 40 04             	mov    0x4(%eax),%eax
c0104823:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104826:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010482a:	74 21                	je     c010484d <slob_alloc+0x91>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010482c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010482f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104832:	01 d0                	add    %edx,%eax
c0104834:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104837:	8b 45 10             	mov    0x10(%ebp),%eax
c010483a:	f7 d8                	neg    %eax
c010483c:	21 d0                	and    %edx,%eax
c010483e:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104841:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104844:	2b 45 f0             	sub    -0x10(%ebp),%eax
c0104847:	c1 f8 03             	sar    $0x3,%eax
c010484a:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c010484d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104850:	8b 00                	mov    (%eax),%eax
c0104852:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104855:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104858:	01 ca                	add    %ecx,%edx
c010485a:	39 d0                	cmp    %edx,%eax
c010485c:	0f 8c aa 00 00 00    	jl     c010490c <slob_alloc+0x150>
			if (delta) { /* need to fragment head to align? */
c0104862:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104866:	74 38                	je     c01048a0 <slob_alloc+0xe4>
				aligned->units = cur->units - delta;
c0104868:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010486b:	8b 00                	mov    (%eax),%eax
c010486d:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104870:	89 c2                	mov    %eax,%edx
c0104872:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104875:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104877:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010487a:	8b 50 04             	mov    0x4(%eax),%edx
c010487d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104880:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104883:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104886:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104889:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c010488c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104892:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104894:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104897:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c010489a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010489d:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01048a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048a3:	8b 00                	mov    (%eax),%eax
c01048a5:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01048a8:	75 0e                	jne    c01048b8 <slob_alloc+0xfc>
				prev->next = cur->next; /* unlink */
c01048aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048ad:	8b 50 04             	mov    0x4(%eax),%edx
c01048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048b3:	89 50 04             	mov    %edx,0x4(%eax)
c01048b6:	eb 3c                	jmp    c01048f4 <slob_alloc+0x138>
			else { /* fragment */
				prev->next = cur + units;
c01048b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01048c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048c5:	01 c2                	add    %eax,%edx
c01048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ca:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01048cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048d0:	8b 10                	mov    (%eax),%edx
c01048d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d5:	8b 40 04             	mov    0x4(%eax),%eax
c01048d8:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01048db:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c01048dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e0:	8b 40 04             	mov    0x4(%eax),%eax
c01048e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048e6:	8b 52 04             	mov    0x4(%edx),%edx
c01048e9:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c01048ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048f2:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c01048f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f7:	a3 e8 89 12 c0       	mov    %eax,0xc01289e8
			spin_unlock_irqrestore(&slob_lock, flags);
c01048fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048ff:	89 04 24             	mov    %eax,(%esp)
c0104902:	e8 17 fd ff ff       	call   c010461e <__intr_restore>
			return cur;
c0104907:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010490a:	eb 7f                	jmp    c010498b <slob_alloc+0x1cf>
		}
		if (cur == slobfree) {
c010490c:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0104911:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104914:	75 61                	jne    c0104977 <slob_alloc+0x1bb>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104919:	89 04 24             	mov    %eax,(%esp)
c010491c:	e8 fd fc ff ff       	call   c010461e <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104921:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104928:	75 07                	jne    c0104931 <slob_alloc+0x175>
				return 0;
c010492a:	b8 00 00 00 00       	mov    $0x0,%eax
c010492f:	eb 5a                	jmp    c010498b <slob_alloc+0x1cf>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104931:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104938:	00 
c0104939:	8b 45 0c             	mov    0xc(%ebp),%eax
c010493c:	89 04 24             	mov    %eax,(%esp)
c010493f:	e8 05 fe ff ff       	call   c0104749 <__slob_get_free_pages>
c0104944:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104947:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010494b:	75 07                	jne    c0104954 <slob_alloc+0x198>
				return 0;
c010494d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104952:	eb 37                	jmp    c010498b <slob_alloc+0x1cf>

			slob_free(cur, PAGE_SIZE);
c0104954:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010495b:	00 
c010495c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010495f:	89 04 24             	mov    %eax,(%esp)
c0104962:	e8 28 00 00 00       	call   c010498f <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104967:	e8 86 fc ff ff       	call   c01045f2 <__intr_save>
c010496c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c010496f:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0104974:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104977:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010497a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010497d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104980:	8b 40 04             	mov    0x4(%eax),%eax
c0104983:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104986:	e9 9b fe ff ff       	jmp    c0104826 <slob_alloc+0x6a>
		}
	}
}
c010498b:	89 ec                	mov    %ebp,%esp
c010498d:	5d                   	pop    %ebp
c010498e:	c3                   	ret    

c010498f <slob_free>:

static void slob_free(void *block, int size)
{
c010498f:	55                   	push   %ebp
c0104990:	89 e5                	mov    %esp,%ebp
c0104992:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104995:	8b 45 08             	mov    0x8(%ebp),%eax
c0104998:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010499b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010499f:	0f 84 01 01 00 00    	je     c0104aa6 <slob_free+0x117>
		return;

	if (size)
c01049a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01049a9:	74 10                	je     c01049bb <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c01049ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049ae:	83 c0 07             	add    $0x7,%eax
c01049b1:	c1 e8 03             	shr    $0x3,%eax
c01049b4:	89 c2                	mov    %eax,%edx
c01049b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049b9:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01049bb:	e8 32 fc ff ff       	call   c01045f2 <__intr_save>
c01049c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01049c3:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c01049c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049cb:	eb 27                	jmp    c01049f4 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01049cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d0:	8b 40 04             	mov    0x4(%eax),%eax
c01049d3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01049d6:	72 13                	jb     c01049eb <slob_free+0x5c>
c01049d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049db:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049de:	77 27                	ja     c0104a07 <slob_free+0x78>
c01049e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049e3:	8b 40 04             	mov    0x4(%eax),%eax
c01049e6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01049e9:	72 1c                	jb     c0104a07 <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01049eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ee:	8b 40 04             	mov    0x4(%eax),%eax
c01049f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049f7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049fa:	76 d1                	jbe    c01049cd <slob_free+0x3e>
c01049fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ff:	8b 40 04             	mov    0x4(%eax),%eax
c0104a02:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104a05:	73 c6                	jae    c01049cd <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c0104a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a0a:	8b 00                	mov    (%eax),%eax
c0104a0c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a16:	01 c2                	add    %eax,%edx
c0104a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a1b:	8b 40 04             	mov    0x4(%eax),%eax
c0104a1e:	39 c2                	cmp    %eax,%edx
c0104a20:	75 25                	jne    c0104a47 <slob_free+0xb8>
		b->units += cur->next->units;
c0104a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a25:	8b 10                	mov    (%eax),%edx
c0104a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a2a:	8b 40 04             	mov    0x4(%eax),%eax
c0104a2d:	8b 00                	mov    (%eax),%eax
c0104a2f:	01 c2                	add    %eax,%edx
c0104a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a34:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a39:	8b 40 04             	mov    0x4(%eax),%eax
c0104a3c:	8b 50 04             	mov    0x4(%eax),%edx
c0104a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a42:	89 50 04             	mov    %edx,0x4(%eax)
c0104a45:	eb 0c                	jmp    c0104a53 <slob_free+0xc4>
	} else
		b->next = cur->next;
c0104a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a4a:	8b 50 04             	mov    0x4(%eax),%edx
c0104a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a50:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a56:	8b 00                	mov    (%eax),%eax
c0104a58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a62:	01 d0                	add    %edx,%eax
c0104a64:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104a67:	75 1f                	jne    c0104a88 <slob_free+0xf9>
		cur->units += b->units;
c0104a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a6c:	8b 10                	mov    (%eax),%edx
c0104a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a71:	8b 00                	mov    (%eax),%eax
c0104a73:	01 c2                	add    %eax,%edx
c0104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a78:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a7d:	8b 50 04             	mov    0x4(%eax),%edx
c0104a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a83:	89 50 04             	mov    %edx,0x4(%eax)
c0104a86:	eb 09                	jmp    c0104a91 <slob_free+0x102>
	} else
		cur->next = b;
c0104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a8e:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a94:	a3 e8 89 12 c0       	mov    %eax,0xc01289e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0104a99:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a9c:	89 04 24             	mov    %eax,(%esp)
c0104a9f:	e8 7a fb ff ff       	call   c010461e <__intr_restore>
c0104aa4:	eb 01                	jmp    c0104aa7 <slob_free+0x118>
		return;
c0104aa6:	90                   	nop
}
c0104aa7:	89 ec                	mov    %ebp,%esp
c0104aa9:	5d                   	pop    %ebp
c0104aaa:	c3                   	ret    

c0104aab <slob_init>:



void
slob_init(void) {
c0104aab:	55                   	push   %ebp
c0104aac:	89 e5                	mov    %esp,%ebp
c0104aae:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104ab1:	c7 04 24 b2 ae 10 c0 	movl   $0xc010aeb2,(%esp)
c0104ab8:	e8 b0 b8 ff ff       	call   c010036d <cprintf>
}
c0104abd:	90                   	nop
c0104abe:	89 ec                	mov    %ebp,%esp
c0104ac0:	5d                   	pop    %ebp
c0104ac1:	c3                   	ret    

c0104ac2 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104ac2:	55                   	push   %ebp
c0104ac3:	89 e5                	mov    %esp,%ebp
c0104ac5:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104ac8:	e8 de ff ff ff       	call   c0104aab <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104acd:	c7 04 24 c6 ae 10 c0 	movl   $0xc010aec6,(%esp)
c0104ad4:	e8 94 b8 ff ff       	call   c010036d <cprintf>
}
c0104ad9:	90                   	nop
c0104ada:	89 ec                	mov    %ebp,%esp
c0104adc:	5d                   	pop    %ebp
c0104add:	c3                   	ret    

c0104ade <slob_allocated>:

size_t
slob_allocated(void) {
c0104ade:	55                   	push   %ebp
c0104adf:	89 e5                	mov    %esp,%ebp
  return 0;
c0104ae1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ae6:	5d                   	pop    %ebp
c0104ae7:	c3                   	ret    

c0104ae8 <kallocated>:

size_t
kallocated(void) {
c0104ae8:	55                   	push   %ebp
c0104ae9:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104aeb:	e8 ee ff ff ff       	call   c0104ade <slob_allocated>
}
c0104af0:	5d                   	pop    %ebp
c0104af1:	c3                   	ret    

c0104af2 <find_order>:

static int find_order(int size)
{
c0104af2:	55                   	push   %ebp
c0104af3:	89 e5                	mov    %esp,%ebp
c0104af5:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104af8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104aff:	eb 06                	jmp    c0104b07 <find_order+0x15>
		order++;
c0104b01:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104b04:	d1 7d 08             	sarl   0x8(%ebp)
c0104b07:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104b0e:	7f f1                	jg     c0104b01 <find_order+0xf>
	return order;
c0104b10:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104b13:	89 ec                	mov    %ebp,%esp
c0104b15:	5d                   	pop    %ebp
c0104b16:	c3                   	ret    

c0104b17 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104b17:	55                   	push   %ebp
c0104b18:	89 e5                	mov    %esp,%ebp
c0104b1a:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104b1d:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104b24:	77 3b                	ja     c0104b61 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104b26:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b29:	8d 50 08             	lea    0x8(%eax),%edx
c0104b2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b33:	00 
c0104b34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b3b:	89 14 24             	mov    %edx,(%esp)
c0104b3e:	e8 79 fc ff ff       	call   c01047bc <slob_alloc>
c0104b43:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104b46:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104b4a:	74 0b                	je     c0104b57 <__kmalloc+0x40>
c0104b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b4f:	83 c0 08             	add    $0x8,%eax
c0104b52:	e9 b0 00 00 00       	jmp    c0104c07 <__kmalloc+0xf0>
c0104b57:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b5c:	e9 a6 00 00 00       	jmp    c0104c07 <__kmalloc+0xf0>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104b61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b68:	00 
c0104b69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b70:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104b77:	e8 40 fc ff ff       	call   c01047bc <slob_alloc>
c0104b7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0104b7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b83:	75 07                	jne    c0104b8c <__kmalloc+0x75>
		return 0;
c0104b85:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b8a:	eb 7b                	jmp    c0104c07 <__kmalloc+0xf0>

	bb->order = find_order(size);
c0104b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b8f:	89 04 24             	mov    %eax,(%esp)
c0104b92:	e8 5b ff ff ff       	call   c0104af2 <find_order>
c0104b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b9a:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b9f:	8b 00                	mov    (%eax),%eax
c0104ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ba8:	89 04 24             	mov    %eax,(%esp)
c0104bab:	e8 99 fb ff ff       	call   c0104749 <__slob_get_free_pages>
c0104bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104bb3:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bb9:	8b 40 04             	mov    0x4(%eax),%eax
c0104bbc:	85 c0                	test   %eax,%eax
c0104bbe:	74 2f                	je     c0104bef <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c0104bc0:	e8 2d fa ff ff       	call   c01045f2 <__intr_save>
c0104bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0104bc8:	8b 15 90 bf 12 c0    	mov    0xc012bf90,%edx
c0104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd1:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd7:	a3 90 bf 12 c0       	mov    %eax,0xc012bf90
		spin_unlock_irqrestore(&block_lock, flags);
c0104bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bdf:	89 04 24             	mov    %eax,(%esp)
c0104be2:	e8 37 fa ff ff       	call   c010461e <__intr_restore>
		return bb->pages;
c0104be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bea:	8b 40 04             	mov    0x4(%eax),%eax
c0104bed:	eb 18                	jmp    c0104c07 <__kmalloc+0xf0>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104bef:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104bf6:	00 
c0104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bfa:	89 04 24             	mov    %eax,(%esp)
c0104bfd:	e8 8d fd ff ff       	call   c010498f <slob_free>
	return 0;
c0104c02:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104c07:	89 ec                	mov    %ebp,%esp
c0104c09:	5d                   	pop    %ebp
c0104c0a:	c3                   	ret    

c0104c0b <kmalloc>:

void *
kmalloc(size_t size)
{
c0104c0b:	55                   	push   %ebp
c0104c0c:	89 e5                	mov    %esp,%ebp
c0104c0e:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104c11:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c18:	00 
c0104c19:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c1c:	89 04 24             	mov    %eax,(%esp)
c0104c1f:	e8 f3 fe ff ff       	call   c0104b17 <__kmalloc>
}
c0104c24:	89 ec                	mov    %ebp,%esp
c0104c26:	5d                   	pop    %ebp
c0104c27:	c3                   	ret    

c0104c28 <kfree>:


void kfree(void *block)
{
c0104c28:	55                   	push   %ebp
c0104c29:	89 e5                	mov    %esp,%ebp
c0104c2b:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104c2e:	c7 45 f0 90 bf 12 c0 	movl   $0xc012bf90,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104c35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c39:	0f 84 a3 00 00 00    	je     c0104ce2 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c42:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c47:	85 c0                	test   %eax,%eax
c0104c49:	75 7f                	jne    c0104cca <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104c4b:	e8 a2 f9 ff ff       	call   c01045f2 <__intr_save>
c0104c50:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104c53:	a1 90 bf 12 c0       	mov    0xc012bf90,%eax
c0104c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c5b:	eb 5c                	jmp    c0104cb9 <kfree+0x91>
			if (bb->pages == block) {
c0104c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c60:	8b 40 04             	mov    0x4(%eax),%eax
c0104c63:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104c66:	75 3f                	jne    c0104ca7 <kfree+0x7f>
				*last = bb->next;
c0104c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c6b:	8b 50 08             	mov    0x8(%eax),%edx
c0104c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c71:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c76:	89 04 24             	mov    %eax,(%esp)
c0104c79:	e8 a0 f9 ff ff       	call   c010461e <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c81:	8b 10                	mov    (%eax),%edx
c0104c83:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c86:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c8a:	89 04 24             	mov    %eax,(%esp)
c0104c8d:	e8 f2 fa ff ff       	call   c0104784 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104c92:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104c99:	00 
c0104c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c9d:	89 04 24             	mov    %eax,(%esp)
c0104ca0:	e8 ea fc ff ff       	call   c010498f <slob_free>
				return;
c0104ca5:	eb 3c                	jmp    c0104ce3 <kfree+0xbb>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104caa:	83 c0 08             	add    $0x8,%eax
c0104cad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cb3:	8b 40 08             	mov    0x8(%eax),%eax
c0104cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104cb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104cbd:	75 9e                	jne    c0104c5d <kfree+0x35>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cc2:	89 04 24             	mov    %eax,(%esp)
c0104cc5:	e8 54 f9 ff ff       	call   c010461e <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104cca:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ccd:	83 e8 08             	sub    $0x8,%eax
c0104cd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cd7:	00 
c0104cd8:	89 04 24             	mov    %eax,(%esp)
c0104cdb:	e8 af fc ff ff       	call   c010498f <slob_free>
	return;
c0104ce0:	eb 01                	jmp    c0104ce3 <kfree+0xbb>
		return;
c0104ce2:	90                   	nop
}
c0104ce3:	89 ec                	mov    %ebp,%esp
c0104ce5:	5d                   	pop    %ebp
c0104ce6:	c3                   	ret    

c0104ce7 <ksize>:


unsigned int ksize(const void *block)
{
c0104ce7:	55                   	push   %ebp
c0104ce8:	89 e5                	mov    %esp,%ebp
c0104cea:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104ced:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104cf1:	75 07                	jne    c0104cfa <ksize+0x13>
		return 0;
c0104cf3:	b8 00 00 00 00       	mov    $0x0,%eax
c0104cf8:	eb 6b                	jmp    c0104d65 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104cfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cfd:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104d02:	85 c0                	test   %eax,%eax
c0104d04:	75 54                	jne    c0104d5a <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104d06:	e8 e7 f8 ff ff       	call   c01045f2 <__intr_save>
c0104d0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104d0e:	a1 90 bf 12 c0       	mov    0xc012bf90,%eax
c0104d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d16:	eb 31                	jmp    c0104d49 <ksize+0x62>
			if (bb->pages == block) {
c0104d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d1b:	8b 40 04             	mov    0x4(%eax),%eax
c0104d1e:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104d21:	75 1d                	jne    c0104d40 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d26:	89 04 24             	mov    %eax,(%esp)
c0104d29:	e8 f0 f8 ff ff       	call   c010461e <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d31:	8b 00                	mov    (%eax),%eax
c0104d33:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104d38:	88 c1                	mov    %al,%cl
c0104d3a:	d3 e2                	shl    %cl,%edx
c0104d3c:	89 d0                	mov    %edx,%eax
c0104d3e:	eb 25                	jmp    c0104d65 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0104d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d43:	8b 40 08             	mov    0x8(%eax),%eax
c0104d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d4d:	75 c9                	jne    c0104d18 <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d52:	89 04 24             	mov    %eax,(%esp)
c0104d55:	e8 c4 f8 ff ff       	call   c010461e <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104d5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d5d:	83 e8 08             	sub    $0x8,%eax
c0104d60:	8b 00                	mov    (%eax),%eax
c0104d62:	c1 e0 03             	shl    $0x3,%eax
}
c0104d65:	89 ec                	mov    %ebp,%esp
c0104d67:	5d                   	pop    %ebp
c0104d68:	c3                   	ret    

c0104d69 <page2ppn>:
page2ppn(struct Page *page) {
c0104d69:	55                   	push   %ebp
c0104d6a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d6c:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104d72:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d75:	29 d0                	sub    %edx,%eax
c0104d77:	c1 f8 05             	sar    $0x5,%eax
}
c0104d7a:	5d                   	pop    %ebp
c0104d7b:	c3                   	ret    

c0104d7c <page2pa>:
page2pa(struct Page *page) {
c0104d7c:	55                   	push   %ebp
c0104d7d:	89 e5                	mov    %esp,%ebp
c0104d7f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104d82:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d85:	89 04 24             	mov    %eax,(%esp)
c0104d88:	e8 dc ff ff ff       	call   c0104d69 <page2ppn>
c0104d8d:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d90:	89 ec                	mov    %ebp,%esp
c0104d92:	5d                   	pop    %ebp
c0104d93:	c3                   	ret    

c0104d94 <pa2page>:
pa2page(uintptr_t pa) {
c0104d94:	55                   	push   %ebp
c0104d95:	89 e5                	mov    %esp,%ebp
c0104d97:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104d9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d9d:	c1 e8 0c             	shr    $0xc,%eax
c0104da0:	89 c2                	mov    %eax,%edx
c0104da2:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104da7:	39 c2                	cmp    %eax,%edx
c0104da9:	72 1c                	jb     c0104dc7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104dab:	c7 44 24 08 e4 ae 10 	movl   $0xc010aee4,0x8(%esp)
c0104db2:	c0 
c0104db3:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104dba:	00 
c0104dbb:	c7 04 24 03 af 10 c0 	movl   $0xc010af03,(%esp)
c0104dc2:	e8 4f bf ff ff       	call   c0100d16 <__panic>
    return &pages[PPN(pa)];
c0104dc7:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104dcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dd0:	c1 e8 0c             	shr    $0xc,%eax
c0104dd3:	c1 e0 05             	shl    $0x5,%eax
c0104dd6:	01 d0                	add    %edx,%eax
}
c0104dd8:	89 ec                	mov    %ebp,%esp
c0104dda:	5d                   	pop    %ebp
c0104ddb:	c3                   	ret    

c0104ddc <page2kva>:
page2kva(struct Page *page) {
c0104ddc:	55                   	push   %ebp
c0104ddd:	89 e5                	mov    %esp,%ebp
c0104ddf:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104de2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104de5:	89 04 24             	mov    %eax,(%esp)
c0104de8:	e8 8f ff ff ff       	call   c0104d7c <page2pa>
c0104ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104df3:	c1 e8 0c             	shr    $0xc,%eax
c0104df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104df9:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104dfe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104e01:	72 23                	jb     c0104e26 <page2kva+0x4a>
c0104e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e06:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e0a:	c7 44 24 08 14 af 10 	movl   $0xc010af14,0x8(%esp)
c0104e11:	c0 
c0104e12:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104e19:	00 
c0104e1a:	c7 04 24 03 af 10 c0 	movl   $0xc010af03,(%esp)
c0104e21:	e8 f0 be ff ff       	call   c0100d16 <__panic>
c0104e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e29:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104e2e:	89 ec                	mov    %ebp,%esp
c0104e30:	5d                   	pop    %ebp
c0104e31:	c3                   	ret    

c0104e32 <pte2page>:
pte2page(pte_t pte) {
c0104e32:	55                   	push   %ebp
c0104e33:	89 e5                	mov    %esp,%ebp
c0104e35:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104e38:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e3b:	83 e0 01             	and    $0x1,%eax
c0104e3e:	85 c0                	test   %eax,%eax
c0104e40:	75 1c                	jne    c0104e5e <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104e42:	c7 44 24 08 38 af 10 	movl   $0xc010af38,0x8(%esp)
c0104e49:	c0 
c0104e4a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0104e51:	00 
c0104e52:	c7 04 24 03 af 10 c0 	movl   $0xc010af03,(%esp)
c0104e59:	e8 b8 be ff ff       	call   c0100d16 <__panic>
    return pa2page(PTE_ADDR(pte));
c0104e5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e61:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e66:	89 04 24             	mov    %eax,(%esp)
c0104e69:	e8 26 ff ff ff       	call   c0104d94 <pa2page>
}
c0104e6e:	89 ec                	mov    %ebp,%esp
c0104e70:	5d                   	pop    %ebp
c0104e71:	c3                   	ret    

c0104e72 <pde2page>:
pde2page(pde_t pde) {
c0104e72:	55                   	push   %ebp
c0104e73:	89 e5                	mov    %esp,%ebp
c0104e75:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104e78:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e80:	89 04 24             	mov    %eax,(%esp)
c0104e83:	e8 0c ff ff ff       	call   c0104d94 <pa2page>
}
c0104e88:	89 ec                	mov    %ebp,%esp
c0104e8a:	5d                   	pop    %ebp
c0104e8b:	c3                   	ret    

c0104e8c <page_ref>:
page_ref(struct Page *page) {
c0104e8c:	55                   	push   %ebp
c0104e8d:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104e8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e92:	8b 00                	mov    (%eax),%eax
}
c0104e94:	5d                   	pop    %ebp
c0104e95:	c3                   	ret    

c0104e96 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104e96:	55                   	push   %ebp
c0104e97:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104e99:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e9c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e9f:	89 10                	mov    %edx,(%eax)
}
c0104ea1:	90                   	nop
c0104ea2:	5d                   	pop    %ebp
c0104ea3:	c3                   	ret    

c0104ea4 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104ea4:	55                   	push   %ebp
c0104ea5:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104ea7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eaa:	8b 00                	mov    (%eax),%eax
c0104eac:	8d 50 01             	lea    0x1(%eax),%edx
c0104eaf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eb2:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104eb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eb7:	8b 00                	mov    (%eax),%eax
}
c0104eb9:	5d                   	pop    %ebp
c0104eba:	c3                   	ret    

c0104ebb <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104ebb:	55                   	push   %ebp
c0104ebc:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104ebe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ec1:	8b 00                	mov    (%eax),%eax
c0104ec3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104ec6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ec9:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104ecb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ece:	8b 00                	mov    (%eax),%eax
}
c0104ed0:	5d                   	pop    %ebp
c0104ed1:	c3                   	ret    

c0104ed2 <__intr_save>:
__intr_save(void) {
c0104ed2:	55                   	push   %ebp
c0104ed3:	89 e5                	mov    %esp,%ebp
c0104ed5:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104ed8:	9c                   	pushf  
c0104ed9:	58                   	pop    %eax
c0104eda:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104ee0:	25 00 02 00 00       	and    $0x200,%eax
c0104ee5:	85 c0                	test   %eax,%eax
c0104ee7:	74 0c                	je     c0104ef5 <__intr_save+0x23>
        intr_disable();
c0104ee9:	e8 de d0 ff ff       	call   c0101fcc <intr_disable>
        return 1;
c0104eee:	b8 01 00 00 00       	mov    $0x1,%eax
c0104ef3:	eb 05                	jmp    c0104efa <__intr_save+0x28>
    return 0;
c0104ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104efa:	89 ec                	mov    %ebp,%esp
c0104efc:	5d                   	pop    %ebp
c0104efd:	c3                   	ret    

c0104efe <__intr_restore>:
__intr_restore(bool flag) {
c0104efe:	55                   	push   %ebp
c0104eff:	89 e5                	mov    %esp,%ebp
c0104f01:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104f04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104f08:	74 05                	je     c0104f0f <__intr_restore+0x11>
        intr_enable();
c0104f0a:	e8 b5 d0 ff ff       	call   c0101fc4 <intr_enable>
}
c0104f0f:	90                   	nop
c0104f10:	89 ec                	mov    %ebp,%esp
c0104f12:	5d                   	pop    %ebp
c0104f13:	c3                   	ret    

c0104f14 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104f14:	55                   	push   %ebp
c0104f15:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104f17:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f1a:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104f1d:	b8 23 00 00 00       	mov    $0x23,%eax
c0104f22:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104f24:	b8 23 00 00 00       	mov    $0x23,%eax
c0104f29:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104f2b:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f30:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104f32:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f37:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104f39:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f3e:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104f40:	ea 47 4f 10 c0 08 00 	ljmp   $0x8,$0xc0104f47
}
c0104f47:	90                   	nop
c0104f48:	5d                   	pop    %ebp
c0104f49:	c3                   	ret    

c0104f4a <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104f4a:	55                   	push   %ebp
c0104f4b:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104f4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f50:	a3 c4 bf 12 c0       	mov    %eax,0xc012bfc4
}
c0104f55:	90                   	nop
c0104f56:	5d                   	pop    %ebp
c0104f57:	c3                   	ret    

c0104f58 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104f58:	55                   	push   %ebp
c0104f59:	89 e5                	mov    %esp,%ebp
c0104f5b:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104f5e:	b8 00 80 12 c0       	mov    $0xc0128000,%eax
c0104f63:	89 04 24             	mov    %eax,(%esp)
c0104f66:	e8 df ff ff ff       	call   c0104f4a <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104f6b:	66 c7 05 c8 bf 12 c0 	movw   $0x10,0xc012bfc8
c0104f72:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104f74:	66 c7 05 48 8a 12 c0 	movw   $0x68,0xc0128a48
c0104f7b:	68 00 
c0104f7d:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0104f82:	0f b7 c0             	movzwl %ax,%eax
c0104f85:	66 a3 4a 8a 12 c0    	mov    %ax,0xc0128a4a
c0104f8b:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0104f90:	c1 e8 10             	shr    $0x10,%eax
c0104f93:	a2 4c 8a 12 c0       	mov    %al,0xc0128a4c
c0104f98:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104f9f:	24 f0                	and    $0xf0,%al
c0104fa1:	0c 09                	or     $0x9,%al
c0104fa3:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104fa8:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104faf:	24 ef                	and    $0xef,%al
c0104fb1:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104fb6:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104fbd:	24 9f                	and    $0x9f,%al
c0104fbf:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104fc4:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104fcb:	0c 80                	or     $0x80,%al
c0104fcd:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104fd2:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104fd9:	24 f0                	and    $0xf0,%al
c0104fdb:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104fe0:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104fe7:	24 ef                	and    $0xef,%al
c0104fe9:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104fee:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104ff5:	24 df                	and    $0xdf,%al
c0104ff7:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104ffc:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0105003:	0c 40                	or     $0x40,%al
c0105005:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c010500a:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0105011:	24 7f                	and    $0x7f,%al
c0105013:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0105018:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c010501d:	c1 e8 18             	shr    $0x18,%eax
c0105020:	a2 4f 8a 12 c0       	mov    %al,0xc0128a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0105025:	c7 04 24 50 8a 12 c0 	movl   $0xc0128a50,(%esp)
c010502c:	e8 e3 fe ff ff       	call   c0104f14 <lgdt>
c0105031:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0105037:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c010503b:	0f 00 d8             	ltr    %ax
}
c010503e:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c010503f:	90                   	nop
c0105040:	89 ec                	mov    %ebp,%esp
c0105042:	5d                   	pop    %ebp
c0105043:	c3                   	ret    

c0105044 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0105044:	55                   	push   %ebp
c0105045:	89 e5                	mov    %esp,%ebp
c0105047:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c010504a:	c7 05 ac bf 12 c0 d8 	movl   $0xc010add8,0xc012bfac
c0105051:	ad 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0105054:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105059:	8b 00                	mov    (%eax),%eax
c010505b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010505f:	c7 04 24 64 af 10 c0 	movl   $0xc010af64,(%esp)
c0105066:	e8 02 b3 ff ff       	call   c010036d <cprintf>
    pmm_manager->init();
c010506b:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105070:	8b 40 04             	mov    0x4(%eax),%eax
c0105073:	ff d0                	call   *%eax
}
c0105075:	90                   	nop
c0105076:	89 ec                	mov    %ebp,%esp
c0105078:	5d                   	pop    %ebp
c0105079:	c3                   	ret    

c010507a <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010507a:	55                   	push   %ebp
c010507b:	89 e5                	mov    %esp,%ebp
c010507d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0105080:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105085:	8b 40 08             	mov    0x8(%eax),%eax
c0105088:	8b 55 0c             	mov    0xc(%ebp),%edx
c010508b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010508f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105092:	89 14 24             	mov    %edx,(%esp)
c0105095:	ff d0                	call   *%eax
}
c0105097:	90                   	nop
c0105098:	89 ec                	mov    %ebp,%esp
c010509a:	5d                   	pop    %ebp
c010509b:	c3                   	ret    

c010509c <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010509c:	55                   	push   %ebp
c010509d:	89 e5                	mov    %esp,%ebp
c010509f:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01050a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c01050a9:	e8 24 fe ff ff       	call   c0104ed2 <__intr_save>
c01050ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01050b1:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c01050b6:	8b 40 0c             	mov    0xc(%eax),%eax
c01050b9:	8b 55 08             	mov    0x8(%ebp),%edx
c01050bc:	89 14 24             	mov    %edx,(%esp)
c01050bf:	ff d0                	call   *%eax
c01050c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050c7:	89 04 24             	mov    %eax,(%esp)
c01050ca:	e8 2f fe ff ff       	call   c0104efe <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01050cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050d3:	75 2d                	jne    c0105102 <alloc_pages+0x66>
c01050d5:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01050d9:	77 27                	ja     c0105102 <alloc_pages+0x66>
c01050db:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c01050e0:	85 c0                	test   %eax,%eax
c01050e2:	74 1e                	je     c0105102 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01050e4:	8b 55 08             	mov    0x8(%ebp),%edx
c01050e7:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01050ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050f3:	00 
c01050f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050f8:	89 04 24             	mov    %eax,(%esp)
c01050fb:	e8 c5 18 00 00       	call   c01069c5 <swap_out>
    {
c0105100:	eb a7                	jmp    c01050a9 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0105102:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105105:	89 ec                	mov    %ebp,%esp
c0105107:	5d                   	pop    %ebp
c0105108:	c3                   	ret    

c0105109 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0105109:	55                   	push   %ebp
c010510a:	89 e5                	mov    %esp,%ebp
c010510c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010510f:	e8 be fd ff ff       	call   c0104ed2 <__intr_save>
c0105114:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0105117:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c010511c:	8b 40 10             	mov    0x10(%eax),%eax
c010511f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105122:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105126:	8b 55 08             	mov    0x8(%ebp),%edx
c0105129:	89 14 24             	mov    %edx,(%esp)
c010512c:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010512e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105131:	89 04 24             	mov    %eax,(%esp)
c0105134:	e8 c5 fd ff ff       	call   c0104efe <__intr_restore>
}
c0105139:	90                   	nop
c010513a:	89 ec                	mov    %ebp,%esp
c010513c:	5d                   	pop    %ebp
c010513d:	c3                   	ret    

c010513e <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010513e:	55                   	push   %ebp
c010513f:	89 e5                	mov    %esp,%ebp
c0105141:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0105144:	e8 89 fd ff ff       	call   c0104ed2 <__intr_save>
c0105149:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010514c:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105151:	8b 40 14             	mov    0x14(%eax),%eax
c0105154:	ff d0                	call   *%eax
c0105156:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0105159:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010515c:	89 04 24             	mov    %eax,(%esp)
c010515f:	e8 9a fd ff ff       	call   c0104efe <__intr_restore>
    return ret;
c0105164:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0105167:	89 ec                	mov    %ebp,%esp
c0105169:	5d                   	pop    %ebp
c010516a:	c3                   	ret    

c010516b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010516b:	55                   	push   %ebp
c010516c:	89 e5                	mov    %esp,%ebp
c010516e:	57                   	push   %edi
c010516f:	56                   	push   %esi
c0105170:	53                   	push   %ebx
c0105171:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0105177:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010517e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105185:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010518c:	c7 04 24 7b af 10 c0 	movl   $0xc010af7b,(%esp)
c0105193:	e8 d5 b1 ff ff       	call   c010036d <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105198:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010519f:	e9 0c 01 00 00       	jmp    c01052b0 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01051a4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051aa:	89 d0                	mov    %edx,%eax
c01051ac:	c1 e0 02             	shl    $0x2,%eax
c01051af:	01 d0                	add    %edx,%eax
c01051b1:	c1 e0 02             	shl    $0x2,%eax
c01051b4:	01 c8                	add    %ecx,%eax
c01051b6:	8b 50 08             	mov    0x8(%eax),%edx
c01051b9:	8b 40 04             	mov    0x4(%eax),%eax
c01051bc:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01051bf:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01051c2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051c8:	89 d0                	mov    %edx,%eax
c01051ca:	c1 e0 02             	shl    $0x2,%eax
c01051cd:	01 d0                	add    %edx,%eax
c01051cf:	c1 e0 02             	shl    $0x2,%eax
c01051d2:	01 c8                	add    %ecx,%eax
c01051d4:	8b 48 0c             	mov    0xc(%eax),%ecx
c01051d7:	8b 58 10             	mov    0x10(%eax),%ebx
c01051da:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01051dd:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01051e0:	01 c8                	add    %ecx,%eax
c01051e2:	11 da                	adc    %ebx,%edx
c01051e4:	89 45 98             	mov    %eax,-0x68(%ebp)
c01051e7:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01051ea:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051f0:	89 d0                	mov    %edx,%eax
c01051f2:	c1 e0 02             	shl    $0x2,%eax
c01051f5:	01 d0                	add    %edx,%eax
c01051f7:	c1 e0 02             	shl    $0x2,%eax
c01051fa:	01 c8                	add    %ecx,%eax
c01051fc:	83 c0 14             	add    $0x14,%eax
c01051ff:	8b 00                	mov    (%eax),%eax
c0105201:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0105207:	8b 45 98             	mov    -0x68(%ebp),%eax
c010520a:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010520d:	83 c0 ff             	add    $0xffffffff,%eax
c0105210:	83 d2 ff             	adc    $0xffffffff,%edx
c0105213:	89 c6                	mov    %eax,%esi
c0105215:	89 d7                	mov    %edx,%edi
c0105217:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010521a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010521d:	89 d0                	mov    %edx,%eax
c010521f:	c1 e0 02             	shl    $0x2,%eax
c0105222:	01 d0                	add    %edx,%eax
c0105224:	c1 e0 02             	shl    $0x2,%eax
c0105227:	01 c8                	add    %ecx,%eax
c0105229:	8b 48 0c             	mov    0xc(%eax),%ecx
c010522c:	8b 58 10             	mov    0x10(%eax),%ebx
c010522f:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0105235:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0105239:	89 74 24 14          	mov    %esi,0x14(%esp)
c010523d:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0105241:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105244:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0105247:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010524b:	89 54 24 10          	mov    %edx,0x10(%esp)
c010524f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105253:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0105257:	c7 04 24 88 af 10 c0 	movl   $0xc010af88,(%esp)
c010525e:	e8 0a b1 ff ff       	call   c010036d <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105263:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105266:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105269:	89 d0                	mov    %edx,%eax
c010526b:	c1 e0 02             	shl    $0x2,%eax
c010526e:	01 d0                	add    %edx,%eax
c0105270:	c1 e0 02             	shl    $0x2,%eax
c0105273:	01 c8                	add    %ecx,%eax
c0105275:	83 c0 14             	add    $0x14,%eax
c0105278:	8b 00                	mov    (%eax),%eax
c010527a:	83 f8 01             	cmp    $0x1,%eax
c010527d:	75 2e                	jne    c01052ad <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c010527f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105282:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105285:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0105288:	89 d0                	mov    %edx,%eax
c010528a:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c010528d:	73 1e                	jae    c01052ad <page_init+0x142>
c010528f:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0105294:	b8 00 00 00 00       	mov    $0x0,%eax
c0105299:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c010529c:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010529f:	72 0c                	jb     c01052ad <page_init+0x142>
                maxpa = end;
c01052a1:	8b 45 98             	mov    -0x68(%ebp),%eax
c01052a4:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01052a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01052aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c01052ad:	ff 45 dc             	incl   -0x24(%ebp)
c01052b0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052b3:	8b 00                	mov    (%eax),%eax
c01052b5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01052b8:	0f 8c e6 fe ff ff    	jl     c01051a4 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01052be:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01052c3:	b8 00 00 00 00       	mov    $0x0,%eax
c01052c8:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c01052cb:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c01052ce:	73 0e                	jae    c01052de <page_init+0x173>
        maxpa = KMEMSIZE;
c01052d0:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01052d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01052de:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052e4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01052e8:	c1 ea 0c             	shr    $0xc,%edx
c01052eb:	a3 a4 bf 12 c0       	mov    %eax,0xc012bfa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01052f0:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01052f7:	b8 54 e1 12 c0       	mov    $0xc012e154,%eax
c01052fc:	8d 50 ff             	lea    -0x1(%eax),%edx
c01052ff:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105302:	01 d0                	add    %edx,%eax
c0105304:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0105307:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010530a:	ba 00 00 00 00       	mov    $0x0,%edx
c010530f:	f7 75 c0             	divl   -0x40(%ebp)
c0105312:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105315:	29 d0                	sub    %edx,%eax
c0105317:	a3 a0 bf 12 c0       	mov    %eax,0xc012bfa0

    for (i = 0; i < npage; i ++) {
c010531c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105323:	eb 28                	jmp    c010534d <page_init+0x1e2>
        SetPageReserved(pages + i);
c0105325:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c010532b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010532e:	c1 e0 05             	shl    $0x5,%eax
c0105331:	01 d0                	add    %edx,%eax
c0105333:	83 c0 04             	add    $0x4,%eax
c0105336:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c010533d:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105340:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105343:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105346:	0f ab 10             	bts    %edx,(%eax)
}
c0105349:	90                   	nop
    for (i = 0; i < npage; i ++) {
c010534a:	ff 45 dc             	incl   -0x24(%ebp)
c010534d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105350:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0105355:	39 c2                	cmp    %eax,%edx
c0105357:	72 cc                	jb     c0105325 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0105359:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c010535e:	c1 e0 05             	shl    $0x5,%eax
c0105361:	89 c2                	mov    %eax,%edx
c0105363:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0105368:	01 d0                	add    %edx,%eax
c010536a:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010536d:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0105374:	77 23                	ja     c0105399 <page_init+0x22e>
c0105376:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105379:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010537d:	c7 44 24 08 b8 af 10 	movl   $0xc010afb8,0x8(%esp)
c0105384:	c0 
c0105385:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c010538c:	00 
c010538d:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105394:	e8 7d b9 ff ff       	call   c0100d16 <__panic>
c0105399:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010539c:	05 00 00 00 40       	add    $0x40000000,%eax
c01053a1:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01053a4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01053ab:	e9 53 01 00 00       	jmp    c0105503 <page_init+0x398>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01053b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053b6:	89 d0                	mov    %edx,%eax
c01053b8:	c1 e0 02             	shl    $0x2,%eax
c01053bb:	01 d0                	add    %edx,%eax
c01053bd:	c1 e0 02             	shl    $0x2,%eax
c01053c0:	01 c8                	add    %ecx,%eax
c01053c2:	8b 50 08             	mov    0x8(%eax),%edx
c01053c5:	8b 40 04             	mov    0x4(%eax),%eax
c01053c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01053cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01053ce:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053d4:	89 d0                	mov    %edx,%eax
c01053d6:	c1 e0 02             	shl    $0x2,%eax
c01053d9:	01 d0                	add    %edx,%eax
c01053db:	c1 e0 02             	shl    $0x2,%eax
c01053de:	01 c8                	add    %ecx,%eax
c01053e0:	8b 48 0c             	mov    0xc(%eax),%ecx
c01053e3:	8b 58 10             	mov    0x10(%eax),%ebx
c01053e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053ec:	01 c8                	add    %ecx,%eax
c01053ee:	11 da                	adc    %ebx,%edx
c01053f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01053f3:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01053f6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053fc:	89 d0                	mov    %edx,%eax
c01053fe:	c1 e0 02             	shl    $0x2,%eax
c0105401:	01 d0                	add    %edx,%eax
c0105403:	c1 e0 02             	shl    $0x2,%eax
c0105406:	01 c8                	add    %ecx,%eax
c0105408:	83 c0 14             	add    $0x14,%eax
c010540b:	8b 00                	mov    (%eax),%eax
c010540d:	83 f8 01             	cmp    $0x1,%eax
c0105410:	0f 85 ea 00 00 00    	jne    c0105500 <page_init+0x395>
            if (begin < freemem) {
c0105416:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105419:	ba 00 00 00 00       	mov    $0x0,%edx
c010541e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105421:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105424:	19 d1                	sbb    %edx,%ecx
c0105426:	73 0d                	jae    c0105435 <page_init+0x2ca>
                begin = freemem;
c0105428:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010542b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010542e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0105435:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010543a:	b8 00 00 00 00       	mov    $0x0,%eax
c010543f:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0105442:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105445:	73 0e                	jae    c0105455 <page_init+0x2ea>
                end = KMEMSIZE;
c0105447:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010544e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0105455:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105458:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010545b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010545e:	89 d0                	mov    %edx,%eax
c0105460:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105463:	0f 83 97 00 00 00    	jae    c0105500 <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c0105469:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0105470:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105473:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105476:	01 d0                	add    %edx,%eax
c0105478:	48                   	dec    %eax
c0105479:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010547c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010547f:	ba 00 00 00 00       	mov    $0x0,%edx
c0105484:	f7 75 b0             	divl   -0x50(%ebp)
c0105487:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010548a:	29 d0                	sub    %edx,%eax
c010548c:	ba 00 00 00 00       	mov    $0x0,%edx
c0105491:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105494:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0105497:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010549a:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010549d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01054a0:	ba 00 00 00 00       	mov    $0x0,%edx
c01054a5:	89 c7                	mov    %eax,%edi
c01054a7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01054ad:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01054b0:	89 d0                	mov    %edx,%eax
c01054b2:	83 e0 00             	and    $0x0,%eax
c01054b5:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01054b8:	8b 45 80             	mov    -0x80(%ebp),%eax
c01054bb:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01054be:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01054c1:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01054c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054ca:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01054cd:	89 d0                	mov    %edx,%eax
c01054cf:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01054d2:	73 2c                	jae    c0105500 <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01054d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01054d7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01054da:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01054dd:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01054e0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01054e4:	c1 ea 0c             	shr    $0xc,%edx
c01054e7:	89 c3                	mov    %eax,%ebx
c01054e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054ec:	89 04 24             	mov    %eax,(%esp)
c01054ef:	e8 a0 f8 ff ff       	call   c0104d94 <pa2page>
c01054f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01054f8:	89 04 24             	mov    %eax,(%esp)
c01054fb:	e8 7a fb ff ff       	call   c010507a <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0105500:	ff 45 dc             	incl   -0x24(%ebp)
c0105503:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105506:	8b 00                	mov    (%eax),%eax
c0105508:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010550b:	0f 8c 9f fe ff ff    	jl     c01053b0 <page_init+0x245>
                }
            }
        }
    }
}
c0105511:	90                   	nop
c0105512:	90                   	nop
c0105513:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0105519:	5b                   	pop    %ebx
c010551a:	5e                   	pop    %esi
c010551b:	5f                   	pop    %edi
c010551c:	5d                   	pop    %ebp
c010551d:	c3                   	ret    

c010551e <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010551e:	55                   	push   %ebp
c010551f:	89 e5                	mov    %esp,%ebp
c0105521:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0105524:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105527:	33 45 14             	xor    0x14(%ebp),%eax
c010552a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010552f:	85 c0                	test   %eax,%eax
c0105531:	74 24                	je     c0105557 <boot_map_segment+0x39>
c0105533:	c7 44 24 0c ea af 10 	movl   $0xc010afea,0xc(%esp)
c010553a:	c0 
c010553b:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105542:	c0 
c0105543:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010554a:	00 
c010554b:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105552:	e8 bf b7 ff ff       	call   c0100d16 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0105557:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010555e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105561:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105566:	89 c2                	mov    %eax,%edx
c0105568:	8b 45 10             	mov    0x10(%ebp),%eax
c010556b:	01 c2                	add    %eax,%edx
c010556d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105570:	01 d0                	add    %edx,%eax
c0105572:	48                   	dec    %eax
c0105573:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105576:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105579:	ba 00 00 00 00       	mov    $0x0,%edx
c010557e:	f7 75 f0             	divl   -0x10(%ebp)
c0105581:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105584:	29 d0                	sub    %edx,%eax
c0105586:	c1 e8 0c             	shr    $0xc,%eax
c0105589:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010558c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010558f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105592:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105595:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010559a:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010559d:	8b 45 14             	mov    0x14(%ebp),%eax
c01055a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01055a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055ab:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01055ae:	eb 68                	jmp    c0105618 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01055b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01055b7:	00 
c01055b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c2:	89 04 24             	mov    %eax,(%esp)
c01055c5:	e8 8d 01 00 00       	call   c0105757 <get_pte>
c01055ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01055cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01055d1:	75 24                	jne    c01055f7 <boot_map_segment+0xd9>
c01055d3:	c7 44 24 0c 16 b0 10 	movl   $0xc010b016,0xc(%esp)
c01055da:	c0 
c01055db:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01055e2:	c0 
c01055e3:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01055ea:	00 
c01055eb:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01055f2:	e8 1f b7 ff ff       	call   c0100d16 <__panic>
        *ptep = pa | PTE_P | perm;
c01055f7:	8b 45 14             	mov    0x14(%ebp),%eax
c01055fa:	0b 45 18             	or     0x18(%ebp),%eax
c01055fd:	83 c8 01             	or     $0x1,%eax
c0105600:	89 c2                	mov    %eax,%edx
c0105602:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105605:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0105607:	ff 4d f4             	decl   -0xc(%ebp)
c010560a:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0105611:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0105618:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010561c:	75 92                	jne    c01055b0 <boot_map_segment+0x92>
    }
}
c010561e:	90                   	nop
c010561f:	90                   	nop
c0105620:	89 ec                	mov    %ebp,%esp
c0105622:	5d                   	pop    %ebp
c0105623:	c3                   	ret    

c0105624 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0105624:	55                   	push   %ebp
c0105625:	89 e5                	mov    %esp,%ebp
c0105627:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010562a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105631:	e8 66 fa ff ff       	call   c010509c <alloc_pages>
c0105636:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0105639:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010563d:	75 1c                	jne    c010565b <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010563f:	c7 44 24 08 23 b0 10 	movl   $0xc010b023,0x8(%esp)
c0105646:	c0 
c0105647:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c010564e:	00 
c010564f:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105656:	e8 bb b6 ff ff       	call   c0100d16 <__panic>
    }
    return page2kva(p);
c010565b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010565e:	89 04 24             	mov    %eax,(%esp)
c0105661:	e8 76 f7 ff ff       	call   c0104ddc <page2kva>
}
c0105666:	89 ec                	mov    %ebp,%esp
c0105668:	5d                   	pop    %ebp
c0105669:	c3                   	ret    

c010566a <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010566a:	55                   	push   %ebp
c010566b:	89 e5                	mov    %esp,%ebp
c010566d:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105670:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105675:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105678:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010567f:	77 23                	ja     c01056a4 <pmm_init+0x3a>
c0105681:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105684:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105688:	c7 44 24 08 b8 af 10 	movl   $0xc010afb8,0x8(%esp)
c010568f:	c0 
c0105690:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105697:	00 
c0105698:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010569f:	e8 72 b6 ff ff       	call   c0100d16 <__panic>
c01056a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056a7:	05 00 00 00 40       	add    $0x40000000,%eax
c01056ac:	a3 a8 bf 12 c0       	mov    %eax,0xc012bfa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01056b1:	e8 8e f9 ff ff       	call   c0105044 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01056b6:	e8 b0 fa ff ff       	call   c010516b <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01056bb:	e8 bf 04 00 00       	call   c0105b7f <check_alloc_page>

    check_pgdir();
c01056c0:	e8 db 04 00 00       	call   c0105ba0 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01056c5:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01056ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056cd:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01056d4:	77 23                	ja     c01056f9 <pmm_init+0x8f>
c01056d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01056dd:	c7 44 24 08 b8 af 10 	movl   $0xc010afb8,0x8(%esp)
c01056e4:	c0 
c01056e5:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01056ec:	00 
c01056ed:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01056f4:	e8 1d b6 ff ff       	call   c0100d16 <__panic>
c01056f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056fc:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0105702:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105707:	05 ac 0f 00 00       	add    $0xfac,%eax
c010570c:	83 ca 03             	or     $0x3,%edx
c010570f:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105711:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105716:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010571d:	00 
c010571e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105725:	00 
c0105726:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010572d:	38 
c010572e:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105735:	c0 
c0105736:	89 04 24             	mov    %eax,(%esp)
c0105739:	e8 e0 fd ff ff       	call   c010551e <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010573e:	e8 15 f8 ff ff       	call   c0104f58 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105743:	e8 f6 0a 00 00       	call   c010623e <check_boot_pgdir>

    print_pgdir();
c0105748:	e8 73 0f 00 00       	call   c01066c0 <print_pgdir>
    
    kmalloc_init();
c010574d:	e8 70 f3 ff ff       	call   c0104ac2 <kmalloc_init>

}
c0105752:	90                   	nop
c0105753:	89 ec                	mov    %ebp,%esp
c0105755:	5d                   	pop    %ebp
c0105756:	c3                   	ret    

c0105757 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105757:	55                   	push   %ebp
c0105758:	89 e5                	mov    %esp,%ebp
c010575a:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c010575d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105760:	c1 e8 16             	shr    $0x16,%eax
c0105763:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010576a:	8b 45 08             	mov    0x8(%ebp),%eax
c010576d:	01 d0                	add    %edx,%eax
c010576f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0105772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105775:	8b 00                	mov    (%eax),%eax
c0105777:	83 e0 01             	and    $0x1,%eax
c010577a:	85 c0                	test   %eax,%eax
c010577c:	0f 85 af 00 00 00    	jne    c0105831 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0105782:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105786:	74 15                	je     c010579d <get_pte+0x46>
c0105788:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010578f:	e8 08 f9 ff ff       	call   c010509c <alloc_pages>
c0105794:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105797:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010579b:	75 0a                	jne    c01057a7 <get_pte+0x50>
            return NULL;
c010579d:	b8 00 00 00 00       	mov    $0x0,%eax
c01057a2:	e9 e7 00 00 00       	jmp    c010588e <get_pte+0x137>
        }
        set_page_ref(page, 1);
c01057a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01057ae:	00 
c01057af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057b2:	89 04 24             	mov    %eax,(%esp)
c01057b5:	e8 dc f6 ff ff       	call   c0104e96 <set_page_ref>
        uintptr_t pa = page2pa(page);
c01057ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057bd:	89 04 24             	mov    %eax,(%esp)
c01057c0:	e8 b7 f5 ff ff       	call   c0104d7c <page2pa>
c01057c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01057c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057d1:	c1 e8 0c             	shr    $0xc,%eax
c01057d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01057d7:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01057dc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01057df:	72 23                	jb     c0105804 <get_pte+0xad>
c01057e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01057e8:	c7 44 24 08 14 af 10 	movl   $0xc010af14,0x8(%esp)
c01057ef:	c0 
c01057f0:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c01057f7:	00 
c01057f8:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01057ff:	e8 12 b5 ff ff       	call   c0100d16 <__panic>
c0105804:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105807:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010580c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105813:	00 
c0105814:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010581b:	00 
c010581c:	89 04 24             	mov    %eax,(%esp)
c010581f:	e8 5f 47 00 00       	call   c0109f83 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0105824:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105827:	83 c8 07             	or     $0x7,%eax
c010582a:	89 c2                	mov    %eax,%edx
c010582c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010582f:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0105831:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105834:	8b 00                	mov    (%eax),%eax
c0105836:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010583b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010583e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105841:	c1 e8 0c             	shr    $0xc,%eax
c0105844:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105847:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c010584c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010584f:	72 23                	jb     c0105874 <get_pte+0x11d>
c0105851:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105854:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105858:	c7 44 24 08 14 af 10 	movl   $0xc010af14,0x8(%esp)
c010585f:	c0 
c0105860:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c0105867:	00 
c0105868:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010586f:	e8 a2 b4 ff ff       	call   c0100d16 <__panic>
c0105874:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105877:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010587c:	89 c2                	mov    %eax,%edx
c010587e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105881:	c1 e8 0c             	shr    $0xc,%eax
c0105884:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105889:	c1 e0 02             	shl    $0x2,%eax
c010588c:	01 d0                	add    %edx,%eax
}
c010588e:	89 ec                	mov    %ebp,%esp
c0105890:	5d                   	pop    %ebp
c0105891:	c3                   	ret    

c0105892 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105892:	55                   	push   %ebp
c0105893:	89 e5                	mov    %esp,%ebp
c0105895:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105898:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010589f:	00 
c01058a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01058aa:	89 04 24             	mov    %eax,(%esp)
c01058ad:	e8 a5 fe ff ff       	call   c0105757 <get_pte>
c01058b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01058b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01058b9:	74 08                	je     c01058c3 <get_page+0x31>
        *ptep_store = ptep;
c01058bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01058be:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058c1:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01058c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058c7:	74 1b                	je     c01058e4 <get_page+0x52>
c01058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058cc:	8b 00                	mov    (%eax),%eax
c01058ce:	83 e0 01             	and    $0x1,%eax
c01058d1:	85 c0                	test   %eax,%eax
c01058d3:	74 0f                	je     c01058e4 <get_page+0x52>
        return pte2page(*ptep);
c01058d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058d8:	8b 00                	mov    (%eax),%eax
c01058da:	89 04 24             	mov    %eax,(%esp)
c01058dd:	e8 50 f5 ff ff       	call   c0104e32 <pte2page>
c01058e2:	eb 05                	jmp    c01058e9 <get_page+0x57>
    }
    return NULL;
c01058e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01058e9:	89 ec                	mov    %ebp,%esp
c01058eb:	5d                   	pop    %ebp
c01058ec:	c3                   	ret    

c01058ed <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01058ed:	55                   	push   %ebp
c01058ee:	89 e5                	mov    %esp,%ebp
c01058f0:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c01058f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01058f6:	8b 00                	mov    (%eax),%eax
c01058f8:	83 e0 01             	and    $0x1,%eax
c01058fb:	85 c0                	test   %eax,%eax
c01058fd:	74 4d                	je     c010594c <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c01058ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0105902:	8b 00                	mov    (%eax),%eax
c0105904:	89 04 24             	mov    %eax,(%esp)
c0105907:	e8 26 f5 ff ff       	call   c0104e32 <pte2page>
c010590c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105912:	89 04 24             	mov    %eax,(%esp)
c0105915:	e8 a1 f5 ff ff       	call   c0104ebb <page_ref_dec>
c010591a:	85 c0                	test   %eax,%eax
c010591c:	75 13                	jne    c0105931 <page_remove_pte+0x44>
            free_page(page);
c010591e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105925:	00 
c0105926:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105929:	89 04 24             	mov    %eax,(%esp)
c010592c:	e8 d8 f7 ff ff       	call   c0105109 <free_pages>
        }
        *ptep = 0;
c0105931:	8b 45 10             	mov    0x10(%ebp),%eax
c0105934:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c010593a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010593d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105941:	8b 45 08             	mov    0x8(%ebp),%eax
c0105944:	89 04 24             	mov    %eax,(%esp)
c0105947:	e8 07 01 00 00       	call   c0105a53 <tlb_invalidate>
    }
}
c010594c:	90                   	nop
c010594d:	89 ec                	mov    %ebp,%esp
c010594f:	5d                   	pop    %ebp
c0105950:	c3                   	ret    

c0105951 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105951:	55                   	push   %ebp
c0105952:	89 e5                	mov    %esp,%ebp
c0105954:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105957:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010595e:	00 
c010595f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105962:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105966:	8b 45 08             	mov    0x8(%ebp),%eax
c0105969:	89 04 24             	mov    %eax,(%esp)
c010596c:	e8 e6 fd ff ff       	call   c0105757 <get_pte>
c0105971:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105974:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105978:	74 19                	je     c0105993 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010597a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010597d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105981:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105984:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105988:	8b 45 08             	mov    0x8(%ebp),%eax
c010598b:	89 04 24             	mov    %eax,(%esp)
c010598e:	e8 5a ff ff ff       	call   c01058ed <page_remove_pte>
    }
}
c0105993:	90                   	nop
c0105994:	89 ec                	mov    %ebp,%esp
c0105996:	5d                   	pop    %ebp
c0105997:	c3                   	ret    

c0105998 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105998:	55                   	push   %ebp
c0105999:	89 e5                	mov    %esp,%ebp
c010599b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010599e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01059a5:	00 
c01059a6:	8b 45 10             	mov    0x10(%ebp),%eax
c01059a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b0:	89 04 24             	mov    %eax,(%esp)
c01059b3:	e8 9f fd ff ff       	call   c0105757 <get_pte>
c01059b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01059bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01059bf:	75 0a                	jne    c01059cb <page_insert+0x33>
        return -E_NO_MEM;
c01059c1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01059c6:	e9 84 00 00 00       	jmp    c0105a4f <page_insert+0xb7>
    }
    page_ref_inc(page);
c01059cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ce:	89 04 24             	mov    %eax,(%esp)
c01059d1:	e8 ce f4 ff ff       	call   c0104ea4 <page_ref_inc>
    if (*ptep & PTE_P) {
c01059d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059d9:	8b 00                	mov    (%eax),%eax
c01059db:	83 e0 01             	and    $0x1,%eax
c01059de:	85 c0                	test   %eax,%eax
c01059e0:	74 3e                	je     c0105a20 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01059e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059e5:	8b 00                	mov    (%eax),%eax
c01059e7:	89 04 24             	mov    %eax,(%esp)
c01059ea:	e8 43 f4 ff ff       	call   c0104e32 <pte2page>
c01059ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01059f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01059f8:	75 0d                	jne    c0105a07 <page_insert+0x6f>
            page_ref_dec(page);
c01059fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059fd:	89 04 24             	mov    %eax,(%esp)
c0105a00:	e8 b6 f4 ff ff       	call   c0104ebb <page_ref_dec>
c0105a05:	eb 19                	jmp    c0105a20 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a11:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a18:	89 04 24             	mov    %eax,(%esp)
c0105a1b:	e8 cd fe ff ff       	call   c01058ed <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105a20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a23:	89 04 24             	mov    %eax,(%esp)
c0105a26:	e8 51 f3 ff ff       	call   c0104d7c <page2pa>
c0105a2b:	0b 45 14             	or     0x14(%ebp),%eax
c0105a2e:	83 c8 01             	or     $0x1,%eax
c0105a31:	89 c2                	mov    %eax,%edx
c0105a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a36:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105a38:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a42:	89 04 24             	mov    %eax,(%esp)
c0105a45:	e8 09 00 00 00       	call   c0105a53 <tlb_invalidate>
    return 0;
c0105a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a4f:	89 ec                	mov    %ebp,%esp
c0105a51:	5d                   	pop    %ebp
c0105a52:	c3                   	ret    

c0105a53 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105a53:	55                   	push   %ebp
c0105a54:	89 e5                	mov    %esp,%ebp
c0105a56:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105a59:	0f 20 d8             	mov    %cr3,%eax
c0105a5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105a5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0105a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a68:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105a6f:	77 23                	ja     c0105a94 <tlb_invalidate+0x41>
c0105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a74:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a78:	c7 44 24 08 b8 af 10 	movl   $0xc010afb8,0x8(%esp)
c0105a7f:	c0 
c0105a80:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0105a87:	00 
c0105a88:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105a8f:	e8 82 b2 ff ff       	call   c0100d16 <__panic>
c0105a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a97:	05 00 00 00 40       	add    $0x40000000,%eax
c0105a9c:	39 d0                	cmp    %edx,%eax
c0105a9e:	75 0d                	jne    c0105aad <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0105aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa3:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105aa9:	0f 01 38             	invlpg (%eax)
}
c0105aac:	90                   	nop
    }
}
c0105aad:	90                   	nop
c0105aae:	89 ec                	mov    %ebp,%esp
c0105ab0:	5d                   	pop    %ebp
c0105ab1:	c3                   	ret    

c0105ab2 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105ab2:	55                   	push   %ebp
c0105ab3:	89 e5                	mov    %esp,%ebp
c0105ab5:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0105ab8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105abf:	e8 d8 f5 ff ff       	call   c010509c <alloc_pages>
c0105ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105ac7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105acb:	0f 84 a7 00 00 00    	je     c0105b78 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105ad1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ad4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105adb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae9:	89 04 24             	mov    %eax,(%esp)
c0105aec:	e8 a7 fe ff ff       	call   c0105998 <page_insert>
c0105af1:	85 c0                	test   %eax,%eax
c0105af3:	74 1a                	je     c0105b0f <pgdir_alloc_page+0x5d>
            free_page(page);
c0105af5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105afc:	00 
c0105afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b00:	89 04 24             	mov    %eax,(%esp)
c0105b03:	e8 01 f6 ff ff       	call   c0105109 <free_pages>
            return NULL;
c0105b08:	b8 00 00 00 00       	mov    $0x0,%eax
c0105b0d:	eb 6c                	jmp    c0105b7b <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105b0f:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c0105b14:	85 c0                	test   %eax,%eax
c0105b16:	74 60                	je     c0105b78 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0105b18:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c0105b1d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105b24:	00 
c0105b25:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b28:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b33:	89 04 24             	mov    %eax,(%esp)
c0105b36:	e8 3a 0e 00 00       	call   c0106975 <swap_map_swappable>
            page->pra_vaddr=la;
c0105b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b41:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b47:	89 04 24             	mov    %eax,(%esp)
c0105b4a:	e8 3d f3 ff ff       	call   c0104e8c <page_ref>
c0105b4f:	83 f8 01             	cmp    $0x1,%eax
c0105b52:	74 24                	je     c0105b78 <pgdir_alloc_page+0xc6>
c0105b54:	c7 44 24 0c 3c b0 10 	movl   $0xc010b03c,0xc(%esp)
c0105b5b:	c0 
c0105b5c:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105b63:	c0 
c0105b64:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0105b6b:	00 
c0105b6c:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105b73:	e8 9e b1 ff ff       	call   c0100d16 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0105b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b7b:	89 ec                	mov    %ebp,%esp
c0105b7d:	5d                   	pop    %ebp
c0105b7e:	c3                   	ret    

c0105b7f <check_alloc_page>:

static void
check_alloc_page(void) {
c0105b7f:	55                   	push   %ebp
c0105b80:	89 e5                	mov    %esp,%ebp
c0105b82:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105b85:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105b8a:	8b 40 18             	mov    0x18(%eax),%eax
c0105b8d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0105b8f:	c7 04 24 50 b0 10 c0 	movl   $0xc010b050,(%esp)
c0105b96:	e8 d2 a7 ff ff       	call   c010036d <cprintf>
}
c0105b9b:	90                   	nop
c0105b9c:	89 ec                	mov    %ebp,%esp
c0105b9e:	5d                   	pop    %ebp
c0105b9f:	c3                   	ret    

c0105ba0 <check_pgdir>:

static void
check_pgdir(void) {
c0105ba0:	55                   	push   %ebp
c0105ba1:	89 e5                	mov    %esp,%ebp
c0105ba3:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105ba6:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0105bab:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0105bb0:	76 24                	jbe    c0105bd6 <check_pgdir+0x36>
c0105bb2:	c7 44 24 0c 6f b0 10 	movl   $0xc010b06f,0xc(%esp)
c0105bb9:	c0 
c0105bba:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105bc1:	c0 
c0105bc2:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0105bc9:	00 
c0105bca:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105bd1:	e8 40 b1 ff ff       	call   c0100d16 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105bd6:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105bdb:	85 c0                	test   %eax,%eax
c0105bdd:	74 0e                	je     c0105bed <check_pgdir+0x4d>
c0105bdf:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105be4:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105be9:	85 c0                	test   %eax,%eax
c0105beb:	74 24                	je     c0105c11 <check_pgdir+0x71>
c0105bed:	c7 44 24 0c 8c b0 10 	movl   $0xc010b08c,0xc(%esp)
c0105bf4:	c0 
c0105bf5:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105bfc:	c0 
c0105bfd:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0105c04:	00 
c0105c05:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105c0c:	e8 05 b1 ff ff       	call   c0100d16 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105c11:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105c16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c1d:	00 
c0105c1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105c25:	00 
c0105c26:	89 04 24             	mov    %eax,(%esp)
c0105c29:	e8 64 fc ff ff       	call   c0105892 <get_page>
c0105c2e:	85 c0                	test   %eax,%eax
c0105c30:	74 24                	je     c0105c56 <check_pgdir+0xb6>
c0105c32:	c7 44 24 0c c4 b0 10 	movl   $0xc010b0c4,0xc(%esp)
c0105c39:	c0 
c0105c3a:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105c41:	c0 
c0105c42:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0105c49:	00 
c0105c4a:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105c51:	e8 c0 b0 ff ff       	call   c0100d16 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105c56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c5d:	e8 3a f4 ff ff       	call   c010509c <alloc_pages>
c0105c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105c65:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105c6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105c71:	00 
c0105c72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c79:	00 
c0105c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c7d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c81:	89 04 24             	mov    %eax,(%esp)
c0105c84:	e8 0f fd ff ff       	call   c0105998 <page_insert>
c0105c89:	85 c0                	test   %eax,%eax
c0105c8b:	74 24                	je     c0105cb1 <check_pgdir+0x111>
c0105c8d:	c7 44 24 0c ec b0 10 	movl   $0xc010b0ec,0xc(%esp)
c0105c94:	c0 
c0105c95:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105c9c:	c0 
c0105c9d:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0105ca4:	00 
c0105ca5:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105cac:	e8 65 b0 ff ff       	call   c0100d16 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0105cb1:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105cb6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105cbd:	00 
c0105cbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105cc5:	00 
c0105cc6:	89 04 24             	mov    %eax,(%esp)
c0105cc9:	e8 89 fa ff ff       	call   c0105757 <get_pte>
c0105cce:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cd1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105cd5:	75 24                	jne    c0105cfb <check_pgdir+0x15b>
c0105cd7:	c7 44 24 0c 18 b1 10 	movl   $0xc010b118,0xc(%esp)
c0105cde:	c0 
c0105cdf:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105ce6:	c0 
c0105ce7:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0105cee:	00 
c0105cef:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105cf6:	e8 1b b0 ff ff       	call   c0100d16 <__panic>
    assert(pte2page(*ptep) == p1);
c0105cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cfe:	8b 00                	mov    (%eax),%eax
c0105d00:	89 04 24             	mov    %eax,(%esp)
c0105d03:	e8 2a f1 ff ff       	call   c0104e32 <pte2page>
c0105d08:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105d0b:	74 24                	je     c0105d31 <check_pgdir+0x191>
c0105d0d:	c7 44 24 0c 45 b1 10 	movl   $0xc010b145,0xc(%esp)
c0105d14:	c0 
c0105d15:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105d1c:	c0 
c0105d1d:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0105d24:	00 
c0105d25:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105d2c:	e8 e5 af ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p1) == 1);
c0105d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d34:	89 04 24             	mov    %eax,(%esp)
c0105d37:	e8 50 f1 ff ff       	call   c0104e8c <page_ref>
c0105d3c:	83 f8 01             	cmp    $0x1,%eax
c0105d3f:	74 24                	je     c0105d65 <check_pgdir+0x1c5>
c0105d41:	c7 44 24 0c 5b b1 10 	movl   $0xc010b15b,0xc(%esp)
c0105d48:	c0 
c0105d49:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105d50:	c0 
c0105d51:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0105d58:	00 
c0105d59:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105d60:	e8 b1 af ff ff       	call   c0100d16 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105d65:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105d6a:	8b 00                	mov    (%eax),%eax
c0105d6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105d71:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d77:	c1 e8 0c             	shr    $0xc,%eax
c0105d7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d7d:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0105d82:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105d85:	72 23                	jb     c0105daa <check_pgdir+0x20a>
c0105d87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d8e:	c7 44 24 08 14 af 10 	movl   $0xc010af14,0x8(%esp)
c0105d95:	c0 
c0105d96:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0105d9d:	00 
c0105d9e:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105da5:	e8 6c af ff ff       	call   c0100d16 <__panic>
c0105daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105dad:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105db2:	83 c0 04             	add    $0x4,%eax
c0105db5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105db8:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105dbd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105dc4:	00 
c0105dc5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105dcc:	00 
c0105dcd:	89 04 24             	mov    %eax,(%esp)
c0105dd0:	e8 82 f9 ff ff       	call   c0105757 <get_pte>
c0105dd5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105dd8:	74 24                	je     c0105dfe <check_pgdir+0x25e>
c0105dda:	c7 44 24 0c 70 b1 10 	movl   $0xc010b170,0xc(%esp)
c0105de1:	c0 
c0105de2:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105de9:	c0 
c0105dea:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105df1:	00 
c0105df2:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105df9:	e8 18 af ff ff       	call   c0100d16 <__panic>

    p2 = alloc_page();
c0105dfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e05:	e8 92 f2 ff ff       	call   c010509c <alloc_pages>
c0105e0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105e0d:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105e12:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0105e19:	00 
c0105e1a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105e21:	00 
c0105e22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105e25:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e29:	89 04 24             	mov    %eax,(%esp)
c0105e2c:	e8 67 fb ff ff       	call   c0105998 <page_insert>
c0105e31:	85 c0                	test   %eax,%eax
c0105e33:	74 24                	je     c0105e59 <check_pgdir+0x2b9>
c0105e35:	c7 44 24 0c 98 b1 10 	movl   $0xc010b198,0xc(%esp)
c0105e3c:	c0 
c0105e3d:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105e44:	c0 
c0105e45:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0105e4c:	00 
c0105e4d:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105e54:	e8 bd ae ff ff       	call   c0100d16 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105e59:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105e5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e65:	00 
c0105e66:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105e6d:	00 
c0105e6e:	89 04 24             	mov    %eax,(%esp)
c0105e71:	e8 e1 f8 ff ff       	call   c0105757 <get_pte>
c0105e76:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e7d:	75 24                	jne    c0105ea3 <check_pgdir+0x303>
c0105e7f:	c7 44 24 0c d0 b1 10 	movl   $0xc010b1d0,0xc(%esp)
c0105e86:	c0 
c0105e87:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105e8e:	c0 
c0105e8f:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105e96:	00 
c0105e97:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105e9e:	e8 73 ae ff ff       	call   c0100d16 <__panic>
    assert(*ptep & PTE_U);
c0105ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ea6:	8b 00                	mov    (%eax),%eax
c0105ea8:	83 e0 04             	and    $0x4,%eax
c0105eab:	85 c0                	test   %eax,%eax
c0105ead:	75 24                	jne    c0105ed3 <check_pgdir+0x333>
c0105eaf:	c7 44 24 0c 00 b2 10 	movl   $0xc010b200,0xc(%esp)
c0105eb6:	c0 
c0105eb7:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105ebe:	c0 
c0105ebf:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105ec6:	00 
c0105ec7:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105ece:	e8 43 ae ff ff       	call   c0100d16 <__panic>
    assert(*ptep & PTE_W);
c0105ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ed6:	8b 00                	mov    (%eax),%eax
c0105ed8:	83 e0 02             	and    $0x2,%eax
c0105edb:	85 c0                	test   %eax,%eax
c0105edd:	75 24                	jne    c0105f03 <check_pgdir+0x363>
c0105edf:	c7 44 24 0c 0e b2 10 	movl   $0xc010b20e,0xc(%esp)
c0105ee6:	c0 
c0105ee7:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105eee:	c0 
c0105eef:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105ef6:	00 
c0105ef7:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105efe:	e8 13 ae ff ff       	call   c0100d16 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105f03:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105f08:	8b 00                	mov    (%eax),%eax
c0105f0a:	83 e0 04             	and    $0x4,%eax
c0105f0d:	85 c0                	test   %eax,%eax
c0105f0f:	75 24                	jne    c0105f35 <check_pgdir+0x395>
c0105f11:	c7 44 24 0c 1c b2 10 	movl   $0xc010b21c,0xc(%esp)
c0105f18:	c0 
c0105f19:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105f20:	c0 
c0105f21:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0105f28:	00 
c0105f29:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105f30:	e8 e1 ad ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p2) == 1);
c0105f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f38:	89 04 24             	mov    %eax,(%esp)
c0105f3b:	e8 4c ef ff ff       	call   c0104e8c <page_ref>
c0105f40:	83 f8 01             	cmp    $0x1,%eax
c0105f43:	74 24                	je     c0105f69 <check_pgdir+0x3c9>
c0105f45:	c7 44 24 0c 32 b2 10 	movl   $0xc010b232,0xc(%esp)
c0105f4c:	c0 
c0105f4d:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105f54:	c0 
c0105f55:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0105f5c:	00 
c0105f5d:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105f64:	e8 ad ad ff ff       	call   c0100d16 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105f69:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105f6e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105f75:	00 
c0105f76:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105f7d:	00 
c0105f7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f81:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f85:	89 04 24             	mov    %eax,(%esp)
c0105f88:	e8 0b fa ff ff       	call   c0105998 <page_insert>
c0105f8d:	85 c0                	test   %eax,%eax
c0105f8f:	74 24                	je     c0105fb5 <check_pgdir+0x415>
c0105f91:	c7 44 24 0c 44 b2 10 	movl   $0xc010b244,0xc(%esp)
c0105f98:	c0 
c0105f99:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105fa0:	c0 
c0105fa1:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105fa8:	00 
c0105fa9:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105fb0:	e8 61 ad ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p1) == 2);
c0105fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fb8:	89 04 24             	mov    %eax,(%esp)
c0105fbb:	e8 cc ee ff ff       	call   c0104e8c <page_ref>
c0105fc0:	83 f8 02             	cmp    $0x2,%eax
c0105fc3:	74 24                	je     c0105fe9 <check_pgdir+0x449>
c0105fc5:	c7 44 24 0c 70 b2 10 	movl   $0xc010b270,0xc(%esp)
c0105fcc:	c0 
c0105fcd:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0105fd4:	c0 
c0105fd5:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105fdc:	00 
c0105fdd:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0105fe4:	e8 2d ad ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p2) == 0);
c0105fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fec:	89 04 24             	mov    %eax,(%esp)
c0105fef:	e8 98 ee ff ff       	call   c0104e8c <page_ref>
c0105ff4:	85 c0                	test   %eax,%eax
c0105ff6:	74 24                	je     c010601c <check_pgdir+0x47c>
c0105ff8:	c7 44 24 0c 82 b2 10 	movl   $0xc010b282,0xc(%esp)
c0105fff:	c0 
c0106000:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106007:	c0 
c0106008:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c010600f:	00 
c0106010:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106017:	e8 fa ac ff ff       	call   c0100d16 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010601c:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106021:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106028:	00 
c0106029:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106030:	00 
c0106031:	89 04 24             	mov    %eax,(%esp)
c0106034:	e8 1e f7 ff ff       	call   c0105757 <get_pte>
c0106039:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010603c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106040:	75 24                	jne    c0106066 <check_pgdir+0x4c6>
c0106042:	c7 44 24 0c d0 b1 10 	movl   $0xc010b1d0,0xc(%esp)
c0106049:	c0 
c010604a:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106051:	c0 
c0106052:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0106059:	00 
c010605a:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106061:	e8 b0 ac ff ff       	call   c0100d16 <__panic>
    assert(pte2page(*ptep) == p1);
c0106066:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106069:	8b 00                	mov    (%eax),%eax
c010606b:	89 04 24             	mov    %eax,(%esp)
c010606e:	e8 bf ed ff ff       	call   c0104e32 <pte2page>
c0106073:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106076:	74 24                	je     c010609c <check_pgdir+0x4fc>
c0106078:	c7 44 24 0c 45 b1 10 	movl   $0xc010b145,0xc(%esp)
c010607f:	c0 
c0106080:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106087:	c0 
c0106088:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c010608f:	00 
c0106090:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106097:	e8 7a ac ff ff       	call   c0100d16 <__panic>
    assert((*ptep & PTE_U) == 0);
c010609c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010609f:	8b 00                	mov    (%eax),%eax
c01060a1:	83 e0 04             	and    $0x4,%eax
c01060a4:	85 c0                	test   %eax,%eax
c01060a6:	74 24                	je     c01060cc <check_pgdir+0x52c>
c01060a8:	c7 44 24 0c 94 b2 10 	movl   $0xc010b294,0xc(%esp)
c01060af:	c0 
c01060b0:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01060b7:	c0 
c01060b8:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c01060bf:	00 
c01060c0:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01060c7:	e8 4a ac ff ff       	call   c0100d16 <__panic>

    page_remove(boot_pgdir, 0x0);
c01060cc:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01060d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01060d8:	00 
c01060d9:	89 04 24             	mov    %eax,(%esp)
c01060dc:	e8 70 f8 ff ff       	call   c0105951 <page_remove>
    assert(page_ref(p1) == 1);
c01060e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060e4:	89 04 24             	mov    %eax,(%esp)
c01060e7:	e8 a0 ed ff ff       	call   c0104e8c <page_ref>
c01060ec:	83 f8 01             	cmp    $0x1,%eax
c01060ef:	74 24                	je     c0106115 <check_pgdir+0x575>
c01060f1:	c7 44 24 0c 5b b1 10 	movl   $0xc010b15b,0xc(%esp)
c01060f8:	c0 
c01060f9:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106100:	c0 
c0106101:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0106108:	00 
c0106109:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106110:	e8 01 ac ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p2) == 0);
c0106115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106118:	89 04 24             	mov    %eax,(%esp)
c010611b:	e8 6c ed ff ff       	call   c0104e8c <page_ref>
c0106120:	85 c0                	test   %eax,%eax
c0106122:	74 24                	je     c0106148 <check_pgdir+0x5a8>
c0106124:	c7 44 24 0c 82 b2 10 	movl   $0xc010b282,0xc(%esp)
c010612b:	c0 
c010612c:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106133:	c0 
c0106134:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c010613b:	00 
c010613c:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106143:	e8 ce ab ff ff       	call   c0100d16 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106148:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010614d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106154:	00 
c0106155:	89 04 24             	mov    %eax,(%esp)
c0106158:	e8 f4 f7 ff ff       	call   c0105951 <page_remove>
    assert(page_ref(p1) == 0);
c010615d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106160:	89 04 24             	mov    %eax,(%esp)
c0106163:	e8 24 ed ff ff       	call   c0104e8c <page_ref>
c0106168:	85 c0                	test   %eax,%eax
c010616a:	74 24                	je     c0106190 <check_pgdir+0x5f0>
c010616c:	c7 44 24 0c a9 b2 10 	movl   $0xc010b2a9,0xc(%esp)
c0106173:	c0 
c0106174:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c010617b:	c0 
c010617c:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0106183:	00 
c0106184:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010618b:	e8 86 ab ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p2) == 0);
c0106190:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106193:	89 04 24             	mov    %eax,(%esp)
c0106196:	e8 f1 ec ff ff       	call   c0104e8c <page_ref>
c010619b:	85 c0                	test   %eax,%eax
c010619d:	74 24                	je     c01061c3 <check_pgdir+0x623>
c010619f:	c7 44 24 0c 82 b2 10 	movl   $0xc010b282,0xc(%esp)
c01061a6:	c0 
c01061a7:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01061ae:	c0 
c01061af:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c01061b6:	00 
c01061b7:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01061be:	e8 53 ab ff ff       	call   c0100d16 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01061c3:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01061c8:	8b 00                	mov    (%eax),%eax
c01061ca:	89 04 24             	mov    %eax,(%esp)
c01061cd:	e8 a0 ec ff ff       	call   c0104e72 <pde2page>
c01061d2:	89 04 24             	mov    %eax,(%esp)
c01061d5:	e8 b2 ec ff ff       	call   c0104e8c <page_ref>
c01061da:	83 f8 01             	cmp    $0x1,%eax
c01061dd:	74 24                	je     c0106203 <check_pgdir+0x663>
c01061df:	c7 44 24 0c bc b2 10 	movl   $0xc010b2bc,0xc(%esp)
c01061e6:	c0 
c01061e7:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01061ee:	c0 
c01061ef:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c01061f6:	00 
c01061f7:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01061fe:	e8 13 ab ff ff       	call   c0100d16 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0106203:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106208:	8b 00                	mov    (%eax),%eax
c010620a:	89 04 24             	mov    %eax,(%esp)
c010620d:	e8 60 ec ff ff       	call   c0104e72 <pde2page>
c0106212:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106219:	00 
c010621a:	89 04 24             	mov    %eax,(%esp)
c010621d:	e8 e7 ee ff ff       	call   c0105109 <free_pages>
    boot_pgdir[0] = 0;
c0106222:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c010622d:	c7 04 24 e3 b2 10 c0 	movl   $0xc010b2e3,(%esp)
c0106234:	e8 34 a1 ff ff       	call   c010036d <cprintf>
}
c0106239:	90                   	nop
c010623a:	89 ec                	mov    %ebp,%esp
c010623c:	5d                   	pop    %ebp
c010623d:	c3                   	ret    

c010623e <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c010623e:	55                   	push   %ebp
c010623f:	89 e5                	mov    %esp,%ebp
c0106241:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106244:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010624b:	e9 ca 00 00 00       	jmp    c010631a <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0106250:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106253:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106259:	c1 e8 0c             	shr    $0xc,%eax
c010625c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010625f:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0106264:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0106267:	72 23                	jb     c010628c <check_boot_pgdir+0x4e>
c0106269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010626c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106270:	c7 44 24 08 14 af 10 	movl   $0xc010af14,0x8(%esp)
c0106277:	c0 
c0106278:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c010627f:	00 
c0106280:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106287:	e8 8a aa ff ff       	call   c0100d16 <__panic>
c010628c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010628f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106294:	89 c2                	mov    %eax,%edx
c0106296:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010629b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01062a2:	00 
c01062a3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062a7:	89 04 24             	mov    %eax,(%esp)
c01062aa:	e8 a8 f4 ff ff       	call   c0105757 <get_pte>
c01062af:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01062b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01062b6:	75 24                	jne    c01062dc <check_boot_pgdir+0x9e>
c01062b8:	c7 44 24 0c 00 b3 10 	movl   $0xc010b300,0xc(%esp)
c01062bf:	c0 
c01062c0:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01062c7:	c0 
c01062c8:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c01062cf:	00 
c01062d0:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01062d7:	e8 3a aa ff ff       	call   c0100d16 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01062dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01062df:	8b 00                	mov    (%eax),%eax
c01062e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01062e6:	89 c2                	mov    %eax,%edx
c01062e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062eb:	39 c2                	cmp    %eax,%edx
c01062ed:	74 24                	je     c0106313 <check_boot_pgdir+0xd5>
c01062ef:	c7 44 24 0c 3d b3 10 	movl   $0xc010b33d,0xc(%esp)
c01062f6:	c0 
c01062f7:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01062fe:	c0 
c01062ff:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0106306:	00 
c0106307:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010630e:	e8 03 aa ff ff       	call   c0100d16 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0106313:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010631a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010631d:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0106322:	39 c2                	cmp    %eax,%edx
c0106324:	0f 82 26 ff ff ff    	jb     c0106250 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c010632a:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010632f:	05 ac 0f 00 00       	add    $0xfac,%eax
c0106334:	8b 00                	mov    (%eax),%eax
c0106336:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010633b:	89 c2                	mov    %eax,%edx
c010633d:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106342:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106345:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010634c:	77 23                	ja     c0106371 <check_boot_pgdir+0x133>
c010634e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106351:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106355:	c7 44 24 08 b8 af 10 	movl   $0xc010afb8,0x8(%esp)
c010635c:	c0 
c010635d:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0106364:	00 
c0106365:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010636c:	e8 a5 a9 ff ff       	call   c0100d16 <__panic>
c0106371:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106374:	05 00 00 00 40       	add    $0x40000000,%eax
c0106379:	39 d0                	cmp    %edx,%eax
c010637b:	74 24                	je     c01063a1 <check_boot_pgdir+0x163>
c010637d:	c7 44 24 0c 54 b3 10 	movl   $0xc010b354,0xc(%esp)
c0106384:	c0 
c0106385:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c010638c:	c0 
c010638d:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0106394:	00 
c0106395:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010639c:	e8 75 a9 ff ff       	call   c0100d16 <__panic>

    assert(boot_pgdir[0] == 0);
c01063a1:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01063a6:	8b 00                	mov    (%eax),%eax
c01063a8:	85 c0                	test   %eax,%eax
c01063aa:	74 24                	je     c01063d0 <check_boot_pgdir+0x192>
c01063ac:	c7 44 24 0c 88 b3 10 	movl   $0xc010b388,0xc(%esp)
c01063b3:	c0 
c01063b4:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01063bb:	c0 
c01063bc:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c01063c3:	00 
c01063c4:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01063cb:	e8 46 a9 ff ff       	call   c0100d16 <__panic>

    struct Page *p;
    p = alloc_page();
c01063d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01063d7:	e8 c0 ec ff ff       	call   c010509c <alloc_pages>
c01063dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01063df:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01063e4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01063eb:	00 
c01063ec:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01063f3:	00 
c01063f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01063f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063fb:	89 04 24             	mov    %eax,(%esp)
c01063fe:	e8 95 f5 ff ff       	call   c0105998 <page_insert>
c0106403:	85 c0                	test   %eax,%eax
c0106405:	74 24                	je     c010642b <check_boot_pgdir+0x1ed>
c0106407:	c7 44 24 0c 9c b3 10 	movl   $0xc010b39c,0xc(%esp)
c010640e:	c0 
c010640f:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106416:	c0 
c0106417:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c010641e:	00 
c010641f:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106426:	e8 eb a8 ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p) == 1);
c010642b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010642e:	89 04 24             	mov    %eax,(%esp)
c0106431:	e8 56 ea ff ff       	call   c0104e8c <page_ref>
c0106436:	83 f8 01             	cmp    $0x1,%eax
c0106439:	74 24                	je     c010645f <check_boot_pgdir+0x221>
c010643b:	c7 44 24 0c ca b3 10 	movl   $0xc010b3ca,0xc(%esp)
c0106442:	c0 
c0106443:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c010644a:	c0 
c010644b:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c0106452:	00 
c0106453:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c010645a:	e8 b7 a8 ff ff       	call   c0100d16 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010645f:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106464:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010646b:	00 
c010646c:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106473:	00 
c0106474:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106477:	89 54 24 04          	mov    %edx,0x4(%esp)
c010647b:	89 04 24             	mov    %eax,(%esp)
c010647e:	e8 15 f5 ff ff       	call   c0105998 <page_insert>
c0106483:	85 c0                	test   %eax,%eax
c0106485:	74 24                	je     c01064ab <check_boot_pgdir+0x26d>
c0106487:	c7 44 24 0c dc b3 10 	movl   $0xc010b3dc,0xc(%esp)
c010648e:	c0 
c010648f:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106496:	c0 
c0106497:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c010649e:	00 
c010649f:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01064a6:	e8 6b a8 ff ff       	call   c0100d16 <__panic>
    assert(page_ref(p) == 2);
c01064ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01064ae:	89 04 24             	mov    %eax,(%esp)
c01064b1:	e8 d6 e9 ff ff       	call   c0104e8c <page_ref>
c01064b6:	83 f8 02             	cmp    $0x2,%eax
c01064b9:	74 24                	je     c01064df <check_boot_pgdir+0x2a1>
c01064bb:	c7 44 24 0c 13 b4 10 	movl   $0xc010b413,0xc(%esp)
c01064c2:	c0 
c01064c3:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c01064ca:	c0 
c01064cb:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01064d2:	00 
c01064d3:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c01064da:	e8 37 a8 ff ff       	call   c0100d16 <__panic>

    const char *str = "ucore: Hello world!!";
c01064df:	c7 45 e8 24 b4 10 c0 	movl   $0xc010b424,-0x18(%ebp)
    strcpy((void *)0x100, str);
c01064e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01064ed:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01064f4:	e8 ba 37 00 00       	call   c0109cb3 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01064f9:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106500:	00 
c0106501:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106508:	e8 1e 38 00 00       	call   c0109d2b <strcmp>
c010650d:	85 c0                	test   %eax,%eax
c010650f:	74 24                	je     c0106535 <check_boot_pgdir+0x2f7>
c0106511:	c7 44 24 0c 3c b4 10 	movl   $0xc010b43c,0xc(%esp)
c0106518:	c0 
c0106519:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106520:	c0 
c0106521:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0106528:	00 
c0106529:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106530:	e8 e1 a7 ff ff       	call   c0100d16 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106535:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106538:	89 04 24             	mov    %eax,(%esp)
c010653b:	e8 9c e8 ff ff       	call   c0104ddc <page2kva>
c0106540:	05 00 01 00 00       	add    $0x100,%eax
c0106545:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106548:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010654f:	e8 05 37 00 00       	call   c0109c59 <strlen>
c0106554:	85 c0                	test   %eax,%eax
c0106556:	74 24                	je     c010657c <check_boot_pgdir+0x33e>
c0106558:	c7 44 24 0c 74 b4 10 	movl   $0xc010b474,0xc(%esp)
c010655f:	c0 
c0106560:	c7 44 24 08 01 b0 10 	movl   $0xc010b001,0x8(%esp)
c0106567:	c0 
c0106568:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c010656f:	00 
c0106570:	c7 04 24 dc af 10 c0 	movl   $0xc010afdc,(%esp)
c0106577:	e8 9a a7 ff ff       	call   c0100d16 <__panic>

    free_page(p);
c010657c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106583:	00 
c0106584:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106587:	89 04 24             	mov    %eax,(%esp)
c010658a:	e8 7a eb ff ff       	call   c0105109 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010658f:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106594:	8b 00                	mov    (%eax),%eax
c0106596:	89 04 24             	mov    %eax,(%esp)
c0106599:	e8 d4 e8 ff ff       	call   c0104e72 <pde2page>
c010659e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01065a5:	00 
c01065a6:	89 04 24             	mov    %eax,(%esp)
c01065a9:	e8 5b eb ff ff       	call   c0105109 <free_pages>
    boot_pgdir[0] = 0;
c01065ae:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01065b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01065b9:	c7 04 24 98 b4 10 c0 	movl   $0xc010b498,(%esp)
c01065c0:	e8 a8 9d ff ff       	call   c010036d <cprintf>
}
c01065c5:	90                   	nop
c01065c6:	89 ec                	mov    %ebp,%esp
c01065c8:	5d                   	pop    %ebp
c01065c9:	c3                   	ret    

c01065ca <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01065ca:	55                   	push   %ebp
c01065cb:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01065cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01065d0:	83 e0 04             	and    $0x4,%eax
c01065d3:	85 c0                	test   %eax,%eax
c01065d5:	74 04                	je     c01065db <perm2str+0x11>
c01065d7:	b0 75                	mov    $0x75,%al
c01065d9:	eb 02                	jmp    c01065dd <perm2str+0x13>
c01065db:	b0 2d                	mov    $0x2d,%al
c01065dd:	a2 28 c0 12 c0       	mov    %al,0xc012c028
    str[1] = 'r';
c01065e2:	c6 05 29 c0 12 c0 72 	movb   $0x72,0xc012c029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01065e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01065ec:	83 e0 02             	and    $0x2,%eax
c01065ef:	85 c0                	test   %eax,%eax
c01065f1:	74 04                	je     c01065f7 <perm2str+0x2d>
c01065f3:	b0 77                	mov    $0x77,%al
c01065f5:	eb 02                	jmp    c01065f9 <perm2str+0x2f>
c01065f7:	b0 2d                	mov    $0x2d,%al
c01065f9:	a2 2a c0 12 c0       	mov    %al,0xc012c02a
    str[3] = '\0';
c01065fe:	c6 05 2b c0 12 c0 00 	movb   $0x0,0xc012c02b
    return str;
c0106605:	b8 28 c0 12 c0       	mov    $0xc012c028,%eax
}
c010660a:	5d                   	pop    %ebp
c010660b:	c3                   	ret    

c010660c <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010660c:	55                   	push   %ebp
c010660d:	89 e5                	mov    %esp,%ebp
c010660f:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106612:	8b 45 10             	mov    0x10(%ebp),%eax
c0106615:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106618:	72 0d                	jb     c0106627 <get_pgtable_items+0x1b>
        return 0;
c010661a:	b8 00 00 00 00       	mov    $0x0,%eax
c010661f:	e9 98 00 00 00       	jmp    c01066bc <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0106624:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0106627:	8b 45 10             	mov    0x10(%ebp),%eax
c010662a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010662d:	73 18                	jae    c0106647 <get_pgtable_items+0x3b>
c010662f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106632:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106639:	8b 45 14             	mov    0x14(%ebp),%eax
c010663c:	01 d0                	add    %edx,%eax
c010663e:	8b 00                	mov    (%eax),%eax
c0106640:	83 e0 01             	and    $0x1,%eax
c0106643:	85 c0                	test   %eax,%eax
c0106645:	74 dd                	je     c0106624 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0106647:	8b 45 10             	mov    0x10(%ebp),%eax
c010664a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010664d:	73 68                	jae    c01066b7 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c010664f:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106653:	74 08                	je     c010665d <get_pgtable_items+0x51>
            *left_store = start;
c0106655:	8b 45 18             	mov    0x18(%ebp),%eax
c0106658:	8b 55 10             	mov    0x10(%ebp),%edx
c010665b:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010665d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106660:	8d 50 01             	lea    0x1(%eax),%edx
c0106663:	89 55 10             	mov    %edx,0x10(%ebp)
c0106666:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010666d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106670:	01 d0                	add    %edx,%eax
c0106672:	8b 00                	mov    (%eax),%eax
c0106674:	83 e0 07             	and    $0x7,%eax
c0106677:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010667a:	eb 03                	jmp    c010667f <get_pgtable_items+0x73>
            start ++;
c010667c:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010667f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106682:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106685:	73 1d                	jae    c01066a4 <get_pgtable_items+0x98>
c0106687:	8b 45 10             	mov    0x10(%ebp),%eax
c010668a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106691:	8b 45 14             	mov    0x14(%ebp),%eax
c0106694:	01 d0                	add    %edx,%eax
c0106696:	8b 00                	mov    (%eax),%eax
c0106698:	83 e0 07             	and    $0x7,%eax
c010669b:	89 c2                	mov    %eax,%edx
c010669d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01066a0:	39 c2                	cmp    %eax,%edx
c01066a2:	74 d8                	je     c010667c <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c01066a4:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01066a8:	74 08                	je     c01066b2 <get_pgtable_items+0xa6>
            *right_store = start;
c01066aa:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01066ad:	8b 55 10             	mov    0x10(%ebp),%edx
c01066b0:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01066b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01066b5:	eb 05                	jmp    c01066bc <get_pgtable_items+0xb0>
    }
    return 0;
c01066b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01066bc:	89 ec                	mov    %ebp,%esp
c01066be:	5d                   	pop    %ebp
c01066bf:	c3                   	ret    

c01066c0 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01066c0:	55                   	push   %ebp
c01066c1:	89 e5                	mov    %esp,%ebp
c01066c3:	57                   	push   %edi
c01066c4:	56                   	push   %esi
c01066c5:	53                   	push   %ebx
c01066c6:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01066c9:	c7 04 24 b8 b4 10 c0 	movl   $0xc010b4b8,(%esp)
c01066d0:	e8 98 9c ff ff       	call   c010036d <cprintf>
    size_t left, right = 0, perm;
c01066d5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01066dc:	e9 f2 00 00 00       	jmp    c01067d3 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01066e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066e4:	89 04 24             	mov    %eax,(%esp)
c01066e7:	e8 de fe ff ff       	call   c01065ca <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01066ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01066f2:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01066f4:	89 d6                	mov    %edx,%esi
c01066f6:	c1 e6 16             	shl    $0x16,%esi
c01066f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066fc:	89 d3                	mov    %edx,%ebx
c01066fe:	c1 e3 16             	shl    $0x16,%ebx
c0106701:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106704:	89 d1                	mov    %edx,%ecx
c0106706:	c1 e1 16             	shl    $0x16,%ecx
c0106709:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010670c:	8b 7d e0             	mov    -0x20(%ebp),%edi
c010670f:	29 fa                	sub    %edi,%edx
c0106711:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106715:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106719:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010671d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106721:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106725:	c7 04 24 e9 b4 10 c0 	movl   $0xc010b4e9,(%esp)
c010672c:	e8 3c 9c ff ff       	call   c010036d <cprintf>
        size_t l, r = left * NPTEENTRY;
c0106731:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106734:	c1 e0 0a             	shl    $0xa,%eax
c0106737:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010673a:	eb 50                	jmp    c010678c <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010673c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010673f:	89 04 24             	mov    %eax,(%esp)
c0106742:	e8 83 fe ff ff       	call   c01065ca <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106747:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010674a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010674d:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010674f:	89 d6                	mov    %edx,%esi
c0106751:	c1 e6 0c             	shl    $0xc,%esi
c0106754:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106757:	89 d3                	mov    %edx,%ebx
c0106759:	c1 e3 0c             	shl    $0xc,%ebx
c010675c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010675f:	89 d1                	mov    %edx,%ecx
c0106761:	c1 e1 0c             	shl    $0xc,%ecx
c0106764:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106767:	8b 7d d8             	mov    -0x28(%ebp),%edi
c010676a:	29 fa                	sub    %edi,%edx
c010676c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106770:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106774:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010677c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106780:	c7 04 24 08 b5 10 c0 	movl   $0xc010b508,(%esp)
c0106787:	e8 e1 9b ff ff       	call   c010036d <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010678c:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0106791:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106794:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106797:	89 d3                	mov    %edx,%ebx
c0106799:	c1 e3 0a             	shl    $0xa,%ebx
c010679c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010679f:	89 d1                	mov    %edx,%ecx
c01067a1:	c1 e1 0a             	shl    $0xa,%ecx
c01067a4:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01067a7:	89 54 24 14          	mov    %edx,0x14(%esp)
c01067ab:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01067ae:	89 54 24 10          	mov    %edx,0x10(%esp)
c01067b2:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01067b6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01067ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01067be:	89 0c 24             	mov    %ecx,(%esp)
c01067c1:	e8 46 fe ff ff       	call   c010660c <get_pgtable_items>
c01067c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01067cd:	0f 85 69 ff ff ff    	jne    c010673c <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01067d3:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01067d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01067db:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01067de:	89 54 24 14          	mov    %edx,0x14(%esp)
c01067e2:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01067e5:	89 54 24 10          	mov    %edx,0x10(%esp)
c01067e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01067ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01067f1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01067f8:	00 
c01067f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106800:	e8 07 fe ff ff       	call   c010660c <get_pgtable_items>
c0106805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106808:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010680c:	0f 85 cf fe ff ff    	jne    c01066e1 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106812:	c7 04 24 2c b5 10 c0 	movl   $0xc010b52c,(%esp)
c0106819:	e8 4f 9b ff ff       	call   c010036d <cprintf>
}
c010681e:	90                   	nop
c010681f:	83 c4 4c             	add    $0x4c,%esp
c0106822:	5b                   	pop    %ebx
c0106823:	5e                   	pop    %esi
c0106824:	5f                   	pop    %edi
c0106825:	5d                   	pop    %ebp
c0106826:	c3                   	ret    

c0106827 <pa2page>:
pa2page(uintptr_t pa) {
c0106827:	55                   	push   %ebp
c0106828:	89 e5                	mov    %esp,%ebp
c010682a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010682d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106830:	c1 e8 0c             	shr    $0xc,%eax
c0106833:	89 c2                	mov    %eax,%edx
c0106835:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c010683a:	39 c2                	cmp    %eax,%edx
c010683c:	72 1c                	jb     c010685a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010683e:	c7 44 24 08 60 b5 10 	movl   $0xc010b560,0x8(%esp)
c0106845:	c0 
c0106846:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010684d:	00 
c010684e:	c7 04 24 7f b5 10 c0 	movl   $0xc010b57f,(%esp)
c0106855:	e8 bc a4 ff ff       	call   c0100d16 <__panic>
    return &pages[PPN(pa)];
c010685a:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0106860:	8b 45 08             	mov    0x8(%ebp),%eax
c0106863:	c1 e8 0c             	shr    $0xc,%eax
c0106866:	c1 e0 05             	shl    $0x5,%eax
c0106869:	01 d0                	add    %edx,%eax
}
c010686b:	89 ec                	mov    %ebp,%esp
c010686d:	5d                   	pop    %ebp
c010686e:	c3                   	ret    

c010686f <pte2page>:
pte2page(pte_t pte) {
c010686f:	55                   	push   %ebp
c0106870:	89 e5                	mov    %esp,%ebp
c0106872:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106875:	8b 45 08             	mov    0x8(%ebp),%eax
c0106878:	83 e0 01             	and    $0x1,%eax
c010687b:	85 c0                	test   %eax,%eax
c010687d:	75 1c                	jne    c010689b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010687f:	c7 44 24 08 90 b5 10 	movl   $0xc010b590,0x8(%esp)
c0106886:	c0 
c0106887:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c010688e:	00 
c010688f:	c7 04 24 7f b5 10 c0 	movl   $0xc010b57f,(%esp)
c0106896:	e8 7b a4 ff ff       	call   c0100d16 <__panic>
    return pa2page(PTE_ADDR(pte));
c010689b:	8b 45 08             	mov    0x8(%ebp),%eax
c010689e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01068a3:	89 04 24             	mov    %eax,(%esp)
c01068a6:	e8 7c ff ff ff       	call   c0106827 <pa2page>
}
c01068ab:	89 ec                	mov    %ebp,%esp
c01068ad:	5d                   	pop    %ebp
c01068ae:	c3                   	ret    

c01068af <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01068af:	55                   	push   %ebp
c01068b0:	89 e5                	mov    %esp,%ebp
c01068b2:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01068b5:	e8 ad 1e 00 00       	call   c0108767 <swapfs_init>

     //一个磁盘最少1024个page，最多1<<24个page
     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01068ba:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c01068bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01068c4:	76 0c                	jbe    c01068d2 <swap_init+0x23>
c01068c6:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c01068cb:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01068d0:	76 25                	jbe    c01068f7 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01068d2:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c01068d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01068db:	c7 44 24 08 b1 b5 10 	movl   $0xc010b5b1,0x8(%esp)
c01068e2:	c0 
c01068e3:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
c01068ea:	00 
c01068eb:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c01068f2:	e8 1f a4 ff ff       	call   c0100d16 <__panic>
     }
     

     sm = &swap_manager_fifo;
c01068f7:	c7 05 00 c1 12 c0 60 	movl   $0xc0128a60,0xc012c100
c01068fe:	8a 12 c0 
     
     int r = sm->init();
c0106901:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106906:	8b 40 04             	mov    0x4(%eax),%eax
c0106909:	ff d0                	call   *%eax
c010690b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c010690e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106912:	75 26                	jne    c010693a <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106914:	c7 05 44 c0 12 c0 01 	movl   $0x1,0xc012c044
c010691b:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010691e:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106923:	8b 00                	mov    (%eax),%eax
c0106925:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106929:	c7 04 24 db b5 10 c0 	movl   $0xc010b5db,(%esp)
c0106930:	e8 38 9a ff ff       	call   c010036d <cprintf>
          check_swap();
c0106935:	e8 b0 04 00 00       	call   c0106dea <check_swap>
     }

     return r;
c010693a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010693d:	89 ec                	mov    %ebp,%esp
c010693f:	5d                   	pop    %ebp
c0106940:	c3                   	ret    

c0106941 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106941:	55                   	push   %ebp
c0106942:	89 e5                	mov    %esp,%ebp
c0106944:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106947:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c010694c:	8b 40 08             	mov    0x8(%eax),%eax
c010694f:	8b 55 08             	mov    0x8(%ebp),%edx
c0106952:	89 14 24             	mov    %edx,(%esp)
c0106955:	ff d0                	call   *%eax
}
c0106957:	89 ec                	mov    %ebp,%esp
c0106959:	5d                   	pop    %ebp
c010695a:	c3                   	ret    

c010695b <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010695b:	55                   	push   %ebp
c010695c:	89 e5                	mov    %esp,%ebp
c010695e:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106961:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106966:	8b 40 0c             	mov    0xc(%eax),%eax
c0106969:	8b 55 08             	mov    0x8(%ebp),%edx
c010696c:	89 14 24             	mov    %edx,(%esp)
c010696f:	ff d0                	call   *%eax
}
c0106971:	89 ec                	mov    %ebp,%esp
c0106973:	5d                   	pop    %ebp
c0106974:	c3                   	ret    

c0106975 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106975:	55                   	push   %ebp
c0106976:	89 e5                	mov    %esp,%ebp
c0106978:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c010697b:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106980:	8b 40 10             	mov    0x10(%eax),%eax
c0106983:	8b 55 14             	mov    0x14(%ebp),%edx
c0106986:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010698a:	8b 55 10             	mov    0x10(%ebp),%edx
c010698d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106991:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106994:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106998:	8b 55 08             	mov    0x8(%ebp),%edx
c010699b:	89 14 24             	mov    %edx,(%esp)
c010699e:	ff d0                	call   *%eax
}
c01069a0:	89 ec                	mov    %ebp,%esp
c01069a2:	5d                   	pop    %ebp
c01069a3:	c3                   	ret    

c01069a4 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01069a4:	55                   	push   %ebp
c01069a5:	89 e5                	mov    %esp,%ebp
c01069a7:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01069aa:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c01069af:	8b 40 14             	mov    0x14(%eax),%eax
c01069b2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01069b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069b9:	8b 55 08             	mov    0x8(%ebp),%edx
c01069bc:	89 14 24             	mov    %edx,(%esp)
c01069bf:	ff d0                	call   *%eax
}
c01069c1:	89 ec                	mov    %ebp,%esp
c01069c3:	5d                   	pop    %ebp
c01069c4:	c3                   	ret    

c01069c5 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01069c5:	55                   	push   %ebp
c01069c6:	89 e5                	mov    %esp,%ebp
c01069c8:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01069cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01069d2:	e9 53 01 00 00       	jmp    c0106b2a <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01069d7:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c01069dc:	8b 40 18             	mov    0x18(%eax),%eax
c01069df:	8b 55 10             	mov    0x10(%ebp),%edx
c01069e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01069e6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01069e9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069ed:	8b 55 08             	mov    0x8(%ebp),%edx
c01069f0:	89 14 24             	mov    %edx,(%esp)
c01069f3:	ff d0                	call   *%eax
c01069f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01069f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01069fc:	74 18                	je     c0106a16 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01069fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a05:	c7 04 24 f0 b5 10 c0 	movl   $0xc010b5f0,(%esp)
c0106a0c:	e8 5c 99 ff ff       	call   c010036d <cprintf>
c0106a11:	e9 20 01 00 00       	jmp    c0106b36 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106a16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a19:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106a1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a22:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106a2c:	00 
c0106a2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a34:	89 04 24             	mov    %eax,(%esp)
c0106a37:	e8 1b ed ff ff       	call   c0105757 <get_pte>
c0106a3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106a3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a42:	8b 00                	mov    (%eax),%eax
c0106a44:	83 e0 01             	and    $0x1,%eax
c0106a47:	85 c0                	test   %eax,%eax
c0106a49:	75 24                	jne    c0106a6f <swap_out+0xaa>
c0106a4b:	c7 44 24 0c 1d b6 10 	movl   $0xc010b61d,0xc(%esp)
c0106a52:	c0 
c0106a53:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106a5a:	c0 
c0106a5b:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106a62:	00 
c0106a63:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106a6a:	e8 a7 a2 ff ff       	call   c0100d16 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106a6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a75:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106a78:	c1 ea 0c             	shr    $0xc,%edx
c0106a7b:	42                   	inc    %edx
c0106a7c:	c1 e2 08             	shl    $0x8,%edx
c0106a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a83:	89 14 24             	mov    %edx,(%esp)
c0106a86:	e8 9b 1d 00 00       	call   c0108826 <swapfs_write>
c0106a8b:	85 c0                	test   %eax,%eax
c0106a8d:	74 34                	je     c0106ac3 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0106a8f:	c7 04 24 47 b6 10 c0 	movl   $0xc010b647,(%esp)
c0106a96:	e8 d2 98 ff ff       	call   c010036d <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106a9b:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106aa0:	8b 40 10             	mov    0x10(%eax),%eax
c0106aa3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106aa6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106aad:	00 
c0106aae:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106ab2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ab9:	8b 55 08             	mov    0x8(%ebp),%edx
c0106abc:	89 14 24             	mov    %edx,(%esp)
c0106abf:	ff d0                	call   *%eax
c0106ac1:	eb 64                	jmp    c0106b27 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ac6:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106ac9:	c1 e8 0c             	shr    $0xc,%eax
c0106acc:	40                   	inc    %eax
c0106acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106ad1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106adb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106adf:	c7 04 24 60 b6 10 c0 	movl   $0xc010b660,(%esp)
c0106ae6:	e8 82 98 ff ff       	call   c010036d <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106aeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106aee:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106af1:	c1 e8 0c             	shr    $0xc,%eax
c0106af4:	40                   	inc    %eax
c0106af5:	c1 e0 08             	shl    $0x8,%eax
c0106af8:	89 c2                	mov    %eax,%edx
c0106afa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106afd:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b02:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b09:	00 
c0106b0a:	89 04 24             	mov    %eax,(%esp)
c0106b0d:	e8 f7 e5 ff ff       	call   c0105109 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b15:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b18:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b1b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b1f:	89 04 24             	mov    %eax,(%esp)
c0106b22:	e8 2c ef ff ff       	call   c0105a53 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0106b27:	ff 45 f4             	incl   -0xc(%ebp)
c0106b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b2d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b30:	0f 85 a1 fe ff ff    	jne    c01069d7 <swap_out+0x12>
     }
     return i;
c0106b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106b39:	89 ec                	mov    %ebp,%esp
c0106b3b:	5d                   	pop    %ebp
c0106b3c:	c3                   	ret    

c0106b3d <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106b3d:	55                   	push   %ebp
c0106b3e:	89 e5                	mov    %esp,%ebp
c0106b40:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106b43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b4a:	e8 4d e5 ff ff       	call   c010509c <alloc_pages>
c0106b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106b52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106b56:	75 24                	jne    c0106b7c <swap_in+0x3f>
c0106b58:	c7 44 24 0c a0 b6 10 	movl   $0xc010b6a0,0xc(%esp)
c0106b5f:	c0 
c0106b60:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106b67:	c0 
c0106b68:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0106b6f:	00 
c0106b70:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106b77:	e8 9a a1 ff ff       	call   c0100d16 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106b7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b7f:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106b89:	00 
c0106b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106b8d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b91:	89 04 24             	mov    %eax,(%esp)
c0106b94:	e8 be eb ff ff       	call   c0105757 <get_pte>
c0106b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b9f:	8b 00                	mov    (%eax),%eax
c0106ba1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106ba4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ba8:	89 04 24             	mov    %eax,(%esp)
c0106bab:	e8 02 1c 00 00       	call   c01087b2 <swapfs_read>
c0106bb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106bb3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106bb7:	74 2a                	je     c0106be3 <swap_in+0xa6>
     {
        assert(r!=0);
c0106bb9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106bbd:	75 24                	jne    c0106be3 <swap_in+0xa6>
c0106bbf:	c7 44 24 0c ad b6 10 	movl   $0xc010b6ad,0xc(%esp)
c0106bc6:	c0 
c0106bc7:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106bce:	c0 
c0106bcf:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0106bd6:	00 
c0106bd7:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106bde:	e8 33 a1 ff ff       	call   c0100d16 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106be6:	8b 00                	mov    (%eax),%eax
c0106be8:	c1 e8 08             	shr    $0x8,%eax
c0106beb:	89 c2                	mov    %eax,%edx
c0106bed:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bf0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106bf4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106bf8:	c7 04 24 b4 b6 10 c0 	movl   $0xc010b6b4,(%esp)
c0106bff:	e8 69 97 ff ff       	call   c010036d <cprintf>
     *ptr_result=result;
c0106c04:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c07:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c0a:	89 10                	mov    %edx,(%eax)
     return 0;
c0106c0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c11:	89 ec                	mov    %ebp,%esp
c0106c13:	5d                   	pop    %ebp
c0106c14:	c3                   	ret    

c0106c15 <check_content_set>:



static inline void
check_content_set(void)
{
c0106c15:	55                   	push   %ebp
c0106c16:	89 e5                	mov    %esp,%ebp
c0106c18:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106c1b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106c20:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106c23:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106c28:	83 f8 01             	cmp    $0x1,%eax
c0106c2b:	74 24                	je     c0106c51 <check_content_set+0x3c>
c0106c2d:	c7 44 24 0c f2 b6 10 	movl   $0xc010b6f2,0xc(%esp)
c0106c34:	c0 
c0106c35:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106c3c:	c0 
c0106c3d:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0106c44:	00 
c0106c45:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106c4c:	e8 c5 a0 ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106c51:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106c56:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106c59:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106c5e:	83 f8 01             	cmp    $0x1,%eax
c0106c61:	74 24                	je     c0106c87 <check_content_set+0x72>
c0106c63:	c7 44 24 0c f2 b6 10 	movl   $0xc010b6f2,0xc(%esp)
c0106c6a:	c0 
c0106c6b:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106c72:	c0 
c0106c73:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106c7a:	00 
c0106c7b:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106c82:	e8 8f a0 ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106c87:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106c8c:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106c8f:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106c94:	83 f8 02             	cmp    $0x2,%eax
c0106c97:	74 24                	je     c0106cbd <check_content_set+0xa8>
c0106c99:	c7 44 24 0c 01 b7 10 	movl   $0xc010b701,0xc(%esp)
c0106ca0:	c0 
c0106ca1:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106ca8:	c0 
c0106ca9:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106cb0:	00 
c0106cb1:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106cb8:	e8 59 a0 ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106cbd:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106cc2:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106cc5:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106cca:	83 f8 02             	cmp    $0x2,%eax
c0106ccd:	74 24                	je     c0106cf3 <check_content_set+0xde>
c0106ccf:	c7 44 24 0c 01 b7 10 	movl   $0xc010b701,0xc(%esp)
c0106cd6:	c0 
c0106cd7:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106cde:	c0 
c0106cdf:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106ce6:	00 
c0106ce7:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106cee:	e8 23 a0 ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106cf3:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106cf8:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106cfb:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106d00:	83 f8 03             	cmp    $0x3,%eax
c0106d03:	74 24                	je     c0106d29 <check_content_set+0x114>
c0106d05:	c7 44 24 0c 10 b7 10 	movl   $0xc010b710,0xc(%esp)
c0106d0c:	c0 
c0106d0d:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106d14:	c0 
c0106d15:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106d1c:	00 
c0106d1d:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106d24:	e8 ed 9f ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106d29:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106d2e:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106d31:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106d36:	83 f8 03             	cmp    $0x3,%eax
c0106d39:	74 24                	je     c0106d5f <check_content_set+0x14a>
c0106d3b:	c7 44 24 0c 10 b7 10 	movl   $0xc010b710,0xc(%esp)
c0106d42:	c0 
c0106d43:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106d4a:	c0 
c0106d4b:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106d52:	00 
c0106d53:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106d5a:	e8 b7 9f ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106d5f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106d64:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106d67:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106d6c:	83 f8 04             	cmp    $0x4,%eax
c0106d6f:	74 24                	je     c0106d95 <check_content_set+0x180>
c0106d71:	c7 44 24 0c 1f b7 10 	movl   $0xc010b71f,0xc(%esp)
c0106d78:	c0 
c0106d79:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106d80:	c0 
c0106d81:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0106d88:	00 
c0106d89:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106d90:	e8 81 9f ff ff       	call   c0100d16 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106d95:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106d9a:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106d9d:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106da2:	83 f8 04             	cmp    $0x4,%eax
c0106da5:	74 24                	je     c0106dcb <check_content_set+0x1b6>
c0106da7:	c7 44 24 0c 1f b7 10 	movl   $0xc010b71f,0xc(%esp)
c0106dae:	c0 
c0106daf:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106db6:	c0 
c0106db7:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0106dbe:	00 
c0106dbf:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106dc6:	e8 4b 9f ff ff       	call   c0100d16 <__panic>
}
c0106dcb:	90                   	nop
c0106dcc:	89 ec                	mov    %ebp,%esp
c0106dce:	5d                   	pop    %ebp
c0106dcf:	c3                   	ret    

c0106dd0 <check_content_access>:

static inline int
check_content_access(void)
{
c0106dd0:	55                   	push   %ebp
c0106dd1:	89 e5                	mov    %esp,%ebp
c0106dd3:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106dd6:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106ddb:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106dde:	ff d0                	call   *%eax
c0106de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106de6:	89 ec                	mov    %ebp,%esp
c0106de8:	5d                   	pop    %ebp
c0106de9:	c3                   	ret    

c0106dea <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106dea:	55                   	push   %ebp
c0106deb:	89 e5                	mov    %esp,%ebp
c0106ded:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106df0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106df7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106dfe:	c7 45 e8 84 bf 12 c0 	movl   $0xc012bf84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106e05:	eb 6a                	jmp    c0106e71 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0106e07:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e0a:	83 e8 0c             	sub    $0xc,%eax
c0106e0d:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106e10:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106e13:	83 c0 04             	add    $0x4,%eax
c0106e16:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106e1d:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106e20:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106e23:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106e26:	0f a3 10             	bt     %edx,(%eax)
c0106e29:	19 c0                	sbb    %eax,%eax
c0106e2b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106e2e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106e32:	0f 95 c0             	setne  %al
c0106e35:	0f b6 c0             	movzbl %al,%eax
c0106e38:	85 c0                	test   %eax,%eax
c0106e3a:	75 24                	jne    c0106e60 <check_swap+0x76>
c0106e3c:	c7 44 24 0c 2e b7 10 	movl   $0xc010b72e,0xc(%esp)
c0106e43:	c0 
c0106e44:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106e4b:	c0 
c0106e4c:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0106e53:	00 
c0106e54:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106e5b:	e8 b6 9e ff ff       	call   c0100d16 <__panic>
        count ++, total += p->property;
c0106e60:	ff 45 f4             	incl   -0xc(%ebp)
c0106e63:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106e66:	8b 50 08             	mov    0x8(%eax),%edx
c0106e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e6c:	01 d0                	add    %edx,%eax
c0106e6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e74:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106e77:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106e7a:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106e80:	81 7d e8 84 bf 12 c0 	cmpl   $0xc012bf84,-0x18(%ebp)
c0106e87:	0f 85 7a ff ff ff    	jne    c0106e07 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0106e8d:	e8 ac e2 ff ff       	call   c010513e <nr_free_pages>
c0106e92:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106e95:	39 d0                	cmp    %edx,%eax
c0106e97:	74 24                	je     c0106ebd <check_swap+0xd3>
c0106e99:	c7 44 24 0c 3e b7 10 	movl   $0xc010b73e,0xc(%esp)
c0106ea0:	c0 
c0106ea1:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106ea8:	c0 
c0106ea9:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0106eb0:	00 
c0106eb1:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106eb8:	e8 59 9e ff ff       	call   c0100d16 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ec0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ecb:	c7 04 24 58 b7 10 c0 	movl   $0xc010b758,(%esp)
c0106ed2:	e8 96 94 ff ff       	call   c010036d <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106ed7:	e8 24 0b 00 00       	call   c0107a00 <mm_create>
c0106edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106edf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106ee3:	75 24                	jne    c0106f09 <check_swap+0x11f>
c0106ee5:	c7 44 24 0c 7e b7 10 	movl   $0xc010b77e,0xc(%esp)
c0106eec:	c0 
c0106eed:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106ef4:	c0 
c0106ef5:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0106efc:	00 
c0106efd:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106f04:	e8 0d 9e ff ff       	call   c0100d16 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106f09:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c0106f0e:	85 c0                	test   %eax,%eax
c0106f10:	74 24                	je     c0106f36 <check_swap+0x14c>
c0106f12:	c7 44 24 0c 89 b7 10 	movl   $0xc010b789,0xc(%esp)
c0106f19:	c0 
c0106f1a:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106f21:	c0 
c0106f22:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0106f29:	00 
c0106f2a:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106f31:	e8 e0 9d ff ff       	call   c0100d16 <__panic>

     check_mm_struct = mm;
c0106f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f39:	a3 0c c1 12 c0       	mov    %eax,0xc012c10c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106f3e:	8b 15 00 8a 12 c0    	mov    0xc0128a00,%edx
c0106f44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f47:	89 50 0c             	mov    %edx,0xc(%eax)
c0106f4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f4d:	8b 40 0c             	mov    0xc(%eax),%eax
c0106f50:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f56:	8b 00                	mov    (%eax),%eax
c0106f58:	85 c0                	test   %eax,%eax
c0106f5a:	74 24                	je     c0106f80 <check_swap+0x196>
c0106f5c:	c7 44 24 0c a1 b7 10 	movl   $0xc010b7a1,0xc(%esp)
c0106f63:	c0 
c0106f64:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106f6b:	c0 
c0106f6c:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0106f73:	00 
c0106f74:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106f7b:	e8 96 9d ff ff       	call   c0100d16 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106f80:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106f87:	00 
c0106f88:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106f8f:	00 
c0106f90:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106f97:	e8 df 0a 00 00       	call   c0107a7b <vma_create>
c0106f9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106f9f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106fa3:	75 24                	jne    c0106fc9 <check_swap+0x1df>
c0106fa5:	c7 44 24 0c af b7 10 	movl   $0xc010b7af,0xc(%esp)
c0106fac:	c0 
c0106fad:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0106fb4:	c0 
c0106fb5:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0106fbc:	00 
c0106fbd:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0106fc4:	e8 4d 9d ff ff       	call   c0100d16 <__panic>

     insert_vma_struct(mm, vma);
c0106fc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fd3:	89 04 24             	mov    %eax,(%esp)
c0106fd6:	e8 37 0c 00 00       	call   c0107c12 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106fdb:	c7 04 24 bc b7 10 c0 	movl   $0xc010b7bc,(%esp)
c0106fe2:	e8 86 93 ff ff       	call   c010036d <cprintf>
     pte_t *temp_ptep=NULL;
c0106fe7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ff1:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ff4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106ffb:	00 
c0106ffc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107003:	00 
c0107004:	89 04 24             	mov    %eax,(%esp)
c0107007:	e8 4b e7 ff ff       	call   c0105757 <get_pte>
c010700c:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c010700f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107013:	75 24                	jne    c0107039 <check_swap+0x24f>
c0107015:	c7 44 24 0c f0 b7 10 	movl   $0xc010b7f0,0xc(%esp)
c010701c:	c0 
c010701d:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0107024:	c0 
c0107025:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c010702c:	00 
c010702d:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0107034:	e8 dd 9c ff ff       	call   c0100d16 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0107039:	c7 04 24 04 b8 10 c0 	movl   $0xc010b804,(%esp)
c0107040:	e8 28 93 ff ff       	call   c010036d <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107045:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010704c:	e9 a2 00 00 00       	jmp    c01070f3 <check_swap+0x309>
          check_rp[i] = alloc_page();
c0107051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107058:	e8 3f e0 ff ff       	call   c010509c <alloc_pages>
c010705d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107060:	89 04 95 cc c0 12 c0 	mov    %eax,-0x3fed3f34(,%edx,4)
          assert(check_rp[i] != NULL );
c0107067:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010706a:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c0107071:	85 c0                	test   %eax,%eax
c0107073:	75 24                	jne    c0107099 <check_swap+0x2af>
c0107075:	c7 44 24 0c 28 b8 10 	movl   $0xc010b828,0xc(%esp)
c010707c:	c0 
c010707d:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0107084:	c0 
c0107085:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010708c:	00 
c010708d:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0107094:	e8 7d 9c ff ff       	call   c0100d16 <__panic>
          assert(!PageProperty(check_rp[i]));
c0107099:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010709c:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c01070a3:	83 c0 04             	add    $0x4,%eax
c01070a6:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01070ad:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01070b0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01070b3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01070b6:	0f a3 10             	bt     %edx,(%eax)
c01070b9:	19 c0                	sbb    %eax,%eax
c01070bb:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01070be:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01070c2:	0f 95 c0             	setne  %al
c01070c5:	0f b6 c0             	movzbl %al,%eax
c01070c8:	85 c0                	test   %eax,%eax
c01070ca:	74 24                	je     c01070f0 <check_swap+0x306>
c01070cc:	c7 44 24 0c 3c b8 10 	movl   $0xc010b83c,0xc(%esp)
c01070d3:	c0 
c01070d4:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c01070db:	c0 
c01070dc:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01070e3:	00 
c01070e4:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c01070eb:	e8 26 9c ff ff       	call   c0100d16 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01070f0:	ff 45 ec             	incl   -0x14(%ebp)
c01070f3:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01070f7:	0f 8e 54 ff ff ff    	jle    c0107051 <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c01070fd:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c0107102:	8b 15 88 bf 12 c0    	mov    0xc012bf88,%edx
c0107108:	89 45 98             	mov    %eax,-0x68(%ebp)
c010710b:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010710e:	c7 45 a4 84 bf 12 c0 	movl   $0xc012bf84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0107115:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107118:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010711b:	89 50 04             	mov    %edx,0x4(%eax)
c010711e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107121:	8b 50 04             	mov    0x4(%eax),%edx
c0107124:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107127:	89 10                	mov    %edx,(%eax)
}
c0107129:	90                   	nop
c010712a:	c7 45 a8 84 bf 12 c0 	movl   $0xc012bf84,-0x58(%ebp)
    return list->next == list;
c0107131:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107134:	8b 40 04             	mov    0x4(%eax),%eax
c0107137:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c010713a:	0f 94 c0             	sete   %al
c010713d:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0107140:	85 c0                	test   %eax,%eax
c0107142:	75 24                	jne    c0107168 <check_swap+0x37e>
c0107144:	c7 44 24 0c 57 b8 10 	movl   $0xc010b857,0xc(%esp)
c010714b:	c0 
c010714c:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0107153:	c0 
c0107154:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c010715b:	00 
c010715c:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0107163:	e8 ae 9b ff ff       	call   c0100d16 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107168:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c010716d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0107170:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0107177:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010717a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107181:	eb 1d                	jmp    c01071a0 <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c0107183:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107186:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c010718d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107194:	00 
c0107195:	89 04 24             	mov    %eax,(%esp)
c0107198:	e8 6c df ff ff       	call   c0105109 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010719d:	ff 45 ec             	incl   -0x14(%ebp)
c01071a0:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01071a4:	7e dd                	jle    c0107183 <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01071a6:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c01071ab:	83 f8 04             	cmp    $0x4,%eax
c01071ae:	74 24                	je     c01071d4 <check_swap+0x3ea>
c01071b0:	c7 44 24 0c 70 b8 10 	movl   $0xc010b870,0xc(%esp)
c01071b7:	c0 
c01071b8:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c01071bf:	c0 
c01071c0:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01071c7:	00 
c01071c8:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c01071cf:	e8 42 9b ff ff       	call   c0100d16 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01071d4:	c7 04 24 94 b8 10 c0 	movl   $0xc010b894,(%esp)
c01071db:	e8 8d 91 ff ff       	call   c010036d <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01071e0:	c7 05 10 c1 12 c0 00 	movl   $0x0,0xc012c110
c01071e7:	00 00 00 
     
     check_content_set();
c01071ea:	e8 26 fa ff ff       	call   c0106c15 <check_content_set>
     assert( nr_free == 0);         
c01071ef:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c01071f4:	85 c0                	test   %eax,%eax
c01071f6:	74 24                	je     c010721c <check_swap+0x432>
c01071f8:	c7 44 24 0c bb b8 10 	movl   $0xc010b8bb,0xc(%esp)
c01071ff:	c0 
c0107200:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0107207:	c0 
c0107208:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c010720f:	00 
c0107210:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0107217:	e8 fa 9a ff ff       	call   c0100d16 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010721c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107223:	eb 25                	jmp    c010724a <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0107225:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107228:	c7 04 85 60 c0 12 c0 	movl   $0xffffffff,-0x3fed3fa0(,%eax,4)
c010722f:	ff ff ff ff 
c0107233:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107236:	8b 14 85 60 c0 12 c0 	mov    -0x3fed3fa0(,%eax,4),%edx
c010723d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107240:	89 14 85 a0 c0 12 c0 	mov    %edx,-0x3fed3f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107247:	ff 45 ec             	incl   -0x14(%ebp)
c010724a:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010724e:	7e d5                	jle    c0107225 <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107250:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107257:	e9 e8 00 00 00       	jmp    c0107344 <check_swap+0x55a>
         check_ptep[i]=0;
c010725c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010725f:	c7 04 85 dc c0 12 c0 	movl   $0x0,-0x3fed3f24(,%eax,4)
c0107266:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010726a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010726d:	40                   	inc    %eax
c010726e:	c1 e0 0c             	shl    $0xc,%eax
c0107271:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107278:	00 
c0107279:	89 44 24 04          	mov    %eax,0x4(%esp)
c010727d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107280:	89 04 24             	mov    %eax,(%esp)
c0107283:	e8 cf e4 ff ff       	call   c0105757 <get_pte>
c0107288:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010728b:	89 04 95 dc c0 12 c0 	mov    %eax,-0x3fed3f24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0107292:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107295:	8b 04 85 dc c0 12 c0 	mov    -0x3fed3f24(,%eax,4),%eax
c010729c:	85 c0                	test   %eax,%eax
c010729e:	75 24                	jne    c01072c4 <check_swap+0x4da>
c01072a0:	c7 44 24 0c c8 b8 10 	movl   $0xc010b8c8,0xc(%esp)
c01072a7:	c0 
c01072a8:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c01072af:	c0 
c01072b0:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01072b7:	00 
c01072b8:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c01072bf:	e8 52 9a ff ff       	call   c0100d16 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01072c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072c7:	8b 04 85 dc c0 12 c0 	mov    -0x3fed3f24(,%eax,4),%eax
c01072ce:	8b 00                	mov    (%eax),%eax
c01072d0:	89 04 24             	mov    %eax,(%esp)
c01072d3:	e8 97 f5 ff ff       	call   c010686f <pte2page>
c01072d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01072db:	8b 14 95 cc c0 12 c0 	mov    -0x3fed3f34(,%edx,4),%edx
c01072e2:	39 d0                	cmp    %edx,%eax
c01072e4:	74 24                	je     c010730a <check_swap+0x520>
c01072e6:	c7 44 24 0c e0 b8 10 	movl   $0xc010b8e0,0xc(%esp)
c01072ed:	c0 
c01072ee:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c01072f5:	c0 
c01072f6:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01072fd:	00 
c01072fe:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0107305:	e8 0c 9a ff ff       	call   c0100d16 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010730a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010730d:	8b 04 85 dc c0 12 c0 	mov    -0x3fed3f24(,%eax,4),%eax
c0107314:	8b 00                	mov    (%eax),%eax
c0107316:	83 e0 01             	and    $0x1,%eax
c0107319:	85 c0                	test   %eax,%eax
c010731b:	75 24                	jne    c0107341 <check_swap+0x557>
c010731d:	c7 44 24 0c 08 b9 10 	movl   $0xc010b908,0xc(%esp)
c0107324:	c0 
c0107325:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c010732c:	c0 
c010732d:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0107334:	00 
c0107335:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c010733c:	e8 d5 99 ff ff       	call   c0100d16 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107341:	ff 45 ec             	incl   -0x14(%ebp)
c0107344:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107348:	0f 8e 0e ff ff ff    	jle    c010725c <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c010734e:	c7 04 24 24 b9 10 c0 	movl   $0xc010b924,(%esp)
c0107355:	e8 13 90 ff ff       	call   c010036d <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c010735a:	e8 71 fa ff ff       	call   c0106dd0 <check_content_access>
c010735f:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0107362:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107366:	74 24                	je     c010738c <check_swap+0x5a2>
c0107368:	c7 44 24 0c 4a b9 10 	movl   $0xc010b94a,0xc(%esp)
c010736f:	c0 
c0107370:	c7 44 24 08 32 b6 10 	movl   $0xc010b632,0x8(%esp)
c0107377:	c0 
c0107378:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c010737f:	00 
c0107380:	c7 04 24 cc b5 10 c0 	movl   $0xc010b5cc,(%esp)
c0107387:	e8 8a 99 ff ff       	call   c0100d16 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010738c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107393:	eb 1d                	jmp    c01073b2 <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c0107395:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107398:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c010739f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01073a6:	00 
c01073a7:	89 04 24             	mov    %eax,(%esp)
c01073aa:	e8 5a dd ff ff       	call   c0105109 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01073af:	ff 45 ec             	incl   -0x14(%ebp)
c01073b2:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01073b6:	7e dd                	jle    c0107395 <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c01073b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073bb:	89 04 24             	mov    %eax,(%esp)
c01073be:	e8 85 09 00 00       	call   c0107d48 <mm_destroy>
         
     nr_free = nr_free_store;
c01073c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01073c6:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
     free_list = free_list_store;
c01073cb:	8b 45 98             	mov    -0x68(%ebp),%eax
c01073ce:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01073d1:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
c01073d6:	89 15 88 bf 12 c0    	mov    %edx,0xc012bf88

     
     le = &free_list;
c01073dc:	c7 45 e8 84 bf 12 c0 	movl   $0xc012bf84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01073e3:	eb 1c                	jmp    c0107401 <check_swap+0x617>
         struct Page *p = le2page(le, page_link);
c01073e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01073e8:	83 e8 0c             	sub    $0xc,%eax
c01073eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c01073ee:	ff 4d f4             	decl   -0xc(%ebp)
c01073f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01073f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01073f7:	8b 48 08             	mov    0x8(%eax),%ecx
c01073fa:	89 d0                	mov    %edx,%eax
c01073fc:	29 c8                	sub    %ecx,%eax
c01073fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107401:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107404:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0107407:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010740a:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c010740d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107410:	81 7d e8 84 bf 12 c0 	cmpl   $0xc012bf84,-0x18(%ebp)
c0107417:	75 cc                	jne    c01073e5 <check_swap+0x5fb>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107419:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010741c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107420:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107423:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107427:	c7 04 24 51 b9 10 c0 	movl   $0xc010b951,(%esp)
c010742e:	e8 3a 8f ff ff       	call   c010036d <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107433:	c7 04 24 6b b9 10 c0 	movl   $0xc010b96b,(%esp)
c010743a:	e8 2e 8f ff ff       	call   c010036d <cprintf>
}
c010743f:	90                   	nop
c0107440:	89 ec                	mov    %ebp,%esp
c0107442:	5d                   	pop    %ebp
c0107443:	c3                   	ret    

c0107444 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107444:	55                   	push   %ebp
c0107445:	89 e5                	mov    %esp,%ebp
c0107447:	83 ec 10             	sub    $0x10,%esp
c010744a:	c7 45 fc 04 c1 12 c0 	movl   $0xc012c104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107451:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107454:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107457:	89 50 04             	mov    %edx,0x4(%eax)
c010745a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010745d:	8b 50 04             	mov    0x4(%eax),%edx
c0107460:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107463:	89 10                	mov    %edx,(%eax)
}
c0107465:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107466:	8b 45 08             	mov    0x8(%ebp),%eax
c0107469:	c7 40 14 04 c1 12 c0 	movl   $0xc012c104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107470:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107475:	89 ec                	mov    %ebp,%esp
c0107477:	5d                   	pop    %ebp
c0107478:	c3                   	ret    

c0107479 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107479:	55                   	push   %ebp
c010747a:	89 e5                	mov    %esp,%ebp
c010747c:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010747f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107482:	8b 40 14             	mov    0x14(%eax),%eax
c0107485:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107488:	8b 45 10             	mov    0x10(%ebp),%eax
c010748b:	83 c0 14             	add    $0x14,%eax
c010748e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107491:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107495:	74 06                	je     c010749d <_fifo_map_swappable+0x24>
c0107497:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010749b:	75 24                	jne    c01074c1 <_fifo_map_swappable+0x48>
c010749d:	c7 44 24 0c 84 b9 10 	movl   $0xc010b984,0xc(%esp)
c01074a4:	c0 
c01074a5:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01074ac:	c0 
c01074ad:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c01074b4:	00 
c01074b5:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01074bc:	e8 55 98 ff ff       	call   c0100d16 <__panic>
c01074c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01074c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01074cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01074d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01074d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01074d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c01074d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074dc:	8b 40 04             	mov    0x4(%eax),%eax
c01074df:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01074e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01074e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01074e8:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01074eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c01074ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01074f4:	89 10                	mov    %edx,(%eax)
c01074f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074f9:	8b 10                	mov    (%eax),%edx
c01074fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01074fe:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107501:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107504:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107507:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010750a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010750d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107510:	89 10                	mov    %edx,(%eax)
}
c0107512:	90                   	nop
}
c0107513:	90                   	nop
}
c0107514:	90                   	nop
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.

    list_add(head,entry);
    
    return 0;
c0107515:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010751a:	89 ec                	mov    %ebp,%esp
c010751c:	5d                   	pop    %ebp
c010751d:	c3                   	ret    

c010751e <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c010751e:	55                   	push   %ebp
c010751f:	89 e5                	mov    %esp,%ebp
c0107521:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107524:	8b 45 08             	mov    0x8(%ebp),%eax
c0107527:	8b 40 14             	mov    0x14(%eax),%eax
c010752a:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c010752d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107531:	75 24                	jne    c0107557 <_fifo_swap_out_victim+0x39>
c0107533:	c7 44 24 0c cb b9 10 	movl   $0xc010b9cb,0xc(%esp)
c010753a:	c0 
c010753b:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c0107542:	c0 
c0107543:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
c010754a:	00 
c010754b:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c0107552:	e8 bf 97 ff ff       	call   c0100d16 <__panic>
     assert(in_tick==0);
c0107557:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010755b:	74 24                	je     c0107581 <_fifo_swap_out_victim+0x63>
c010755d:	c7 44 24 0c d8 b9 10 	movl   $0xc010b9d8,0xc(%esp)
c0107564:	c0 
c0107565:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c010756c:	c0 
c010756d:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
c0107574:	00 
c0107575:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c010757c:	e8 95 97 ff ff       	call   c0100d16 <__panic>
c0107581:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107584:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->prev;
c0107587:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010758a:	8b 00                	mov    (%eax),%eax
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
    
     list_entry_t *le=list_prev(head);
c010758c:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c010758f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107592:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107595:	75 24                	jne    c01075bb <_fifo_swap_out_victim+0x9d>
c0107597:	c7 44 24 0c e3 b9 10 	movl   $0xc010b9e3,0xc(%esp)
c010759e:	c0 
c010759f:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01075a6:	c0 
c01075a7:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c01075ae:	00 
c01075af:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01075b6:	e8 5b 97 ff ff       	call   c0100d16 <__panic>
     struct Page *page=le2page(le,pra_page_link);
c01075bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075be:	83 e8 14             	sub    $0x14,%eax
c01075c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01075c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01075ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01075cd:	8b 40 04             	mov    0x4(%eax),%eax
c01075d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01075d3:	8b 12                	mov    (%edx),%edx
c01075d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01075d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c01075db:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01075de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075e1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01075e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01075e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01075ea:	89 10                	mov    %edx,(%eax)
}
c01075ec:	90                   	nop
}
c01075ed:	90                   	nop

     list_del(le);

    assert(page !=NULL); 
c01075ee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01075f2:	75 24                	jne    c0107618 <_fifo_swap_out_victim+0xfa>
c01075f4:	c7 44 24 0c ec b9 10 	movl   $0xc010b9ec,0xc(%esp)
c01075fb:	c0 
c01075fc:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c0107603:	c0 
c0107604:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c010760b:	00 
c010760c:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c0107613:	e8 fe 96 ff ff       	call   c0100d16 <__panic>

    *ptr_page = page;
c0107618:	8b 45 0c             	mov    0xc(%ebp),%eax
c010761b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010761e:	89 10                	mov    %edx,(%eax)
     struct Page *p = le2page(le, pra_page_link);
     list_del(le);
     assert(p !=NULL);
     *ptr_page = p;*/
     
     return 0;
c0107620:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107625:	89 ec                	mov    %ebp,%esp
c0107627:	5d                   	pop    %ebp
c0107628:	c3                   	ret    

c0107629 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107629:	55                   	push   %ebp
c010762a:	89 e5                	mov    %esp,%ebp
c010762c:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c010762f:	c7 04 24 f8 b9 10 c0 	movl   $0xc010b9f8,(%esp)
c0107636:	e8 32 8d ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010763b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107640:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107643:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107648:	83 f8 04             	cmp    $0x4,%eax
c010764b:	74 24                	je     c0107671 <_fifo_check_swap+0x48>
c010764d:	c7 44 24 0c 1e ba 10 	movl   $0xc010ba1e,0xc(%esp)
c0107654:	c0 
c0107655:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c010765c:	c0 
c010765d:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0107664:	00 
c0107665:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c010766c:	e8 a5 96 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107671:	c7 04 24 30 ba 10 c0 	movl   $0xc010ba30,(%esp)
c0107678:	e8 f0 8c ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010767d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107682:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107685:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010768a:	83 f8 04             	cmp    $0x4,%eax
c010768d:	74 24                	je     c01076b3 <_fifo_check_swap+0x8a>
c010768f:	c7 44 24 0c 1e ba 10 	movl   $0xc010ba1e,0xc(%esp)
c0107696:	c0 
c0107697:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c010769e:	c0 
c010769f:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01076a6:	00 
c01076a7:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01076ae:	e8 63 96 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01076b3:	c7 04 24 58 ba 10 c0 	movl   $0xc010ba58,(%esp)
c01076ba:	e8 ae 8c ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01076bf:	b8 00 40 00 00       	mov    $0x4000,%eax
c01076c4:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c01076c7:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01076cc:	83 f8 04             	cmp    $0x4,%eax
c01076cf:	74 24                	je     c01076f5 <_fifo_check_swap+0xcc>
c01076d1:	c7 44 24 0c 1e ba 10 	movl   $0xc010ba1e,0xc(%esp)
c01076d8:	c0 
c01076d9:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01076e0:	c0 
c01076e1:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01076e8:	00 
c01076e9:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01076f0:	e8 21 96 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01076f5:	c7 04 24 80 ba 10 c0 	movl   $0xc010ba80,(%esp)
c01076fc:	e8 6c 8c ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107701:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107706:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107709:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010770e:	83 f8 04             	cmp    $0x4,%eax
c0107711:	74 24                	je     c0107737 <_fifo_check_swap+0x10e>
c0107713:	c7 44 24 0c 1e ba 10 	movl   $0xc010ba1e,0xc(%esp)
c010771a:	c0 
c010771b:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c0107722:	c0 
c0107723:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010772a:	00 
c010772b:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c0107732:	e8 df 95 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107737:	c7 04 24 a8 ba 10 c0 	movl   $0xc010baa8,(%esp)
c010773e:	e8 2a 8c ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107743:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107748:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c010774b:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107750:	83 f8 05             	cmp    $0x5,%eax
c0107753:	74 24                	je     c0107779 <_fifo_check_swap+0x150>
c0107755:	c7 44 24 0c ce ba 10 	movl   $0xc010bace,0xc(%esp)
c010775c:	c0 
c010775d:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c0107764:	c0 
c0107765:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c010776c:	00 
c010776d:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c0107774:	e8 9d 95 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107779:	c7 04 24 80 ba 10 c0 	movl   $0xc010ba80,(%esp)
c0107780:	e8 e8 8b ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107785:	b8 00 20 00 00       	mov    $0x2000,%eax
c010778a:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c010778d:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107792:	83 f8 05             	cmp    $0x5,%eax
c0107795:	74 24                	je     c01077bb <_fifo_check_swap+0x192>
c0107797:	c7 44 24 0c ce ba 10 	movl   $0xc010bace,0xc(%esp)
c010779e:	c0 
c010779f:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01077a6:	c0 
c01077a7:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c01077ae:	00 
c01077af:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01077b6:	e8 5b 95 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01077bb:	c7 04 24 30 ba 10 c0 	movl   $0xc010ba30,(%esp)
c01077c2:	e8 a6 8b ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01077c7:	b8 00 10 00 00       	mov    $0x1000,%eax
c01077cc:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c01077cf:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01077d4:	83 f8 06             	cmp    $0x6,%eax
c01077d7:	74 24                	je     c01077fd <_fifo_check_swap+0x1d4>
c01077d9:	c7 44 24 0c dd ba 10 	movl   $0xc010badd,0xc(%esp)
c01077e0:	c0 
c01077e1:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01077e8:	c0 
c01077e9:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c01077f0:	00 
c01077f1:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01077f8:	e8 19 95 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01077fd:	c7 04 24 80 ba 10 c0 	movl   $0xc010ba80,(%esp)
c0107804:	e8 64 8b ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107809:	b8 00 20 00 00       	mov    $0x2000,%eax
c010780e:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107811:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107816:	83 f8 07             	cmp    $0x7,%eax
c0107819:	74 24                	je     c010783f <_fifo_check_swap+0x216>
c010781b:	c7 44 24 0c ec ba 10 	movl   $0xc010baec,0xc(%esp)
c0107822:	c0 
c0107823:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c010782a:	c0 
c010782b:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c0107832:	00 
c0107833:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c010783a:	e8 d7 94 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c010783f:	c7 04 24 f8 b9 10 c0 	movl   $0xc010b9f8,(%esp)
c0107846:	e8 22 8b ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010784b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107850:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107853:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107858:	83 f8 08             	cmp    $0x8,%eax
c010785b:	74 24                	je     c0107881 <_fifo_check_swap+0x258>
c010785d:	c7 44 24 0c fb ba 10 	movl   $0xc010bafb,0xc(%esp)
c0107864:	c0 
c0107865:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c010786c:	c0 
c010786d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0107874:	00 
c0107875:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c010787c:	e8 95 94 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107881:	c7 04 24 58 ba 10 c0 	movl   $0xc010ba58,(%esp)
c0107888:	e8 e0 8a ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010788d:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107892:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107895:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010789a:	83 f8 09             	cmp    $0x9,%eax
c010789d:	74 24                	je     c01078c3 <_fifo_check_swap+0x29a>
c010789f:	c7 44 24 0c 0a bb 10 	movl   $0xc010bb0a,0xc(%esp)
c01078a6:	c0 
c01078a7:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01078ae:	c0 
c01078af:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c01078b6:	00 
c01078b7:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c01078be:	e8 53 94 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01078c3:	c7 04 24 a8 ba 10 c0 	movl   $0xc010baa8,(%esp)
c01078ca:	e8 9e 8a ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01078cf:	b8 00 50 00 00       	mov    $0x5000,%eax
c01078d4:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01078d7:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01078dc:	83 f8 0a             	cmp    $0xa,%eax
c01078df:	74 24                	je     c0107905 <_fifo_check_swap+0x2dc>
c01078e1:	c7 44 24 0c 19 bb 10 	movl   $0xc010bb19,0xc(%esp)
c01078e8:	c0 
c01078e9:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c01078f0:	c0 
c01078f1:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
c01078f8:	00 
c01078f9:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c0107900:	e8 11 94 ff ff       	call   c0100d16 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107905:	c7 04 24 30 ba 10 c0 	movl   $0xc010ba30,(%esp)
c010790c:	e8 5c 8a ff ff       	call   c010036d <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107911:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107916:	0f b6 00             	movzbl (%eax),%eax
c0107919:	3c 0a                	cmp    $0xa,%al
c010791b:	74 24                	je     c0107941 <_fifo_check_swap+0x318>
c010791d:	c7 44 24 0c 2c bb 10 	movl   $0xc010bb2c,0xc(%esp)
c0107924:	c0 
c0107925:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c010792c:	c0 
c010792d:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0107934:	00 
c0107935:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c010793c:	e8 d5 93 ff ff       	call   c0100d16 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107941:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107946:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107949:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010794e:	83 f8 0b             	cmp    $0xb,%eax
c0107951:	74 24                	je     c0107977 <_fifo_check_swap+0x34e>
c0107953:	c7 44 24 0c 4d bb 10 	movl   $0xc010bb4d,0xc(%esp)
c010795a:	c0 
c010795b:	c7 44 24 08 a2 b9 10 	movl   $0xc010b9a2,0x8(%esp)
c0107962:	c0 
c0107963:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c010796a:	00 
c010796b:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c0107972:	e8 9f 93 ff ff       	call   c0100d16 <__panic>
    return 0;
c0107977:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010797c:	89 ec                	mov    %ebp,%esp
c010797e:	5d                   	pop    %ebp
c010797f:	c3                   	ret    

c0107980 <_fifo_init>:


static int
_fifo_init(void)
{
c0107980:	55                   	push   %ebp
c0107981:	89 e5                	mov    %esp,%ebp
    return 0;
c0107983:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107988:	5d                   	pop    %ebp
c0107989:	c3                   	ret    

c010798a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010798a:	55                   	push   %ebp
c010798b:	89 e5                	mov    %esp,%ebp
    return 0;
c010798d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107992:	5d                   	pop    %ebp
c0107993:	c3                   	ret    

c0107994 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107994:	55                   	push   %ebp
c0107995:	89 e5                	mov    %esp,%ebp
c0107997:	b8 00 00 00 00       	mov    $0x0,%eax
c010799c:	5d                   	pop    %ebp
c010799d:	c3                   	ret    

c010799e <pa2page>:
pa2page(uintptr_t pa) {
c010799e:	55                   	push   %ebp
c010799f:	89 e5                	mov    %esp,%ebp
c01079a1:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01079a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a7:	c1 e8 0c             	shr    $0xc,%eax
c01079aa:	89 c2                	mov    %eax,%edx
c01079ac:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01079b1:	39 c2                	cmp    %eax,%edx
c01079b3:	72 1c                	jb     c01079d1 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01079b5:	c7 44 24 08 70 bb 10 	movl   $0xc010bb70,0x8(%esp)
c01079bc:	c0 
c01079bd:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01079c4:	00 
c01079c5:	c7 04 24 8f bb 10 c0 	movl   $0xc010bb8f,(%esp)
c01079cc:	e8 45 93 ff ff       	call   c0100d16 <__panic>
    return &pages[PPN(pa)];
c01079d1:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01079d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01079da:	c1 e8 0c             	shr    $0xc,%eax
c01079dd:	c1 e0 05             	shl    $0x5,%eax
c01079e0:	01 d0                	add    %edx,%eax
}
c01079e2:	89 ec                	mov    %ebp,%esp
c01079e4:	5d                   	pop    %ebp
c01079e5:	c3                   	ret    

c01079e6 <pde2page>:
pde2page(pde_t pde) {
c01079e6:	55                   	push   %ebp
c01079e7:	89 e5                	mov    %esp,%ebp
c01079e9:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01079ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01079ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01079f4:	89 04 24             	mov    %eax,(%esp)
c01079f7:	e8 a2 ff ff ff       	call   c010799e <pa2page>
}
c01079fc:	89 ec                	mov    %ebp,%esp
c01079fe:	5d                   	pop    %ebp
c01079ff:	c3                   	ret    

c0107a00 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107a00:	55                   	push   %ebp
c0107a01:	89 e5                	mov    %esp,%ebp
c0107a03:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107a06:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107a0d:	e8 f9 d1 ff ff       	call   c0104c0b <kmalloc>
c0107a12:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107a15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a19:	74 59                	je     c0107a74 <mm_create+0x74>
        list_init(&(mm->mmap_list));
c0107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0107a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a24:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107a27:	89 50 04             	mov    %edx,0x4(%eax)
c0107a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a2d:	8b 50 04             	mov    0x4(%eax),%edx
c0107a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a33:	89 10                	mov    %edx,(%eax)
}
c0107a35:	90                   	nop
        mm->mmap_cache = NULL;
c0107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a39:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0107a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a43:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a4d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107a54:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c0107a59:	85 c0                	test   %eax,%eax
c0107a5b:	74 0d                	je     c0107a6a <mm_create+0x6a>
c0107a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a60:	89 04 24             	mov    %eax,(%esp)
c0107a63:	e8 d9 ee ff ff       	call   c0106941 <swap_init_mm>
c0107a68:	eb 0a                	jmp    c0107a74 <mm_create+0x74>
        else mm->sm_priv = NULL;
c0107a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a6d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0107a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107a77:	89 ec                	mov    %ebp,%esp
c0107a79:	5d                   	pop    %ebp
c0107a7a:	c3                   	ret    

c0107a7b <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107a7b:	55                   	push   %ebp
c0107a7c:	89 e5                	mov    %esp,%ebp
c0107a7e:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0107a81:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107a88:	e8 7e d1 ff ff       	call   c0104c0b <kmalloc>
c0107a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0107a90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a94:	74 1b                	je     c0107ab1 <vma_create+0x36>
        vma->vm_start = vm_start;
c0107a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a99:	8b 55 08             	mov    0x8(%ebp),%edx
c0107a9c:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107aa5:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aab:	8b 55 10             	mov    0x10(%ebp),%edx
c0107aae:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107ab4:	89 ec                	mov    %ebp,%esp
c0107ab6:	5d                   	pop    %ebp
c0107ab7:	c3                   	ret    

c0107ab8 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107ab8:	55                   	push   %ebp
c0107ab9:	89 e5                	mov    %esp,%ebp
c0107abb:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107abe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107ac5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107ac9:	0f 84 95 00 00 00    	je     c0107b64 <find_vma+0xac>
        vma = mm->mmap_cache;
c0107acf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ad2:	8b 40 08             	mov    0x8(%eax),%eax
c0107ad5:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107ad8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107adc:	74 16                	je     c0107af4 <find_vma+0x3c>
c0107ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ae1:	8b 40 04             	mov    0x4(%eax),%eax
c0107ae4:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107ae7:	72 0b                	jb     c0107af4 <find_vma+0x3c>
c0107ae9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107aec:	8b 40 08             	mov    0x8(%eax),%eax
c0107aef:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107af2:	72 61                	jb     c0107b55 <find_vma+0x9d>
                bool found = 0;
c0107af4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107afb:	8b 45 08             	mov    0x8(%ebp),%eax
c0107afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b04:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0107b07:	eb 28                	jmp    c0107b31 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b0c:	83 e8 10             	sub    $0x10,%eax
c0107b0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0107b12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b15:	8b 40 04             	mov    0x4(%eax),%eax
c0107b18:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107b1b:	72 14                	jb     c0107b31 <find_vma+0x79>
c0107b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b20:	8b 40 08             	mov    0x8(%eax),%eax
c0107b23:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107b26:	73 09                	jae    c0107b31 <find_vma+0x79>
                        found = 1;
c0107b28:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107b2f:	eb 17                	jmp    c0107b48 <find_vma+0x90>
c0107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b34:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0107b37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b3a:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0107b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b43:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107b46:	75 c1                	jne    c0107b09 <find_vma+0x51>
                    }
                }
                if (!found) {
c0107b48:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0107b4c:	75 07                	jne    c0107b55 <find_vma+0x9d>
                    vma = NULL;
c0107b4e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0107b55:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107b59:	74 09                	je     c0107b64 <find_vma+0xac>
            mm->mmap_cache = vma;
c0107b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b5e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107b61:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0107b64:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107b67:	89 ec                	mov    %ebp,%esp
c0107b69:	5d                   	pop    %ebp
c0107b6a:	c3                   	ret    

c0107b6b <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0107b6b:	55                   	push   %ebp
c0107b6c:	89 e5                	mov    %esp,%ebp
c0107b6e:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0107b71:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b74:	8b 50 04             	mov    0x4(%eax),%edx
c0107b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b7a:	8b 40 08             	mov    0x8(%eax),%eax
c0107b7d:	39 c2                	cmp    %eax,%edx
c0107b7f:	72 24                	jb     c0107ba5 <check_vma_overlap+0x3a>
c0107b81:	c7 44 24 0c 9d bb 10 	movl   $0xc010bb9d,0xc(%esp)
c0107b88:	c0 
c0107b89:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107b90:	c0 
c0107b91:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0107b98:	00 
c0107b99:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107ba0:	e8 71 91 ff ff       	call   c0100d16 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0107ba5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ba8:	8b 50 08             	mov    0x8(%eax),%edx
c0107bab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bae:	8b 40 04             	mov    0x4(%eax),%eax
c0107bb1:	39 c2                	cmp    %eax,%edx
c0107bb3:	76 24                	jbe    c0107bd9 <check_vma_overlap+0x6e>
c0107bb5:	c7 44 24 0c e0 bb 10 	movl   $0xc010bbe0,0xc(%esp)
c0107bbc:	c0 
c0107bbd:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107bc4:	c0 
c0107bc5:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107bcc:	00 
c0107bcd:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107bd4:	e8 3d 91 ff ff       	call   c0100d16 <__panic>
    assert(next->vm_start < next->vm_end);
c0107bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bdc:	8b 50 04             	mov    0x4(%eax),%edx
c0107bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107be2:	8b 40 08             	mov    0x8(%eax),%eax
c0107be5:	39 c2                	cmp    %eax,%edx
c0107be7:	72 24                	jb     c0107c0d <check_vma_overlap+0xa2>
c0107be9:	c7 44 24 0c ff bb 10 	movl   $0xc010bbff,0xc(%esp)
c0107bf0:	c0 
c0107bf1:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107bf8:	c0 
c0107bf9:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0107c00:	00 
c0107c01:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107c08:	e8 09 91 ff ff       	call   c0100d16 <__panic>
}
c0107c0d:	90                   	nop
c0107c0e:	89 ec                	mov    %ebp,%esp
c0107c10:	5d                   	pop    %ebp
c0107c11:	c3                   	ret    

c0107c12 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107c12:	55                   	push   %ebp
c0107c13:	89 e5                	mov    %esp,%ebp
c0107c15:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0107c18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c1b:	8b 50 04             	mov    0x4(%eax),%edx
c0107c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c21:	8b 40 08             	mov    0x8(%eax),%eax
c0107c24:	39 c2                	cmp    %eax,%edx
c0107c26:	72 24                	jb     c0107c4c <insert_vma_struct+0x3a>
c0107c28:	c7 44 24 0c 1d bc 10 	movl   $0xc010bc1d,0xc(%esp)
c0107c2f:	c0 
c0107c30:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107c37:	c0 
c0107c38:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107c3f:	00 
c0107c40:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107c47:	e8 ca 90 ff ff       	call   c0100d16 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0107c4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0107c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c55:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0107c58:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0107c5e:	eb 1f                	jmp    c0107c7f <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0107c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c63:	83 e8 10             	sub    $0x10,%eax
c0107c66:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0107c69:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c6c:	8b 50 04             	mov    0x4(%eax),%edx
c0107c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c72:	8b 40 04             	mov    0x4(%eax),%eax
c0107c75:	39 c2                	cmp    %eax,%edx
c0107c77:	77 1f                	ja     c0107c98 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c0107c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c82:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c88:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0107c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c91:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107c94:	75 ca                	jne    c0107c60 <insert_vma_struct+0x4e>
c0107c96:	eb 01                	jmp    c0107c99 <insert_vma_struct+0x87>
                break;
c0107c98:	90                   	nop
c0107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107c9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ca2:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0107ca5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107cae:	74 15                	je     c0107cc5 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cb3:	8d 50 f0             	lea    -0x10(%eax),%edx
c0107cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cbd:	89 14 24             	mov    %edx,(%esp)
c0107cc0:	e8 a6 fe ff ff       	call   c0107b6b <check_vma_overlap>
    }
    if (le_next != list) {
c0107cc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cc8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107ccb:	74 15                	je     c0107ce2 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cd0:	83 e8 10             	sub    $0x10,%eax
c0107cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107cda:	89 04 24             	mov    %eax,(%esp)
c0107cdd:	e8 89 fe ff ff       	call   c0107b6b <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ce5:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ce8:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0107cea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ced:	8d 50 10             	lea    0x10(%eax),%edx
c0107cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cf3:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107cf6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107cf9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107cfc:	8b 40 04             	mov    0x4(%eax),%eax
c0107cff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107d02:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107d05:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107d08:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0107d0b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0107d0e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107d11:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107d14:	89 10                	mov    %edx,(%eax)
c0107d16:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107d19:	8b 10                	mov    (%eax),%edx
c0107d1b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107d1e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107d21:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107d24:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107d27:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107d2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107d2d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107d30:	89 10                	mov    %edx,(%eax)
}
c0107d32:	90                   	nop
}
c0107d33:	90                   	nop

    mm->map_count ++;
c0107d34:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d37:	8b 40 10             	mov    0x10(%eax),%eax
c0107d3a:	8d 50 01             	lea    0x1(%eax),%edx
c0107d3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d40:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107d43:	90                   	nop
c0107d44:	89 ec                	mov    %ebp,%esp
c0107d46:	5d                   	pop    %ebp
c0107d47:	c3                   	ret    

c0107d48 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107d48:	55                   	push   %ebp
c0107d49:	89 e5                	mov    %esp,%ebp
c0107d4b:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0107d4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0107d54:	eb 38                	jmp    c0107d8e <mm_destroy+0x46>
c0107d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d5f:	8b 40 04             	mov    0x4(%eax),%eax
c0107d62:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d65:	8b 12                	mov    (%edx),%edx
c0107d67:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107d6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c0107d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d73:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d79:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107d7c:	89 10                	mov    %edx,(%eax)
}
c0107d7e:	90                   	nop
}
c0107d7f:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0107d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d83:	83 e8 10             	sub    $0x10,%eax
c0107d86:	89 04 24             	mov    %eax,(%esp)
c0107d89:	e8 9a ce ff ff       	call   c0104c28 <kfree>
c0107d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d91:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d97:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0107d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107da0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107da3:	75 b1                	jne    c0107d56 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
c0107da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107da8:	89 04 24             	mov    %eax,(%esp)
c0107dab:	e8 78 ce ff ff       	call   c0104c28 <kfree>
    mm=NULL;
c0107db0:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107db7:	90                   	nop
c0107db8:	89 ec                	mov    %ebp,%esp
c0107dba:	5d                   	pop    %ebp
c0107dbb:	c3                   	ret    

c0107dbc <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107dbc:	55                   	push   %ebp
c0107dbd:	89 e5                	mov    %esp,%ebp
c0107dbf:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107dc2:	e8 05 00 00 00       	call   c0107dcc <check_vmm>
}
c0107dc7:	90                   	nop
c0107dc8:	89 ec                	mov    %ebp,%esp
c0107dca:	5d                   	pop    %ebp
c0107dcb:	c3                   	ret    

c0107dcc <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107dcc:	55                   	push   %ebp
c0107dcd:	89 e5                	mov    %esp,%ebp
c0107dcf:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107dd2:	e8 67 d3 ff ff       	call   c010513e <nr_free_pages>
c0107dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0107dda:	e8 16 00 00 00       	call   c0107df5 <check_vma_struct>
    check_pgfault();
c0107ddf:	e8 a5 04 00 00       	call   c0108289 <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c0107de4:	c7 04 24 39 bc 10 c0 	movl   $0xc010bc39,(%esp)
c0107deb:	e8 7d 85 ff ff       	call   c010036d <cprintf>
}
c0107df0:	90                   	nop
c0107df1:	89 ec                	mov    %ebp,%esp
c0107df3:	5d                   	pop    %ebp
c0107df4:	c3                   	ret    

c0107df5 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107df5:	55                   	push   %ebp
c0107df6:	89 e5                	mov    %esp,%ebp
c0107df8:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107dfb:	e8 3e d3 ff ff       	call   c010513e <nr_free_pages>
c0107e00:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107e03:	e8 f8 fb ff ff       	call   c0107a00 <mm_create>
c0107e08:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107e0b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107e0f:	75 24                	jne    c0107e35 <check_vma_struct+0x40>
c0107e11:	c7 44 24 0c 51 bc 10 	movl   $0xc010bc51,0xc(%esp)
c0107e18:	c0 
c0107e19:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107e20:	c0 
c0107e21:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c0107e28:	00 
c0107e29:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107e30:	e8 e1 8e ff ff       	call   c0100d16 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107e35:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107e3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107e3f:	89 d0                	mov    %edx,%eax
c0107e41:	c1 e0 02             	shl    $0x2,%eax
c0107e44:	01 d0                	add    %edx,%eax
c0107e46:	01 c0                	add    %eax,%eax
c0107e48:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107e51:	eb 6f                	jmp    c0107ec2 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e56:	89 d0                	mov    %edx,%eax
c0107e58:	c1 e0 02             	shl    $0x2,%eax
c0107e5b:	01 d0                	add    %edx,%eax
c0107e5d:	83 c0 02             	add    $0x2,%eax
c0107e60:	89 c1                	mov    %eax,%ecx
c0107e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e65:	89 d0                	mov    %edx,%eax
c0107e67:	c1 e0 02             	shl    $0x2,%eax
c0107e6a:	01 d0                	add    %edx,%eax
c0107e6c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e73:	00 
c0107e74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107e78:	89 04 24             	mov    %eax,(%esp)
c0107e7b:	e8 fb fb ff ff       	call   c0107a7b <vma_create>
c0107e80:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0107e83:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107e87:	75 24                	jne    c0107ead <check_vma_struct+0xb8>
c0107e89:	c7 44 24 0c 5c bc 10 	movl   $0xc010bc5c,0xc(%esp)
c0107e90:	c0 
c0107e91:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107e98:	c0 
c0107e99:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0107ea0:	00 
c0107ea1:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107ea8:	e8 69 8e ff ff       	call   c0100d16 <__panic>
        insert_vma_struct(mm, vma);
c0107ead:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107eb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107eb7:	89 04 24             	mov    %eax,(%esp)
c0107eba:	e8 53 fd ff ff       	call   c0107c12 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0107ebf:	ff 4d f4             	decl   -0xc(%ebp)
c0107ec2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ec6:	7f 8b                	jg     c0107e53 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107ec8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ecb:	40                   	inc    %eax
c0107ecc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ecf:	eb 6f                	jmp    c0107f40 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107ed1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ed4:	89 d0                	mov    %edx,%eax
c0107ed6:	c1 e0 02             	shl    $0x2,%eax
c0107ed9:	01 d0                	add    %edx,%eax
c0107edb:	83 c0 02             	add    $0x2,%eax
c0107ede:	89 c1                	mov    %eax,%ecx
c0107ee0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ee3:	89 d0                	mov    %edx,%eax
c0107ee5:	c1 e0 02             	shl    $0x2,%eax
c0107ee8:	01 d0                	add    %edx,%eax
c0107eea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107ef1:	00 
c0107ef2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107ef6:	89 04 24             	mov    %eax,(%esp)
c0107ef9:	e8 7d fb ff ff       	call   c0107a7b <vma_create>
c0107efe:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0107f01:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107f05:	75 24                	jne    c0107f2b <check_vma_struct+0x136>
c0107f07:	c7 44 24 0c 5c bc 10 	movl   $0xc010bc5c,0xc(%esp)
c0107f0e:	c0 
c0107f0f:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107f16:	c0 
c0107f17:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0107f1e:	00 
c0107f1f:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107f26:	e8 eb 8d ff ff       	call   c0100d16 <__panic>
        insert_vma_struct(mm, vma);
c0107f2b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f35:	89 04 24             	mov    %eax,(%esp)
c0107f38:	e8 d5 fc ff ff       	call   c0107c12 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0107f3d:	ff 45 f4             	incl   -0xc(%ebp)
c0107f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f43:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107f46:	7e 89                	jle    c0107ed1 <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107f48:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f4b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107f4e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107f51:	8b 40 04             	mov    0x4(%eax),%eax
c0107f54:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107f57:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107f5e:	e9 96 00 00 00       	jmp    c0107ff9 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0107f63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f66:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107f69:	75 24                	jne    c0107f8f <check_vma_struct+0x19a>
c0107f6b:	c7 44 24 0c 68 bc 10 	movl   $0xc010bc68,0xc(%esp)
c0107f72:	c0 
c0107f73:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107f7a:	c0 
c0107f7b:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0107f82:	00 
c0107f83:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107f8a:	e8 87 8d ff ff       	call   c0100d16 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f92:	83 e8 10             	sub    $0x10,%eax
c0107f95:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107f98:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107f9b:	8b 48 04             	mov    0x4(%eax),%ecx
c0107f9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107fa1:	89 d0                	mov    %edx,%eax
c0107fa3:	c1 e0 02             	shl    $0x2,%eax
c0107fa6:	01 d0                	add    %edx,%eax
c0107fa8:	39 c1                	cmp    %eax,%ecx
c0107faa:	75 17                	jne    c0107fc3 <check_vma_struct+0x1ce>
c0107fac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107faf:	8b 48 08             	mov    0x8(%eax),%ecx
c0107fb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107fb5:	89 d0                	mov    %edx,%eax
c0107fb7:	c1 e0 02             	shl    $0x2,%eax
c0107fba:	01 d0                	add    %edx,%eax
c0107fbc:	83 c0 02             	add    $0x2,%eax
c0107fbf:	39 c1                	cmp    %eax,%ecx
c0107fc1:	74 24                	je     c0107fe7 <check_vma_struct+0x1f2>
c0107fc3:	c7 44 24 0c 80 bc 10 	movl   $0xc010bc80,0xc(%esp)
c0107fca:	c0 
c0107fcb:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0107fd2:	c0 
c0107fd3:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0107fda:	00 
c0107fdb:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0107fe2:	e8 2f 8d ff ff       	call   c0100d16 <__panic>
c0107fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107fea:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107fed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107ff0:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107ff3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0107ff6:	ff 45 f4             	incl   -0xc(%ebp)
c0107ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ffc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107fff:	0f 8e 5e ff ff ff    	jle    c0107f63 <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108005:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c010800c:	e9 cb 01 00 00       	jmp    c01081dc <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108011:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108014:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108018:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010801b:	89 04 24             	mov    %eax,(%esp)
c010801e:	e8 95 fa ff ff       	call   c0107ab8 <find_vma>
c0108023:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0108026:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010802a:	75 24                	jne    c0108050 <check_vma_struct+0x25b>
c010802c:	c7 44 24 0c b5 bc 10 	movl   $0xc010bcb5,0xc(%esp)
c0108033:	c0 
c0108034:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c010803b:	c0 
c010803c:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0108043:	00 
c0108044:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c010804b:	e8 c6 8c ff ff       	call   c0100d16 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0108050:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108053:	40                   	inc    %eax
c0108054:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108058:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010805b:	89 04 24             	mov    %eax,(%esp)
c010805e:	e8 55 fa ff ff       	call   c0107ab8 <find_vma>
c0108063:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0108066:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010806a:	75 24                	jne    c0108090 <check_vma_struct+0x29b>
c010806c:	c7 44 24 0c c2 bc 10 	movl   $0xc010bcc2,0xc(%esp)
c0108073:	c0 
c0108074:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c010807b:	c0 
c010807c:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0108083:	00 
c0108084:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c010808b:	e8 86 8c ff ff       	call   c0100d16 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0108090:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108093:	83 c0 02             	add    $0x2,%eax
c0108096:	89 44 24 04          	mov    %eax,0x4(%esp)
c010809a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010809d:	89 04 24             	mov    %eax,(%esp)
c01080a0:	e8 13 fa ff ff       	call   c0107ab8 <find_vma>
c01080a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c01080a8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01080ac:	74 24                	je     c01080d2 <check_vma_struct+0x2dd>
c01080ae:	c7 44 24 0c cf bc 10 	movl   $0xc010bccf,0xc(%esp)
c01080b5:	c0 
c01080b6:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c01080bd:	c0 
c01080be:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01080c5:	00 
c01080c6:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c01080cd:	e8 44 8c ff ff       	call   c0100d16 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080d5:	83 c0 03             	add    $0x3,%eax
c01080d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080df:	89 04 24             	mov    %eax,(%esp)
c01080e2:	e8 d1 f9 ff ff       	call   c0107ab8 <find_vma>
c01080e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c01080ea:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01080ee:	74 24                	je     c0108114 <check_vma_struct+0x31f>
c01080f0:	c7 44 24 0c dc bc 10 	movl   $0xc010bcdc,0xc(%esp)
c01080f7:	c0 
c01080f8:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c01080ff:	c0 
c0108100:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0108107:	00 
c0108108:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c010810f:	e8 02 8c ff ff       	call   c0100d16 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0108114:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108117:	83 c0 04             	add    $0x4,%eax
c010811a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010811e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108121:	89 04 24             	mov    %eax,(%esp)
c0108124:	e8 8f f9 ff ff       	call   c0107ab8 <find_vma>
c0108129:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c010812c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108130:	74 24                	je     c0108156 <check_vma_struct+0x361>
c0108132:	c7 44 24 0c e9 bc 10 	movl   $0xc010bce9,0xc(%esp)
c0108139:	c0 
c010813a:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0108141:	c0 
c0108142:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0108149:	00 
c010814a:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0108151:	e8 c0 8b ff ff       	call   c0100d16 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108156:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108159:	8b 50 04             	mov    0x4(%eax),%edx
c010815c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010815f:	39 c2                	cmp    %eax,%edx
c0108161:	75 10                	jne    c0108173 <check_vma_struct+0x37e>
c0108163:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108166:	8b 40 08             	mov    0x8(%eax),%eax
c0108169:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010816c:	83 c2 02             	add    $0x2,%edx
c010816f:	39 d0                	cmp    %edx,%eax
c0108171:	74 24                	je     c0108197 <check_vma_struct+0x3a2>
c0108173:	c7 44 24 0c f8 bc 10 	movl   $0xc010bcf8,0xc(%esp)
c010817a:	c0 
c010817b:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0108182:	c0 
c0108183:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010818a:	00 
c010818b:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0108192:	e8 7f 8b ff ff       	call   c0100d16 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108197:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010819a:	8b 50 04             	mov    0x4(%eax),%edx
c010819d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081a0:	39 c2                	cmp    %eax,%edx
c01081a2:	75 10                	jne    c01081b4 <check_vma_struct+0x3bf>
c01081a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01081a7:	8b 40 08             	mov    0x8(%eax),%eax
c01081aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01081ad:	83 c2 02             	add    $0x2,%edx
c01081b0:	39 d0                	cmp    %edx,%eax
c01081b2:	74 24                	je     c01081d8 <check_vma_struct+0x3e3>
c01081b4:	c7 44 24 0c 28 bd 10 	movl   $0xc010bd28,0xc(%esp)
c01081bb:	c0 
c01081bc:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c01081c3:	c0 
c01081c4:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c01081cb:	00 
c01081cc:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c01081d3:	e8 3e 8b ff ff       	call   c0100d16 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c01081d8:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01081dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01081df:	89 d0                	mov    %edx,%eax
c01081e1:	c1 e0 02             	shl    $0x2,%eax
c01081e4:	01 d0                	add    %edx,%eax
c01081e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01081e9:	0f 8e 22 fe ff ff    	jle    c0108011 <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c01081ef:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c01081f6:	eb 6f                	jmp    c0108267 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c01081f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108202:	89 04 24             	mov    %eax,(%esp)
c0108205:	e8 ae f8 ff ff       	call   c0107ab8 <find_vma>
c010820a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c010820d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108211:	74 27                	je     c010823a <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0108213:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108216:	8b 50 08             	mov    0x8(%eax),%edx
c0108219:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010821c:	8b 40 04             	mov    0x4(%eax),%eax
c010821f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108223:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108227:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010822a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010822e:	c7 04 24 58 bd 10 c0 	movl   $0xc010bd58,(%esp)
c0108235:	e8 33 81 ff ff       	call   c010036d <cprintf>
        }
        assert(vma_below_5 == NULL);
c010823a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010823e:	74 24                	je     c0108264 <check_vma_struct+0x46f>
c0108240:	c7 44 24 0c 7d bd 10 	movl   $0xc010bd7d,0xc(%esp)
c0108247:	c0 
c0108248:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c010824f:	c0 
c0108250:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0108257:	00 
c0108258:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c010825f:	e8 b2 8a ff ff       	call   c0100d16 <__panic>
    for (i =4; i>=0; i--) {
c0108264:	ff 4d f4             	decl   -0xc(%ebp)
c0108267:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010826b:	79 8b                	jns    c01081f8 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c010826d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108270:	89 04 24             	mov    %eax,(%esp)
c0108273:	e8 d0 fa ff ff       	call   c0107d48 <mm_destroy>

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c0108278:	c7 04 24 94 bd 10 c0 	movl   $0xc010bd94,(%esp)
c010827f:	e8 e9 80 ff ff       	call   c010036d <cprintf>
}
c0108284:	90                   	nop
c0108285:	89 ec                	mov    %ebp,%esp
c0108287:	5d                   	pop    %ebp
c0108288:	c3                   	ret    

c0108289 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108289:	55                   	push   %ebp
c010828a:	89 e5                	mov    %esp,%ebp
c010828c:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010828f:	e8 aa ce ff ff       	call   c010513e <nr_free_pages>
c0108294:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108297:	e8 64 f7 ff ff       	call   c0107a00 <mm_create>
c010829c:	a3 0c c1 12 c0       	mov    %eax,0xc012c10c
    assert(check_mm_struct != NULL);
c01082a1:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01082a6:	85 c0                	test   %eax,%eax
c01082a8:	75 24                	jne    c01082ce <check_pgfault+0x45>
c01082aa:	c7 44 24 0c b3 bd 10 	movl   $0xc010bdb3,0xc(%esp)
c01082b1:	c0 
c01082b2:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c01082b9:	c0 
c01082ba:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c01082c1:	00 
c01082c2:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c01082c9:	e8 48 8a ff ff       	call   c0100d16 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01082ce:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01082d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c01082d6:	8b 15 00 8a 12 c0    	mov    0xc0128a00,%edx
c01082dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082df:	89 50 0c             	mov    %edx,0xc(%eax)
c01082e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01082e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01082eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082ee:	8b 00                	mov    (%eax),%eax
c01082f0:	85 c0                	test   %eax,%eax
c01082f2:	74 24                	je     c0108318 <check_pgfault+0x8f>
c01082f4:	c7 44 24 0c cb bd 10 	movl   $0xc010bdcb,0xc(%esp)
c01082fb:	c0 
c01082fc:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0108303:	c0 
c0108304:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c010830b:	00 
c010830c:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0108313:	e8 fe 89 ff ff       	call   c0100d16 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108318:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c010831f:	00 
c0108320:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108327:	00 
c0108328:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010832f:	e8 47 f7 ff ff       	call   c0107a7b <vma_create>
c0108334:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108337:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010833b:	75 24                	jne    c0108361 <check_pgfault+0xd8>
c010833d:	c7 44 24 0c 5c bc 10 	movl   $0xc010bc5c,0xc(%esp)
c0108344:	c0 
c0108345:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c010834c:	c0 
c010834d:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0108354:	00 
c0108355:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c010835c:	e8 b5 89 ff ff       	call   c0100d16 <__panic>

    insert_vma_struct(mm, vma);
c0108361:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108364:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108368:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010836b:	89 04 24             	mov    %eax,(%esp)
c010836e:	e8 9f f8 ff ff       	call   c0107c12 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108373:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010837a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010837d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108381:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108384:	89 04 24             	mov    %eax,(%esp)
c0108387:	e8 2c f7 ff ff       	call   c0107ab8 <find_vma>
c010838c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010838f:	74 24                	je     c01083b5 <check_pgfault+0x12c>
c0108391:	c7 44 24 0c d9 bd 10 	movl   $0xc010bdd9,0xc(%esp)
c0108398:	c0 
c0108399:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c01083a0:	c0 
c01083a1:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01083a8:	00 
c01083a9:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c01083b0:	e8 61 89 ff ff       	call   c0100d16 <__panic>

    int i, sum = 0;
c01083b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01083bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01083c3:	eb 16                	jmp    c01083db <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c01083c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083cb:	01 d0                	add    %edx,%eax
c01083cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083d0:	88 10                	mov    %dl,(%eax)
        sum += i;
c01083d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083d5:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01083d8:	ff 45 f4             	incl   -0xc(%ebp)
c01083db:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01083df:	7e e4                	jle    c01083c5 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c01083e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01083e8:	eb 14                	jmp    c01083fe <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c01083ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083f0:	01 d0                	add    %edx,%eax
c01083f2:	0f b6 00             	movzbl (%eax),%eax
c01083f5:	0f be c0             	movsbl %al,%eax
c01083f8:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01083fb:	ff 45 f4             	incl   -0xc(%ebp)
c01083fe:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108402:	7e e6                	jle    c01083ea <check_pgfault+0x161>
    }
    assert(sum == 0);
c0108404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108408:	74 24                	je     c010842e <check_pgfault+0x1a5>
c010840a:	c7 44 24 0c f3 bd 10 	movl   $0xc010bdf3,0xc(%esp)
c0108411:	c0 
c0108412:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c0108419:	c0 
c010841a:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0108421:	00 
c0108422:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c0108429:	e8 e8 88 ff ff       	call   c0100d16 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010842e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108431:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108434:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108437:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010843c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108443:	89 04 24             	mov    %eax,(%esp)
c0108446:	e8 06 d5 ff ff       	call   c0105951 <page_remove>
    free_page(pde2page(pgdir[0]));
c010844b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010844e:	8b 00                	mov    (%eax),%eax
c0108450:	89 04 24             	mov    %eax,(%esp)
c0108453:	e8 8e f5 ff ff       	call   c01079e6 <pde2page>
c0108458:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010845f:	00 
c0108460:	89 04 24             	mov    %eax,(%esp)
c0108463:	e8 a1 cc ff ff       	call   c0105109 <free_pages>
    pgdir[0] = 0;
c0108468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010846b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108471:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108474:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c010847b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010847e:	89 04 24             	mov    %eax,(%esp)
c0108481:	e8 c2 f8 ff ff       	call   c0107d48 <mm_destroy>
    check_mm_struct = NULL;
c0108486:	c7 05 0c c1 12 c0 00 	movl   $0x0,0xc012c10c
c010848d:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108490:	e8 a9 cc ff ff       	call   c010513e <nr_free_pages>
c0108495:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108498:	74 24                	je     c01084be <check_pgfault+0x235>
c010849a:	c7 44 24 0c fc bd 10 	movl   $0xc010bdfc,0xc(%esp)
c01084a1:	c0 
c01084a2:	c7 44 24 08 bb bb 10 	movl   $0xc010bbbb,0x8(%esp)
c01084a9:	c0 
c01084aa:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01084b1:	00 
c01084b2:	c7 04 24 d0 bb 10 c0 	movl   $0xc010bbd0,(%esp)
c01084b9:	e8 58 88 ff ff       	call   c0100d16 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01084be:	c7 04 24 23 be 10 c0 	movl   $0xc010be23,(%esp)
c01084c5:	e8 a3 7e ff ff       	call   c010036d <cprintf>
}
c01084ca:	90                   	nop
c01084cb:	89 ec                	mov    %ebp,%esp
c01084cd:	5d                   	pop    %ebp
c01084ce:	c3                   	ret    

c01084cf <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01084cf:	55                   	push   %ebp
c01084d0:	89 e5                	mov    %esp,%ebp
c01084d2:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c01084d5:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01084dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01084df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01084e6:	89 04 24             	mov    %eax,(%esp)
c01084e9:	e8 ca f5 ff ff       	call   c0107ab8 <find_vma>
c01084ee:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01084f1:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01084f6:	40                   	inc    %eax
c01084f7:	a3 10 c1 12 c0       	mov    %eax,0xc012c110
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01084fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108500:	74 0b                	je     c010850d <do_pgfault+0x3e>
c0108502:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108505:	8b 40 04             	mov    0x4(%eax),%eax
c0108508:	39 45 10             	cmp    %eax,0x10(%ebp)
c010850b:	73 18                	jae    c0108525 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c010850d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108510:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108514:	c7 04 24 40 be 10 c0 	movl   $0xc010be40,(%esp)
c010851b:	e8 4d 7e ff ff       	call   c010036d <cprintf>
        goto failed;
c0108520:	e9 ba 01 00 00       	jmp    c01086df <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c0108525:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108528:	83 e0 03             	and    $0x3,%eax
c010852b:	85 c0                	test   %eax,%eax
c010852d:	74 34                	je     c0108563 <do_pgfault+0x94>
c010852f:	83 f8 01             	cmp    $0x1,%eax
c0108532:	74 1e                	je     c0108552 <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0108534:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108537:	8b 40 0c             	mov    0xc(%eax),%eax
c010853a:	83 e0 02             	and    $0x2,%eax
c010853d:	85 c0                	test   %eax,%eax
c010853f:	75 40                	jne    c0108581 <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108541:	c7 04 24 70 be 10 c0 	movl   $0xc010be70,(%esp)
c0108548:	e8 20 7e ff ff       	call   c010036d <cprintf>
            goto failed;
c010854d:	e9 8d 01 00 00       	jmp    c01086df <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108552:	c7 04 24 d0 be 10 c0 	movl   $0xc010bed0,(%esp)
c0108559:	e8 0f 7e ff ff       	call   c010036d <cprintf>
        goto failed;
c010855e:	e9 7c 01 00 00       	jmp    c01086df <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108563:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108566:	8b 40 0c             	mov    0xc(%eax),%eax
c0108569:	83 e0 05             	and    $0x5,%eax
c010856c:	85 c0                	test   %eax,%eax
c010856e:	75 12                	jne    c0108582 <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108570:	c7 04 24 08 bf 10 c0 	movl   $0xc010bf08,(%esp)
c0108577:	e8 f1 7d ff ff       	call   c010036d <cprintf>
            goto failed;
c010857c:	e9 5e 01 00 00       	jmp    c01086df <do_pgfault+0x210>
        break;
c0108581:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108582:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108589:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010858c:	8b 40 0c             	mov    0xc(%eax),%eax
c010858f:	83 e0 02             	and    $0x2,%eax
c0108592:	85 c0                	test   %eax,%eax
c0108594:	74 04                	je     c010859a <do_pgfault+0xcb>
        perm |= PTE_W;
c0108596:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c010859a:	8b 45 10             	mov    0x10(%ebp),%eax
c010859d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01085a8:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01085ab:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01085b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c01085b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01085bc:	8b 40 0c             	mov    0xc(%eax),%eax
c01085bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01085c6:	00 
c01085c7:	8b 55 10             	mov    0x10(%ebp),%edx
c01085ca:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085ce:	89 04 24             	mov    %eax,(%esp)
c01085d1:	e8 81 d1 ff ff       	call   c0105757 <get_pte>
c01085d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01085d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01085dd:	75 11                	jne    c01085f0 <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c01085df:	c7 04 24 6b bf 10 c0 	movl   $0xc010bf6b,(%esp)
c01085e6:	e8 82 7d ff ff       	call   c010036d <cprintf>
        goto failed;
c01085eb:	e9 ef 00 00 00       	jmp    c01086df <do_pgfault+0x210>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c01085f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085f3:	8b 00                	mov    (%eax),%eax
c01085f5:	85 c0                	test   %eax,%eax
c01085f7:	75 35                	jne    c010862e <do_pgfault+0x15f>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01085f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01085fc:	8b 40 0c             	mov    0xc(%eax),%eax
c01085ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108602:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108606:	8b 55 10             	mov    0x10(%ebp),%edx
c0108609:	89 54 24 04          	mov    %edx,0x4(%esp)
c010860d:	89 04 24             	mov    %eax,(%esp)
c0108610:	e8 9d d4 ff ff       	call   c0105ab2 <pgdir_alloc_page>
c0108615:	85 c0                	test   %eax,%eax
c0108617:	0f 85 bb 00 00 00    	jne    c01086d8 <do_pgfault+0x209>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010861d:	c7 04 24 8c bf 10 c0 	movl   $0xc010bf8c,(%esp)
c0108624:	e8 44 7d ff ff       	call   c010036d <cprintf>
            goto failed;
c0108629:	e9 b1 00 00 00       	jmp    c01086df <do_pgfault+0x210>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c010862e:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c0108633:	85 c0                	test   %eax,%eax
c0108635:	0f 84 86 00 00 00    	je     c01086c1 <do_pgfault+0x1f2>
            struct Page *page=NULL;
c010863b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0108642:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0108645:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108649:	8b 45 10             	mov    0x10(%ebp),%eax
c010864c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108650:	8b 45 08             	mov    0x8(%ebp),%eax
c0108653:	89 04 24             	mov    %eax,(%esp)
c0108656:	e8 e2 e4 ff ff       	call   c0106b3d <swap_in>
c010865b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010865e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108662:	74 0e                	je     c0108672 <do_pgfault+0x1a3>
                cprintf("swap_in in do_pgfault failed\n");
c0108664:	c7 04 24 b3 bf 10 c0 	movl   $0xc010bfb3,(%esp)
c010866b:	e8 fd 7c ff ff       	call   c010036d <cprintf>
c0108670:	eb 6d                	jmp    c01086df <do_pgfault+0x210>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0108672:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108675:	8b 45 08             	mov    0x8(%ebp),%eax
c0108678:	8b 40 0c             	mov    0xc(%eax),%eax
c010867b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010867e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108682:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108685:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108689:	89 54 24 04          	mov    %edx,0x4(%esp)
c010868d:	89 04 24             	mov    %eax,(%esp)
c0108690:	e8 03 d3 ff ff       	call   c0105998 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0108695:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108698:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010869f:	00 
c01086a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01086a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ae:	89 04 24             	mov    %eax,(%esp)
c01086b1:	e8 bf e2 ff ff       	call   c0106975 <swap_map_swappable>
            page->pra_vaddr = addr;
c01086b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01086b9:	8b 55 10             	mov    0x10(%ebp),%edx
c01086bc:	89 50 1c             	mov    %edx,0x1c(%eax)
c01086bf:	eb 17                	jmp    c01086d8 <do_pgfault+0x209>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c01086c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01086c4:	8b 00                	mov    (%eax),%eax
c01086c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086ca:	c7 04 24 d4 bf 10 c0 	movl   $0xc010bfd4,(%esp)
c01086d1:	e8 97 7c ff ff       	call   c010036d <cprintf>
            goto failed;
c01086d6:	eb 07                	jmp    c01086df <do_pgfault+0x210>
        }
   }
   ret = 0;
c01086d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01086e2:	89 ec                	mov    %ebp,%esp
c01086e4:	5d                   	pop    %ebp
c01086e5:	c3                   	ret    

c01086e6 <page2ppn>:
page2ppn(struct Page *page) {
c01086e6:	55                   	push   %ebp
c01086e7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01086e9:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01086ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01086f2:	29 d0                	sub    %edx,%eax
c01086f4:	c1 f8 05             	sar    $0x5,%eax
}
c01086f7:	5d                   	pop    %ebp
c01086f8:	c3                   	ret    

c01086f9 <page2pa>:
page2pa(struct Page *page) {
c01086f9:	55                   	push   %ebp
c01086fa:	89 e5                	mov    %esp,%ebp
c01086fc:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01086ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0108702:	89 04 24             	mov    %eax,(%esp)
c0108705:	e8 dc ff ff ff       	call   c01086e6 <page2ppn>
c010870a:	c1 e0 0c             	shl    $0xc,%eax
}
c010870d:	89 ec                	mov    %ebp,%esp
c010870f:	5d                   	pop    %ebp
c0108710:	c3                   	ret    

c0108711 <page2kva>:
page2kva(struct Page *page) {
c0108711:	55                   	push   %ebp
c0108712:	89 e5                	mov    %esp,%ebp
c0108714:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108717:	8b 45 08             	mov    0x8(%ebp),%eax
c010871a:	89 04 24             	mov    %eax,(%esp)
c010871d:	e8 d7 ff ff ff       	call   c01086f9 <page2pa>
c0108722:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108728:	c1 e8 0c             	shr    $0xc,%eax
c010872b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010872e:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0108733:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108736:	72 23                	jb     c010875b <page2kva+0x4a>
c0108738:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010873b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010873f:	c7 44 24 08 fc bf 10 	movl   $0xc010bffc,0x8(%esp)
c0108746:	c0 
c0108747:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010874e:	00 
c010874f:	c7 04 24 1f c0 10 c0 	movl   $0xc010c01f,(%esp)
c0108756:	e8 bb 85 ff ff       	call   c0100d16 <__panic>
c010875b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010875e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108763:	89 ec                	mov    %ebp,%esp
c0108765:	5d                   	pop    %ebp
c0108766:	c3                   	ret    

c0108767 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108767:	55                   	push   %ebp
c0108768:	89 e5                	mov    %esp,%ebp
c010876a:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010876d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108774:	e8 4c 93 ff ff       	call   c0101ac5 <ide_device_valid>
c0108779:	85 c0                	test   %eax,%eax
c010877b:	75 1c                	jne    c0108799 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010877d:	c7 44 24 08 2d c0 10 	movl   $0xc010c02d,0x8(%esp)
c0108784:	c0 
c0108785:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010878c:	00 
c010878d:	c7 04 24 47 c0 10 c0 	movl   $0xc010c047,(%esp)
c0108794:	e8 7d 85 ff ff       	call   c0100d16 <__panic>
    }

    //总扇区数目除以一个页所需的扇区数目，得到页数
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0108799:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01087a0:	e8 60 93 ff ff       	call   c0101b05 <ide_device_size>
c01087a5:	c1 e8 03             	shr    $0x3,%eax
c01087a8:	a3 40 c0 12 c0       	mov    %eax,0xc012c040
}
c01087ad:	90                   	nop
c01087ae:	89 ec                	mov    %ebp,%esp
c01087b0:	5d                   	pop    %ebp
c01087b1:	c3                   	ret    

c01087b2 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01087b2:	55                   	push   %ebp
c01087b3:	89 e5                	mov    %esp,%ebp
c01087b5:	83 ec 28             	sub    $0x28,%esp

    //PTE前24位的索引值对应的是，将磁盘按页划分的索引值
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01087b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087bb:	89 04 24             	mov    %eax,(%esp)
c01087be:	e8 4e ff ff ff       	call   c0108711 <page2kva>
c01087c3:	8b 55 08             	mov    0x8(%ebp),%edx
c01087c6:	c1 ea 08             	shr    $0x8,%edx
c01087c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01087cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01087d0:	74 0b                	je     c01087dd <swapfs_read+0x2b>
c01087d2:	8b 15 40 c0 12 c0    	mov    0xc012c040,%edx
c01087d8:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01087db:	72 23                	jb     c0108800 <swapfs_read+0x4e>
c01087dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01087e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01087e4:	c7 44 24 08 58 c0 10 	movl   $0xc010c058,0x8(%esp)
c01087eb:	c0 
c01087ec:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01087f3:	00 
c01087f4:	c7 04 24 47 c0 10 c0 	movl   $0xc010c047,(%esp)
c01087fb:	e8 16 85 ff ff       	call   c0100d16 <__panic>
c0108800:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108803:	c1 e2 03             	shl    $0x3,%edx
c0108806:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010880d:	00 
c010880e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108812:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108816:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010881d:	e8 20 93 ff ff       	call   c0101b42 <ide_read_secs>
}
c0108822:	89 ec                	mov    %ebp,%esp
c0108824:	5d                   	pop    %ebp
c0108825:	c3                   	ret    

c0108826 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108826:	55                   	push   %ebp
c0108827:	89 e5                	mov    %esp,%ebp
c0108829:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010882c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010882f:	89 04 24             	mov    %eax,(%esp)
c0108832:	e8 da fe ff ff       	call   c0108711 <page2kva>
c0108837:	8b 55 08             	mov    0x8(%ebp),%edx
c010883a:	c1 ea 08             	shr    $0x8,%edx
c010883d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108840:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108844:	74 0b                	je     c0108851 <swapfs_write+0x2b>
c0108846:	8b 15 40 c0 12 c0    	mov    0xc012c040,%edx
c010884c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010884f:	72 23                	jb     c0108874 <swapfs_write+0x4e>
c0108851:	8b 45 08             	mov    0x8(%ebp),%eax
c0108854:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108858:	c7 44 24 08 58 c0 10 	movl   $0xc010c058,0x8(%esp)
c010885f:	c0 
c0108860:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
c0108867:	00 
c0108868:	c7 04 24 47 c0 10 c0 	movl   $0xc010c047,(%esp)
c010886f:	e8 a2 84 ff ff       	call   c0100d16 <__panic>
c0108874:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108877:	c1 e2 03             	shl    $0x3,%edx
c010887a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108881:	00 
c0108882:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108886:	89 54 24 04          	mov    %edx,0x4(%esp)
c010888a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108891:	e8 ed 94 ff ff       	call   c0101d83 <ide_write_secs>
}
c0108896:	89 ec                	mov    %ebp,%esp
c0108898:	5d                   	pop    %ebp
c0108899:	c3                   	ret    

c010889a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010889a:	52                   	push   %edx
    call *%ebx              # call fn
c010889b:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c010889d:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c010889e:	e8 60 08 00 00       	call   c0109103 <do_exit>

c01088a3 <__intr_save>:
__intr_save(void) {
c01088a3:	55                   	push   %ebp
c01088a4:	89 e5                	mov    %esp,%ebp
c01088a6:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01088a9:	9c                   	pushf  
c01088aa:	58                   	pop    %eax
c01088ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01088ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01088b1:	25 00 02 00 00       	and    $0x200,%eax
c01088b6:	85 c0                	test   %eax,%eax
c01088b8:	74 0c                	je     c01088c6 <__intr_save+0x23>
        intr_disable();
c01088ba:	e8 0d 97 ff ff       	call   c0101fcc <intr_disable>
        return 1;
c01088bf:	b8 01 00 00 00       	mov    $0x1,%eax
c01088c4:	eb 05                	jmp    c01088cb <__intr_save+0x28>
    return 0;
c01088c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01088cb:	89 ec                	mov    %ebp,%esp
c01088cd:	5d                   	pop    %ebp
c01088ce:	c3                   	ret    

c01088cf <__intr_restore>:
__intr_restore(bool flag) {
c01088cf:	55                   	push   %ebp
c01088d0:	89 e5                	mov    %esp,%ebp
c01088d2:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01088d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01088d9:	74 05                	je     c01088e0 <__intr_restore+0x11>
        intr_enable();
c01088db:	e8 e4 96 ff ff       	call   c0101fc4 <intr_enable>
}
c01088e0:	90                   	nop
c01088e1:	89 ec                	mov    %ebp,%esp
c01088e3:	5d                   	pop    %ebp
c01088e4:	c3                   	ret    

c01088e5 <page2ppn>:
page2ppn(struct Page *page) {
c01088e5:	55                   	push   %ebp
c01088e6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01088e8:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01088ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01088f1:	29 d0                	sub    %edx,%eax
c01088f3:	c1 f8 05             	sar    $0x5,%eax
}
c01088f6:	5d                   	pop    %ebp
c01088f7:	c3                   	ret    

c01088f8 <page2pa>:
page2pa(struct Page *page) {
c01088f8:	55                   	push   %ebp
c01088f9:	89 e5                	mov    %esp,%ebp
c01088fb:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01088fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108901:	89 04 24             	mov    %eax,(%esp)
c0108904:	e8 dc ff ff ff       	call   c01088e5 <page2ppn>
c0108909:	c1 e0 0c             	shl    $0xc,%eax
}
c010890c:	89 ec                	mov    %ebp,%esp
c010890e:	5d                   	pop    %ebp
c010890f:	c3                   	ret    

c0108910 <pa2page>:
pa2page(uintptr_t pa) {
c0108910:	55                   	push   %ebp
c0108911:	89 e5                	mov    %esp,%ebp
c0108913:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108916:	8b 45 08             	mov    0x8(%ebp),%eax
c0108919:	c1 e8 0c             	shr    $0xc,%eax
c010891c:	89 c2                	mov    %eax,%edx
c010891e:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0108923:	39 c2                	cmp    %eax,%edx
c0108925:	72 1c                	jb     c0108943 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108927:	c7 44 24 08 78 c0 10 	movl   $0xc010c078,0x8(%esp)
c010892e:	c0 
c010892f:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0108936:	00 
c0108937:	c7 04 24 97 c0 10 c0 	movl   $0xc010c097,(%esp)
c010893e:	e8 d3 83 ff ff       	call   c0100d16 <__panic>
    return &pages[PPN(pa)];
c0108943:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0108949:	8b 45 08             	mov    0x8(%ebp),%eax
c010894c:	c1 e8 0c             	shr    $0xc,%eax
c010894f:	c1 e0 05             	shl    $0x5,%eax
c0108952:	01 d0                	add    %edx,%eax
}
c0108954:	89 ec                	mov    %ebp,%esp
c0108956:	5d                   	pop    %ebp
c0108957:	c3                   	ret    

c0108958 <page2kva>:
page2kva(struct Page *page) {
c0108958:	55                   	push   %ebp
c0108959:	89 e5                	mov    %esp,%ebp
c010895b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010895e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108961:	89 04 24             	mov    %eax,(%esp)
c0108964:	e8 8f ff ff ff       	call   c01088f8 <page2pa>
c0108969:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010896c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010896f:	c1 e8 0c             	shr    $0xc,%eax
c0108972:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108975:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c010897a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010897d:	72 23                	jb     c01089a2 <page2kva+0x4a>
c010897f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108982:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108986:	c7 44 24 08 a8 c0 10 	movl   $0xc010c0a8,0x8(%esp)
c010898d:	c0 
c010898e:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0108995:	00 
c0108996:	c7 04 24 97 c0 10 c0 	movl   $0xc010c097,(%esp)
c010899d:	e8 74 83 ff ff       	call   c0100d16 <__panic>
c01089a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089a5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01089aa:	89 ec                	mov    %ebp,%esp
c01089ac:	5d                   	pop    %ebp
c01089ad:	c3                   	ret    

c01089ae <kva2page>:
kva2page(void *kva) {
c01089ae:	55                   	push   %ebp
c01089af:	89 e5                	mov    %esp,%ebp
c01089b1:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01089b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01089ba:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01089c1:	77 23                	ja     c01089e6 <kva2page+0x38>
c01089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01089ca:	c7 44 24 08 cc c0 10 	movl   $0xc010c0cc,0x8(%esp)
c01089d1:	c0 
c01089d2:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01089d9:	00 
c01089da:	c7 04 24 97 c0 10 c0 	movl   $0xc010c097,(%esp)
c01089e1:	e8 30 83 ff ff       	call   c0100d16 <__panic>
c01089e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089e9:	05 00 00 00 40       	add    $0x40000000,%eax
c01089ee:	89 04 24             	mov    %eax,(%esp)
c01089f1:	e8 1a ff ff ff       	call   c0108910 <pa2page>
}
c01089f6:	89 ec                	mov    %ebp,%esp
c01089f8:	5d                   	pop    %ebp
c01089f9:	c3                   	ret    

c01089fa <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c01089fa:	55                   	push   %ebp
c01089fb:	89 e5                	mov    %esp,%ebp
c01089fd:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0108a00:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c0108a07:	e8 ff c1 ff ff       	call   c0104c0b <kmalloc>
c0108a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0108a0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108a13:	0f 84 a1 00 00 00    	je     c0108aba <alloc_proc+0xc0>
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    //因为没有分配物理页，故将线程状态初始为初始状态
     proc->state=PROC_UNINIT;
c0108a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     proc->pid=-1; //id初始化为-1
c0108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a25:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
     proc->runs=0; //进程调度次数为为0
c0108a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
     proc->kstack=0; //内核栈位置，暂未分配，初始化为0
c0108a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a39:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     proc->need_resched=0; //不需要释放CPU，因为还没有分配
c0108a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a43:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     proc->parent=NULL;  //当前没有父进程，初始为null
c0108a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a4d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
     proc->mm=NULL;     //当前未分配内存，初始为null
c0108a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a57:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
     //用memset将context变量中的所有成员变量置为0
     memset(&(proc -> context), 0, sizeof(struct context)); 
c0108a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a61:	83 c0 1c             	add    $0x1c,%eax
c0108a64:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0108a6b:	00 
c0108a6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108a73:	00 
c0108a74:	89 04 24             	mov    %eax,(%esp)
c0108a77:	e8 07 15 00 00       	call   c0109f83 <memset>
     proc->tf=NULL;   		//当前没有中断帧,初始为null
c0108a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a7f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
     proc->cr3=boot_cr3;    //内核线程，默认初始化为boot_cr3
c0108a86:	8b 15 a8 bf 12 c0    	mov    0xc012bfa8,%edx
c0108a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a8f:	89 50 40             	mov    %edx,0x40(%eax)
     proc->flags=0;//当前进程的相关标志，暂无，设为0
c0108a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a95:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
     memset(proc -> name, 0, PROC_NAME_LEN);
c0108a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a9f:	83 c0 48             	add    $0x48,%eax
c0108aa2:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108aa9:	00 
c0108aaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108ab1:	00 
c0108ab2:	89 04 24             	mov    %eax,(%esp)
c0108ab5:	e8 c9 14 00 00       	call   c0109f83 <memset>
    }
    return proc;
c0108aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108abd:	89 ec                	mov    %ebp,%esp
c0108abf:	5d                   	pop    %ebp
c0108ac0:	c3                   	ret    

c0108ac1 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0108ac1:	55                   	push   %ebp
c0108ac2:	89 e5                	mov    %esp,%ebp
c0108ac4:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0108ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aca:	83 c0 48             	add    $0x48,%eax
c0108acd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108ad4:	00 
c0108ad5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108adc:	00 
c0108add:	89 04 24             	mov    %eax,(%esp)
c0108ae0:	e8 9e 14 00 00       	call   c0109f83 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0108ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ae8:	8d 50 48             	lea    0x48(%eax),%edx
c0108aeb:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108af2:	00 
c0108af3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108af6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108afa:	89 14 24             	mov    %edx,(%esp)
c0108afd:	e8 66 15 00 00       	call   c010a068 <memcpy>
}
c0108b02:	89 ec                	mov    %ebp,%esp
c0108b04:	5d                   	pop    %ebp
c0108b05:	c3                   	ret    

c0108b06 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0108b06:	55                   	push   %ebp
c0108b07:	89 e5                	mov    %esp,%ebp
c0108b09:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0108b0c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108b13:	00 
c0108b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108b1b:	00 
c0108b1c:	c7 04 24 44 e1 12 c0 	movl   $0xc012e144,(%esp)
c0108b23:	e8 5b 14 00 00       	call   c0109f83 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0108b28:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b2b:	83 c0 48             	add    $0x48,%eax
c0108b2e:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108b35:	00 
c0108b36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b3a:	c7 04 24 44 e1 12 c0 	movl   $0xc012e144,(%esp)
c0108b41:	e8 22 15 00 00       	call   c010a068 <memcpy>
}
c0108b46:	89 ec                	mov    %ebp,%esp
c0108b48:	5d                   	pop    %ebp
c0108b49:	c3                   	ret    

c0108b4a <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0108b4a:	55                   	push   %ebp
c0108b4b:	89 e5                	mov    %esp,%ebp
c0108b4d:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0108b50:	c7 45 f8 20 c1 12 c0 	movl   $0xc012c120,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0108b57:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108b5c:	40                   	inc    %eax
c0108b5d:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0108b62:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108b67:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108b6c:	7e 0c                	jle    c0108b7a <get_pid+0x30>
        last_pid = 1;
c0108b6e:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0108b75:	00 00 00 
        goto inside;
c0108b78:	eb 14                	jmp    c0108b8e <get_pid+0x44>
    }
    if (last_pid >= next_safe) {
c0108b7a:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0108b80:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108b85:	39 c2                	cmp    %eax,%edx
c0108b87:	0f 8c ab 00 00 00    	jl     c0108c38 <get_pid+0xee>
    inside:
c0108b8d:	90                   	nop
        next_safe = MAX_PID;
c0108b8e:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0108b95:	20 00 00 
    repeat:
        le = list;
c0108b98:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108b9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0108b9e:	eb 7d                	jmp    c0108c1d <get_pid+0xd3>
            proc = le2proc(le, list_link);
c0108ba0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108ba3:	83 e8 58             	sub    $0x58,%eax
c0108ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0108ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bac:	8b 50 04             	mov    0x4(%eax),%edx
c0108baf:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108bb4:	39 c2                	cmp    %eax,%edx
c0108bb6:	75 3c                	jne    c0108bf4 <get_pid+0xaa>
                if (++ last_pid >= next_safe) {
c0108bb8:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108bbd:	40                   	inc    %eax
c0108bbe:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0108bc3:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0108bc9:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108bce:	39 c2                	cmp    %eax,%edx
c0108bd0:	7c 4b                	jl     c0108c1d <get_pid+0xd3>
                    if (last_pid >= MAX_PID) {
c0108bd2:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108bd7:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108bdc:	7e 0a                	jle    c0108be8 <get_pid+0x9e>
                        last_pid = 1;
c0108bde:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0108be5:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108be8:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0108bef:	20 00 00 
                    goto repeat;
c0108bf2:	eb a4                	jmp    c0108b98 <get_pid+0x4e>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0108bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bf7:	8b 50 04             	mov    0x4(%eax),%edx
c0108bfa:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108bff:	39 c2                	cmp    %eax,%edx
c0108c01:	7e 1a                	jle    c0108c1d <get_pid+0xd3>
c0108c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c06:	8b 50 04             	mov    0x4(%eax),%edx
c0108c09:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108c0e:	39 c2                	cmp    %eax,%edx
c0108c10:	7d 0b                	jge    c0108c1d <get_pid+0xd3>
                next_safe = proc->pid;
c0108c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c15:	8b 40 04             	mov    0x4(%eax),%eax
c0108c18:	a3 84 8a 12 c0       	mov    %eax,0xc0128a84
c0108c1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c26:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0108c29:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0108c2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c2f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0108c32:	0f 85 68 ff ff ff    	jne    c0108ba0 <get_pid+0x56>
            }
        }
    }
    return last_pid;
c0108c38:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
}
c0108c3d:	89 ec                	mov    %ebp,%esp
c0108c3f:	5d                   	pop    %ebp
c0108c40:	c3                   	ret    

c0108c41 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0108c41:	55                   	push   %ebp
c0108c42:	89 e5                	mov    %esp,%ebp
c0108c44:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0108c47:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108c4c:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108c4f:	74 64                	je     c0108cb5 <proc_run+0x74>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0108c51:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108c59:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0108c5f:	e8 3f fc ff ff       	call   c01088a3 <__intr_save>
c0108c64:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0108c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c6a:	a3 30 c1 12 c0       	mov    %eax,0xc012c130
            load_esp0(next->kstack + KSTACKSIZE);
c0108c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c72:	8b 40 0c             	mov    0xc(%eax),%eax
c0108c75:	05 00 20 00 00       	add    $0x2000,%eax
c0108c7a:	89 04 24             	mov    %eax,(%esp)
c0108c7d:	e8 c8 c2 ff ff       	call   c0104f4a <load_esp0>
            lcr3(next->cr3);
c0108c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c85:	8b 40 40             	mov    0x40(%eax),%eax
c0108c88:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108c8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c8e:	0f 22 d8             	mov    %eax,%cr3
}
c0108c91:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c0108c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c95:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c9b:	83 c0 1c             	add    $0x1c,%eax
c0108c9e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108ca2:	89 04 24             	mov    %eax,(%esp)
c0108ca5:	e8 ad 06 00 00       	call   c0109357 <switch_to>
        }
        local_intr_restore(intr_flag);
c0108caa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108cad:	89 04 24             	mov    %eax,(%esp)
c0108cb0:	e8 1a fc ff ff       	call   c01088cf <__intr_restore>
    }
}
c0108cb5:	90                   	nop
c0108cb6:	89 ec                	mov    %ebp,%esp
c0108cb8:	5d                   	pop    %ebp
c0108cb9:	c3                   	ret    

c0108cba <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0108cba:	55                   	push   %ebp
c0108cbb:	89 e5                	mov    %esp,%ebp
c0108cbd:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0108cc0:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108cc5:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108cc8:	89 04 24             	mov    %eax,(%esp)
c0108ccb:	e8 d7 9b ff ff       	call   c01028a7 <forkrets>
}
c0108cd0:	90                   	nop
c0108cd1:	89 ec                	mov    %ebp,%esp
c0108cd3:	5d                   	pop    %ebp
c0108cd4:	c3                   	ret    

c0108cd5 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0108cd5:	55                   	push   %ebp
c0108cd6:	89 e5                	mov    %esp,%ebp
c0108cd8:	83 ec 38             	sub    $0x38,%esp
c0108cdb:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108cde:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce1:	8d 58 60             	lea    0x60(%eax),%ebx
c0108ce4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce7:	8b 40 04             	mov    0x4(%eax),%eax
c0108cea:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108cf1:	00 
c0108cf2:	89 04 24             	mov    %eax,(%esp)
c0108cf5:	e8 ec 07 00 00       	call   c01094e6 <hash32>
c0108cfa:	c1 e0 03             	shl    $0x3,%eax
c0108cfd:	05 40 c1 12 c0       	add    $0xc012c140,%eax
c0108d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d05:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0108d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d11:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108d17:	8b 40 04             	mov    0x4(%eax),%eax
c0108d1a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108d1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108d20:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108d23:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0108d26:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0108d29:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108d2f:	89 10                	mov    %edx,(%eax)
c0108d31:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d34:	8b 10                	mov    (%eax),%edx
c0108d36:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d39:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d3f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108d42:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d48:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108d4b:	89 10                	mov    %edx,(%eax)
}
c0108d4d:	90                   	nop
}
c0108d4e:	90                   	nop
}
c0108d4f:	90                   	nop
}
c0108d50:	90                   	nop
c0108d51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108d54:	89 ec                	mov    %ebp,%esp
c0108d56:	5d                   	pop    %ebp
c0108d57:	c3                   	ret    

c0108d58 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0108d58:	55                   	push   %ebp
c0108d59:	89 e5                	mov    %esp,%ebp
c0108d5b:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0108d5e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108d62:	7e 5f                	jle    c0108dc3 <find_proc+0x6b>
c0108d64:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0108d6b:	7f 56                	jg     c0108dc3 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108d6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d70:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108d77:	00 
c0108d78:	89 04 24             	mov    %eax,(%esp)
c0108d7b:	e8 66 07 00 00       	call   c01094e6 <hash32>
c0108d80:	c1 e0 03             	shl    $0x3,%eax
c0108d83:	05 40 c1 12 c0       	add    $0xc012c140,%eax
c0108d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0108d91:	eb 19                	jmp    c0108dac <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0108d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d96:	83 e8 60             	sub    $0x60,%eax
c0108d99:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0108d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108d9f:	8b 40 04             	mov    0x4(%eax),%eax
c0108da2:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108da5:	75 05                	jne    c0108dac <find_proc+0x54>
                return proc;
c0108da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108daa:	eb 1c                	jmp    c0108dc8 <find_proc+0x70>
c0108dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108daf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0108db2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108db5:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0108db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108dbe:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108dc1:	75 d0                	jne    c0108d93 <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0108dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108dc8:	89 ec                	mov    %ebp,%esp
c0108dca:	5d                   	pop    %ebp
c0108dcb:	c3                   	ret    

c0108dcc <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0108dcc:	55                   	push   %ebp
c0108dcd:	89 e5                	mov    %esp,%ebp
c0108dcf:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108dd2:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108dd9:	00 
c0108dda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108de1:	00 
c0108de2:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108de5:	89 04 24             	mov    %eax,(%esp)
c0108de8:	e8 96 11 00 00       	call   c0109f83 <memset>
    tf.tf_cs = KERNEL_CS;
c0108ded:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108df3:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108df9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108dfd:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108e01:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108e05:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108e09:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e0c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0108e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e12:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0108e15:	b8 9a 88 10 c0       	mov    $0xc010889a,%eax
c0108e1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0108e1d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e20:	0d 00 01 00 00       	or     $0x100,%eax
c0108e25:	89 c2                	mov    %eax,%edx
c0108e27:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108e2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108e35:	00 
c0108e36:	89 14 24             	mov    %edx,(%esp)
c0108e39:	e8 90 01 00 00       	call   c0108fce <do_fork>
}
c0108e3e:	89 ec                	mov    %ebp,%esp
c0108e40:	5d                   	pop    %ebp
c0108e41:	c3                   	ret    

c0108e42 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0108e42:	55                   	push   %ebp
c0108e43:	89 e5                	mov    %esp,%ebp
c0108e45:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108e48:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108e4f:	e8 48 c2 ff ff       	call   c010509c <alloc_pages>
c0108e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108e57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108e5b:	74 1a                	je     c0108e77 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0108e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e60:	89 04 24             	mov    %eax,(%esp)
c0108e63:	e8 f0 fa ff ff       	call   c0108958 <page2kva>
c0108e68:	89 c2                	mov    %eax,%edx
c0108e6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e6d:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108e70:	b8 00 00 00 00       	mov    $0x0,%eax
c0108e75:	eb 05                	jmp    c0108e7c <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0108e77:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0108e7c:	89 ec                	mov    %ebp,%esp
c0108e7e:	5d                   	pop    %ebp
c0108e7f:	c3                   	ret    

c0108e80 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0108e80:	55                   	push   %ebp
c0108e81:	89 e5                	mov    %esp,%ebp
c0108e83:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108e86:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e89:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e8c:	89 04 24             	mov    %eax,(%esp)
c0108e8f:	e8 1a fb ff ff       	call   c01089ae <kva2page>
c0108e94:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0108e9b:	00 
c0108e9c:	89 04 24             	mov    %eax,(%esp)
c0108e9f:	e8 65 c2 ff ff       	call   c0105109 <free_pages>
}
c0108ea4:	90                   	nop
c0108ea5:	89 ec                	mov    %ebp,%esp
c0108ea7:	5d                   	pop    %ebp
c0108ea8:	c3                   	ret    

c0108ea9 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0108ea9:	55                   	push   %ebp
c0108eaa:	89 e5                	mov    %esp,%ebp
c0108eac:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0108eaf:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108eb4:	8b 40 18             	mov    0x18(%eax),%eax
c0108eb7:	85 c0                	test   %eax,%eax
c0108eb9:	74 24                	je     c0108edf <copy_mm+0x36>
c0108ebb:	c7 44 24 0c f0 c0 10 	movl   $0xc010c0f0,0xc(%esp)
c0108ec2:	c0 
c0108ec3:	c7 44 24 08 04 c1 10 	movl   $0xc010c104,0x8(%esp)
c0108eca:	c0 
c0108ecb:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0108ed2:	00 
c0108ed3:	c7 04 24 19 c1 10 c0 	movl   $0xc010c119,(%esp)
c0108eda:	e8 37 7e ff ff       	call   c0100d16 <__panic>
    /* do nothing in this project */
    return 0;
c0108edf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108ee4:	89 ec                	mov    %ebp,%esp
c0108ee6:	5d                   	pop    %ebp
c0108ee7:	c3                   	ret    

c0108ee8 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0108ee8:	55                   	push   %ebp
c0108ee9:	89 e5                	mov    %esp,%ebp
c0108eeb:	57                   	push   %edi
c0108eec:	56                   	push   %esi
c0108eed:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108eee:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ef1:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ef4:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108ef9:	89 c2                	mov    %eax,%edx
c0108efb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108efe:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108f01:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f04:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f07:	8b 55 10             	mov    0x10(%ebp),%edx
c0108f0a:	b9 4c 00 00 00       	mov    $0x4c,%ecx
c0108f0f:	89 c3                	mov    %eax,%ebx
c0108f11:	83 e3 01             	and    $0x1,%ebx
c0108f14:	85 db                	test   %ebx,%ebx
c0108f16:	74 0c                	je     c0108f24 <copy_thread+0x3c>
c0108f18:	0f b6 1a             	movzbl (%edx),%ebx
c0108f1b:	88 18                	mov    %bl,(%eax)
c0108f1d:	8d 40 01             	lea    0x1(%eax),%eax
c0108f20:	8d 52 01             	lea    0x1(%edx),%edx
c0108f23:	49                   	dec    %ecx
c0108f24:	89 c3                	mov    %eax,%ebx
c0108f26:	83 e3 02             	and    $0x2,%ebx
c0108f29:	85 db                	test   %ebx,%ebx
c0108f2b:	74 0f                	je     c0108f3c <copy_thread+0x54>
c0108f2d:	0f b7 1a             	movzwl (%edx),%ebx
c0108f30:	66 89 18             	mov    %bx,(%eax)
c0108f33:	8d 40 02             	lea    0x2(%eax),%eax
c0108f36:	8d 52 02             	lea    0x2(%edx),%edx
c0108f39:	83 e9 02             	sub    $0x2,%ecx
c0108f3c:	89 cf                	mov    %ecx,%edi
c0108f3e:	83 e7 fc             	and    $0xfffffffc,%edi
c0108f41:	bb 00 00 00 00       	mov    $0x0,%ebx
c0108f46:	8b 34 1a             	mov    (%edx,%ebx,1),%esi
c0108f49:	89 34 18             	mov    %esi,(%eax,%ebx,1)
c0108f4c:	83 c3 04             	add    $0x4,%ebx
c0108f4f:	39 fb                	cmp    %edi,%ebx
c0108f51:	72 f3                	jb     c0108f46 <copy_thread+0x5e>
c0108f53:	01 d8                	add    %ebx,%eax
c0108f55:	01 da                	add    %ebx,%edx
c0108f57:	bb 00 00 00 00       	mov    $0x0,%ebx
c0108f5c:	89 ce                	mov    %ecx,%esi
c0108f5e:	83 e6 02             	and    $0x2,%esi
c0108f61:	85 f6                	test   %esi,%esi
c0108f63:	74 0b                	je     c0108f70 <copy_thread+0x88>
c0108f65:	0f b7 34 1a          	movzwl (%edx,%ebx,1),%esi
c0108f69:	66 89 34 18          	mov    %si,(%eax,%ebx,1)
c0108f6d:	83 c3 02             	add    $0x2,%ebx
c0108f70:	83 e1 01             	and    $0x1,%ecx
c0108f73:	85 c9                	test   %ecx,%ecx
c0108f75:	74 07                	je     c0108f7e <copy_thread+0x96>
c0108f77:	0f b6 14 1a          	movzbl (%edx,%ebx,1),%edx
c0108f7b:	88 14 18             	mov    %dl,(%eax,%ebx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0108f7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f81:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f84:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0108f8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f8e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f91:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108f94:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0108f97:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f9a:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f9d:	8b 50 40             	mov    0x40(%eax),%edx
c0108fa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fa3:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108fa6:	81 ca 00 02 00 00    	or     $0x200,%edx
c0108fac:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0108faf:	ba ba 8c 10 c0       	mov    $0xc0108cba,%edx
c0108fb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fb7:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0108fba:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fbd:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108fc0:	89 c2                	mov    %eax,%edx
c0108fc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fc5:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108fc8:	90                   	nop
c0108fc9:	5b                   	pop    %ebx
c0108fca:	5e                   	pop    %esi
c0108fcb:	5f                   	pop    %edi
c0108fcc:	5d                   	pop    %ebp
c0108fcd:	c3                   	ret    

c0108fce <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0108fce:	55                   	push   %ebp
c0108fcf:	89 e5                	mov    %esp,%ebp
c0108fd1:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c0108fd4:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108fdb:	a1 40 e1 12 c0       	mov    0xc012e140,%eax
c0108fe0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0108fe5:	0f 8f fa 00 00 00    	jg     c01090e5 <do_fork+0x117>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0108feb:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
     //1.调用alloc_proc()函数申请内存块，将子进程的父节点设置为当前进程
    if((proc=alloc_proc())==NULL) 
c0108ff2:	e8 03 fa ff ff       	call   c01089fa <alloc_proc>
c0108ff7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ffa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108ffe:	0f 84 e4 00 00 00    	je     c01090e8 <do_fork+0x11a>
        goto fork_out;
    proc->parent=current;
c0109004:	8b 15 30 c1 12 c0    	mov    0xc012c130,%edx
c010900a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010900d:	89 50 14             	mov    %edx,0x14(%eax)
    // 2. 调用setup_stack()函数为进程分配一个内核栈
    if (setup_kstack(proc)!=0)
c0109010:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109013:	89 04 24             	mov    %eax,(%esp)
c0109016:	e8 27 fe ff ff       	call   c0108e42 <setup_kstack>
c010901b:	85 c0                	test   %eax,%eax
c010901d:	0f 85 cb 00 00 00    	jne    c01090ee <do_fork+0x120>
        goto bad_fork_cleanup_proc;
    // 3. 调用copy_mm()函数（proc.c253行）复制父进程的内存信息到子进程
    if(copy_mm(clone_flags, proc)!=0)
c0109023:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109026:	89 44 24 04          	mov    %eax,0x4(%esp)
c010902a:	8b 45 08             	mov    0x8(%ebp),%eax
c010902d:	89 04 24             	mov    %eax,(%esp)
c0109030:	e8 74 fe ff ff       	call   c0108ea9 <copy_mm>
c0109035:	85 c0                	test   %eax,%eax
c0109037:	0f 85 b4 00 00 00    	jne    c01090f1 <do_fork+0x123>
        goto bad_fork_cleanup_proc;
    // 4. 调用copy_thread()函数复制父进程的中断帧和上下文信息
    copy_thread(proc,stack,tf);  
c010903d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109040:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109044:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109047:	89 44 24 04          	mov    %eax,0x4(%esp)
c010904b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010904e:	89 04 24             	mov    %eax,(%esp)
c0109051:	e8 92 fe ff ff       	call   c0108ee8 <copy_thread>
    // 5. 将新进程添加到进程的（hash）列表中
    proc->pid = get_pid(); //创建一个id
c0109056:	e8 ef fa ff ff       	call   c0108b4a <get_pid>
c010905b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010905e:	89 42 04             	mov    %eax,0x4(%edx)
    // 将线程放入使用hash组织的链表以及所有线程的链表中
    hash_proc(proc); //建立映射
c0109061:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109064:	89 04 24             	mov    %eax,(%esp)
c0109067:	e8 69 fc ff ff       	call   c0108cd5 <hash_proc>
    list_add(&proc_list, &proc->list_link); 
c010906c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010906f:	83 c0 58             	add    $0x58,%eax
c0109072:	c7 45 ec 20 c1 12 c0 	movl   $0xc012c120,-0x14(%ebp)
c0109079:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010907c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010907f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109082:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109085:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010908b:	8b 40 04             	mov    0x4(%eax),%eax
c010908e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109091:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0109094:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109097:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010909a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c010909d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01090a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01090a3:	89 10                	mov    %edx,(%eax)
c01090a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01090a8:	8b 10                	mov    (%eax),%edx
c01090aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01090ad:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01090b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01090b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01090b6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01090b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01090bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01090bf:	89 10                	mov    %edx,(%eax)
}
c01090c1:	90                   	nop
}
c01090c2:	90                   	nop
}
c01090c3:	90                   	nop
    nr_process ++;  // 将全局线程的数目加1
c01090c4:	a1 40 e1 12 c0       	mov    0xc012e140,%eax
c01090c9:	40                   	inc    %eax
c01090ca:	a3 40 e1 12 c0       	mov    %eax,0xc012e140
    // 6. 唤醒子进程
    wakeup_proc(proc);
c01090cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090d2:	89 04 24             	mov    %eax,(%esp)
c01090d5:	e8 f6 02 00 00       	call   c01093d0 <wakeup_proc>
    // 7. 返回子进程的pid
     ret = proc->pid; // 返回新线程的pid
c01090da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090dd:	8b 40 04             	mov    0x4(%eax),%eax
c01090e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090e3:	eb 04                	jmp    c01090e9 <do_fork+0x11b>
        goto fork_out;
c01090e5:	90                   	nop
c01090e6:	eb 01                	jmp    c01090e9 <do_fork+0x11b>
        goto fork_out;
c01090e8:	90                   	nop
fork_out:
    return ret;
c01090e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090ec:	eb 11                	jmp    c01090ff <do_fork+0x131>
        goto bad_fork_cleanup_proc;
c01090ee:	90                   	nop
c01090ef:	eb 01                	jmp    c01090f2 <do_fork+0x124>
        goto bad_fork_cleanup_proc;
c01090f1:	90                   	nop

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c01090f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090f5:	89 04 24             	mov    %eax,(%esp)
c01090f8:	e8 2b bb ff ff       	call   c0104c28 <kfree>
    goto fork_out;
c01090fd:	eb ea                	jmp    c01090e9 <do_fork+0x11b>
}
c01090ff:	89 ec                	mov    %ebp,%esp
c0109101:	5d                   	pop    %ebp
c0109102:	c3                   	ret    

c0109103 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109103:	55                   	push   %ebp
c0109104:	89 e5                	mov    %esp,%ebp
c0109106:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c0109109:	c7 44 24 08 2d c1 10 	movl   $0xc010c12d,0x8(%esp)
c0109110:	c0 
c0109111:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
c0109118:	00 
c0109119:	c7 04 24 19 c1 10 c0 	movl   $0xc010c119,(%esp)
c0109120:	e8 f1 7b ff ff       	call   c0100d16 <__panic>

c0109125 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0109125:	55                   	push   %ebp
c0109126:	89 e5                	mov    %esp,%ebp
c0109128:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c010912b:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0109130:	89 04 24             	mov    %eax,(%esp)
c0109133:	e8 ce f9 ff ff       	call   c0108b06 <get_proc_name>
c0109138:	8b 15 30 c1 12 c0    	mov    0xc012c130,%edx
c010913e:	8b 52 04             	mov    0x4(%edx),%edx
c0109141:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109145:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109149:	c7 04 24 40 c1 10 c0 	movl   $0xc010c140,(%esp)
c0109150:	e8 18 72 ff ff       	call   c010036d <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0109155:	8b 45 08             	mov    0x8(%ebp),%eax
c0109158:	89 44 24 04          	mov    %eax,0x4(%esp)
c010915c:	c7 04 24 66 c1 10 c0 	movl   $0xc010c166,(%esp)
c0109163:	e8 05 72 ff ff       	call   c010036d <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0109168:	c7 04 24 73 c1 10 c0 	movl   $0xc010c173,(%esp)
c010916f:	e8 f9 71 ff ff       	call   c010036d <cprintf>
    return 0;
c0109174:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109179:	89 ec                	mov    %ebp,%esp
c010917b:	5d                   	pop    %ebp
c010917c:	c3                   	ret    

c010917d <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010917d:	55                   	push   %ebp
c010917e:	89 e5                	mov    %esp,%ebp
c0109180:	83 ec 28             	sub    $0x28,%esp
c0109183:	c7 45 ec 20 c1 12 c0 	movl   $0xc012c120,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010918a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010918d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109190:	89 50 04             	mov    %edx,0x4(%eax)
c0109193:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109196:	8b 50 04             	mov    0x4(%eax),%edx
c0109199:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010919c:	89 10                	mov    %edx,(%eax)
}
c010919e:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010919f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01091a6:	eb 26                	jmp    c01091ce <proc_init+0x51>
        list_init(hash_list + i);
c01091a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091ab:	c1 e0 03             	shl    $0x3,%eax
c01091ae:	05 40 c1 12 c0       	add    $0xc012c140,%eax
c01091b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c01091b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091b9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01091bc:	89 50 04             	mov    %edx,0x4(%eax)
c01091bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091c2:	8b 50 04             	mov    0x4(%eax),%edx
c01091c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091c8:	89 10                	mov    %edx,(%eax)
}
c01091ca:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c01091cb:	ff 45 f4             	incl   -0xc(%ebp)
c01091ce:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c01091d5:	7e d1                	jle    c01091a8 <proc_init+0x2b>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c01091d7:	e8 1e f8 ff ff       	call   c01089fa <alloc_proc>
c01091dc:	a3 28 c1 12 c0       	mov    %eax,0xc012c128
c01091e1:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01091e6:	85 c0                	test   %eax,%eax
c01091e8:	75 1c                	jne    c0109206 <proc_init+0x89>
        panic("cannot alloc idleproc.\n");
c01091ea:	c7 44 24 08 8f c1 10 	movl   $0xc010c18f,0x8(%esp)
c01091f1:	c0 
c01091f2:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
c01091f9:	00 
c01091fa:	c7 04 24 19 c1 10 c0 	movl   $0xc010c119,(%esp)
c0109201:	e8 10 7b ff ff       	call   c0100d16 <__panic>
    }

    idleproc->pid = 0;
c0109206:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c010920b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0109212:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c0109217:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010921d:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c0109222:	ba 00 60 12 c0       	mov    $0xc0126000,%edx
c0109227:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010922a:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c010922f:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0109236:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c010923b:	c7 44 24 04 a7 c1 10 	movl   $0xc010c1a7,0x4(%esp)
c0109242:	c0 
c0109243:	89 04 24             	mov    %eax,(%esp)
c0109246:	e8 76 f8 ff ff       	call   c0108ac1 <set_proc_name>
    nr_process ++;
c010924b:	a1 40 e1 12 c0       	mov    0xc012e140,%eax
c0109250:	40                   	inc    %eax
c0109251:	a3 40 e1 12 c0       	mov    %eax,0xc012e140

    current = idleproc;
c0109256:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c010925b:	a3 30 c1 12 c0       	mov    %eax,0xc012c130

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0109260:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0109267:	00 
c0109268:	c7 44 24 04 ac c1 10 	movl   $0xc010c1ac,0x4(%esp)
c010926f:	c0 
c0109270:	c7 04 24 25 91 10 c0 	movl   $0xc0109125,(%esp)
c0109277:	e8 50 fb ff ff       	call   c0108dcc <kernel_thread>
c010927c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010927f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109283:	7f 1c                	jg     c01092a1 <proc_init+0x124>
        panic("create init_main failed.\n");
c0109285:	c7 44 24 08 ba c1 10 	movl   $0xc010c1ba,0x8(%esp)
c010928c:	c0 
c010928d:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c0109294:	00 
c0109295:	c7 04 24 19 c1 10 c0 	movl   $0xc010c119,(%esp)
c010929c:	e8 75 7a ff ff       	call   c0100d16 <__panic>
    }

    initproc = find_proc(pid);
c01092a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01092a4:	89 04 24             	mov    %eax,(%esp)
c01092a7:	e8 ac fa ff ff       	call   c0108d58 <find_proc>
c01092ac:	a3 2c c1 12 c0       	mov    %eax,0xc012c12c
    set_proc_name(initproc, "init");
c01092b1:	a1 2c c1 12 c0       	mov    0xc012c12c,%eax
c01092b6:	c7 44 24 04 d4 c1 10 	movl   $0xc010c1d4,0x4(%esp)
c01092bd:	c0 
c01092be:	89 04 24             	mov    %eax,(%esp)
c01092c1:	e8 fb f7 ff ff       	call   c0108ac1 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c01092c6:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01092cb:	85 c0                	test   %eax,%eax
c01092cd:	74 0c                	je     c01092db <proc_init+0x15e>
c01092cf:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01092d4:	8b 40 04             	mov    0x4(%eax),%eax
c01092d7:	85 c0                	test   %eax,%eax
c01092d9:	74 24                	je     c01092ff <proc_init+0x182>
c01092db:	c7 44 24 0c dc c1 10 	movl   $0xc010c1dc,0xc(%esp)
c01092e2:	c0 
c01092e3:	c7 44 24 08 04 c1 10 	movl   $0xc010c104,0x8(%esp)
c01092ea:	c0 
c01092eb:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
c01092f2:	00 
c01092f3:	c7 04 24 19 c1 10 c0 	movl   $0xc010c119,(%esp)
c01092fa:	e8 17 7a ff ff       	call   c0100d16 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c01092ff:	a1 2c c1 12 c0       	mov    0xc012c12c,%eax
c0109304:	85 c0                	test   %eax,%eax
c0109306:	74 0d                	je     c0109315 <proc_init+0x198>
c0109308:	a1 2c c1 12 c0       	mov    0xc012c12c,%eax
c010930d:	8b 40 04             	mov    0x4(%eax),%eax
c0109310:	83 f8 01             	cmp    $0x1,%eax
c0109313:	74 24                	je     c0109339 <proc_init+0x1bc>
c0109315:	c7 44 24 0c 04 c2 10 	movl   $0xc010c204,0xc(%esp)
c010931c:	c0 
c010931d:	c7 44 24 08 04 c1 10 	movl   $0xc010c104,0x8(%esp)
c0109324:	c0 
c0109325:	c7 44 24 04 8c 01 00 	movl   $0x18c,0x4(%esp)
c010932c:	00 
c010932d:	c7 04 24 19 c1 10 c0 	movl   $0xc010c119,(%esp)
c0109334:	e8 dd 79 ff ff       	call   c0100d16 <__panic>
}
c0109339:	90                   	nop
c010933a:	89 ec                	mov    %ebp,%esp
c010933c:	5d                   	pop    %ebp
c010933d:	c3                   	ret    

c010933e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010933e:	55                   	push   %ebp
c010933f:	89 e5                	mov    %esp,%ebp
c0109341:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0109344:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0109349:	8b 40 10             	mov    0x10(%eax),%eax
c010934c:	85 c0                	test   %eax,%eax
c010934e:	74 f4                	je     c0109344 <cpu_idle+0x6>
            schedule();
c0109350:	e8 c7 00 00 00       	call   c010941c <schedule>
        if (current->need_resched) {
c0109355:	eb ed                	jmp    c0109344 <cpu_idle+0x6>

c0109357 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0109357:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010935b:	8f 00                	pop    (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c010935d:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0109360:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c0109363:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c0109366:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c0109369:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c010936c:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c010936f:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0109372:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c0109376:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c0109379:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c010937c:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c010937f:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0109382:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c0109385:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c0109388:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010938b:	ff 30                	push   (%eax)

    ret
c010938d:	c3                   	ret    

c010938e <__intr_save>:
__intr_save(void) {
c010938e:	55                   	push   %ebp
c010938f:	89 e5                	mov    %esp,%ebp
c0109391:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109394:	9c                   	pushf  
c0109395:	58                   	pop    %eax
c0109396:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109399:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010939c:	25 00 02 00 00       	and    $0x200,%eax
c01093a1:	85 c0                	test   %eax,%eax
c01093a3:	74 0c                	je     c01093b1 <__intr_save+0x23>
        intr_disable();
c01093a5:	e8 22 8c ff ff       	call   c0101fcc <intr_disable>
        return 1;
c01093aa:	b8 01 00 00 00       	mov    $0x1,%eax
c01093af:	eb 05                	jmp    c01093b6 <__intr_save+0x28>
    return 0;
c01093b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01093b6:	89 ec                	mov    %ebp,%esp
c01093b8:	5d                   	pop    %ebp
c01093b9:	c3                   	ret    

c01093ba <__intr_restore>:
__intr_restore(bool flag) {
c01093ba:	55                   	push   %ebp
c01093bb:	89 e5                	mov    %esp,%ebp
c01093bd:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01093c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01093c4:	74 05                	je     c01093cb <__intr_restore+0x11>
        intr_enable();
c01093c6:	e8 f9 8b ff ff       	call   c0101fc4 <intr_enable>
}
c01093cb:	90                   	nop
c01093cc:	89 ec                	mov    %ebp,%esp
c01093ce:	5d                   	pop    %ebp
c01093cf:	c3                   	ret    

c01093d0 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c01093d0:	55                   	push   %ebp
c01093d1:	89 e5                	mov    %esp,%ebp
c01093d3:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c01093d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01093d9:	8b 00                	mov    (%eax),%eax
c01093db:	83 f8 03             	cmp    $0x3,%eax
c01093de:	74 0a                	je     c01093ea <wakeup_proc+0x1a>
c01093e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01093e3:	8b 00                	mov    (%eax),%eax
c01093e5:	83 f8 02             	cmp    $0x2,%eax
c01093e8:	75 24                	jne    c010940e <wakeup_proc+0x3e>
c01093ea:	c7 44 24 0c 2c c2 10 	movl   $0xc010c22c,0xc(%esp)
c01093f1:	c0 
c01093f2:	c7 44 24 08 67 c2 10 	movl   $0xc010c267,0x8(%esp)
c01093f9:	c0 
c01093fa:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c0109401:	00 
c0109402:	c7 04 24 7c c2 10 c0 	movl   $0xc010c27c,(%esp)
c0109409:	e8 08 79 ff ff       	call   c0100d16 <__panic>
    proc->state = PROC_RUNNABLE;
c010940e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109411:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0109417:	90                   	nop
c0109418:	89 ec                	mov    %ebp,%esp
c010941a:	5d                   	pop    %ebp
c010941b:	c3                   	ret    

c010941c <schedule>:

void
schedule(void) {
c010941c:	55                   	push   %ebp
c010941d:	89 e5                	mov    %esp,%ebp
c010941f:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c0109422:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0109429:	e8 60 ff ff ff       	call   c010938e <__intr_save>
c010942e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0109431:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0109436:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010943d:	8b 15 30 c1 12 c0    	mov    0xc012c130,%edx
c0109443:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c0109448:	39 c2                	cmp    %eax,%edx
c010944a:	74 0a                	je     c0109456 <schedule+0x3a>
c010944c:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0109451:	83 c0 58             	add    $0x58,%eax
c0109454:	eb 05                	jmp    c010945b <schedule+0x3f>
c0109456:	b8 20 c1 12 c0       	mov    $0xc012c120,%eax
c010945b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010945e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109461:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109464:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109467:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010946a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010946d:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c0109470:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109473:	81 7d f4 20 c1 12 c0 	cmpl   $0xc012c120,-0xc(%ebp)
c010947a:	74 13                	je     c010948f <schedule+0x73>
                next = le2proc(le, list_link);
c010947c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010947f:	83 e8 58             	sub    $0x58,%eax
c0109482:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109485:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109488:	8b 00                	mov    (%eax),%eax
c010948a:	83 f8 02             	cmp    $0x2,%eax
c010948d:	74 0a                	je     c0109499 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c010948f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109492:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109495:	75 cd                	jne    c0109464 <schedule+0x48>
c0109497:	eb 01                	jmp    c010949a <schedule+0x7e>
                    break;
c0109499:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010949a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010949e:	74 0a                	je     c01094aa <schedule+0x8e>
c01094a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01094a3:	8b 00                	mov    (%eax),%eax
c01094a5:	83 f8 02             	cmp    $0x2,%eax
c01094a8:	74 08                	je     c01094b2 <schedule+0x96>
            next = idleproc;
c01094aa:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01094af:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c01094b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01094b5:	8b 40 08             	mov    0x8(%eax),%eax
c01094b8:	8d 50 01             	lea    0x1(%eax),%edx
c01094bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01094be:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c01094c1:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c01094c6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01094c9:	74 0b                	je     c01094d6 <schedule+0xba>
            proc_run(next);
c01094cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01094ce:	89 04 24             	mov    %eax,(%esp)
c01094d1:	e8 6b f7 ff ff       	call   c0108c41 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c01094d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01094d9:	89 04 24             	mov    %eax,(%esp)
c01094dc:	e8 d9 fe ff ff       	call   c01093ba <__intr_restore>
}
c01094e1:	90                   	nop
c01094e2:	89 ec                	mov    %ebp,%esp
c01094e4:	5d                   	pop    %ebp
c01094e5:	c3                   	ret    

c01094e6 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c01094e6:	55                   	push   %ebp
c01094e7:	89 e5                	mov    %esp,%ebp
c01094e9:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c01094ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ef:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c01094f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c01094f8:	b8 20 00 00 00       	mov    $0x20,%eax
c01094fd:	2b 45 0c             	sub    0xc(%ebp),%eax
c0109500:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109503:	88 c1                	mov    %al,%cl
c0109505:	d3 ea                	shr    %cl,%edx
c0109507:	89 d0                	mov    %edx,%eax
}
c0109509:	89 ec                	mov    %ebp,%esp
c010950b:	5d                   	pop    %ebp
c010950c:	c3                   	ret    

c010950d <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010950d:	55                   	push   %ebp
c010950e:	89 e5                	mov    %esp,%ebp
c0109510:	83 ec 58             	sub    $0x58,%esp
c0109513:	8b 45 10             	mov    0x10(%ebp),%eax
c0109516:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0109519:	8b 45 14             	mov    0x14(%ebp),%eax
c010951c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010951f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109522:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109525:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109528:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010952b:	8b 45 18             	mov    0x18(%ebp),%eax
c010952e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109531:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109534:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109537:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010953a:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010953d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109540:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109543:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109547:	74 1c                	je     c0109565 <printnum+0x58>
c0109549:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010954c:	ba 00 00 00 00       	mov    $0x0,%edx
c0109551:	f7 75 e4             	divl   -0x1c(%ebp)
c0109554:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109557:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010955a:	ba 00 00 00 00       	mov    $0x0,%edx
c010955f:	f7 75 e4             	divl   -0x1c(%ebp)
c0109562:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109565:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109568:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010956b:	f7 75 e4             	divl   -0x1c(%ebp)
c010956e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109571:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0109574:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109577:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010957a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010957d:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109580:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109583:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0109586:	8b 45 18             	mov    0x18(%ebp),%eax
c0109589:	ba 00 00 00 00       	mov    $0x0,%edx
c010958e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0109591:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0109594:	19 d1                	sbb    %edx,%ecx
c0109596:	72 4c                	jb     c01095e4 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0109598:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010959b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010959e:	8b 45 20             	mov    0x20(%ebp),%eax
c01095a1:	89 44 24 18          	mov    %eax,0x18(%esp)
c01095a5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01095a9:	8b 45 18             	mov    0x18(%ebp),%eax
c01095ac:	89 44 24 10          	mov    %eax,0x10(%esp)
c01095b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01095b6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01095ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01095be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01095c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01095c8:	89 04 24             	mov    %eax,(%esp)
c01095cb:	e8 3d ff ff ff       	call   c010950d <printnum>
c01095d0:	eb 1b                	jmp    c01095ed <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01095d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01095d9:	8b 45 20             	mov    0x20(%ebp),%eax
c01095dc:	89 04 24             	mov    %eax,(%esp)
c01095df:	8b 45 08             	mov    0x8(%ebp),%eax
c01095e2:	ff d0                	call   *%eax
        while (-- width > 0)
c01095e4:	ff 4d 1c             	decl   0x1c(%ebp)
c01095e7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01095eb:	7f e5                	jg     c01095d2 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01095ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01095f0:	05 14 c3 10 c0       	add    $0xc010c314,%eax
c01095f5:	0f b6 00             	movzbl (%eax),%eax
c01095f8:	0f be c0             	movsbl %al,%eax
c01095fb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01095fe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109602:	89 04 24             	mov    %eax,(%esp)
c0109605:	8b 45 08             	mov    0x8(%ebp),%eax
c0109608:	ff d0                	call   *%eax
}
c010960a:	90                   	nop
c010960b:	89 ec                	mov    %ebp,%esp
c010960d:	5d                   	pop    %ebp
c010960e:	c3                   	ret    

c010960f <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010960f:	55                   	push   %ebp
c0109610:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109612:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109616:	7e 14                	jle    c010962c <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0109618:	8b 45 08             	mov    0x8(%ebp),%eax
c010961b:	8b 00                	mov    (%eax),%eax
c010961d:	8d 48 08             	lea    0x8(%eax),%ecx
c0109620:	8b 55 08             	mov    0x8(%ebp),%edx
c0109623:	89 0a                	mov    %ecx,(%edx)
c0109625:	8b 50 04             	mov    0x4(%eax),%edx
c0109628:	8b 00                	mov    (%eax),%eax
c010962a:	eb 30                	jmp    c010965c <getuint+0x4d>
    }
    else if (lflag) {
c010962c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109630:	74 16                	je     c0109648 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0109632:	8b 45 08             	mov    0x8(%ebp),%eax
c0109635:	8b 00                	mov    (%eax),%eax
c0109637:	8d 48 04             	lea    0x4(%eax),%ecx
c010963a:	8b 55 08             	mov    0x8(%ebp),%edx
c010963d:	89 0a                	mov    %ecx,(%edx)
c010963f:	8b 00                	mov    (%eax),%eax
c0109641:	ba 00 00 00 00       	mov    $0x0,%edx
c0109646:	eb 14                	jmp    c010965c <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0109648:	8b 45 08             	mov    0x8(%ebp),%eax
c010964b:	8b 00                	mov    (%eax),%eax
c010964d:	8d 48 04             	lea    0x4(%eax),%ecx
c0109650:	8b 55 08             	mov    0x8(%ebp),%edx
c0109653:	89 0a                	mov    %ecx,(%edx)
c0109655:	8b 00                	mov    (%eax),%eax
c0109657:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010965c:	5d                   	pop    %ebp
c010965d:	c3                   	ret    

c010965e <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010965e:	55                   	push   %ebp
c010965f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109661:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109665:	7e 14                	jle    c010967b <getint+0x1d>
        return va_arg(*ap, long long);
c0109667:	8b 45 08             	mov    0x8(%ebp),%eax
c010966a:	8b 00                	mov    (%eax),%eax
c010966c:	8d 48 08             	lea    0x8(%eax),%ecx
c010966f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109672:	89 0a                	mov    %ecx,(%edx)
c0109674:	8b 50 04             	mov    0x4(%eax),%edx
c0109677:	8b 00                	mov    (%eax),%eax
c0109679:	eb 28                	jmp    c01096a3 <getint+0x45>
    }
    else if (lflag) {
c010967b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010967f:	74 12                	je     c0109693 <getint+0x35>
        return va_arg(*ap, long);
c0109681:	8b 45 08             	mov    0x8(%ebp),%eax
c0109684:	8b 00                	mov    (%eax),%eax
c0109686:	8d 48 04             	lea    0x4(%eax),%ecx
c0109689:	8b 55 08             	mov    0x8(%ebp),%edx
c010968c:	89 0a                	mov    %ecx,(%edx)
c010968e:	8b 00                	mov    (%eax),%eax
c0109690:	99                   	cltd   
c0109691:	eb 10                	jmp    c01096a3 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0109693:	8b 45 08             	mov    0x8(%ebp),%eax
c0109696:	8b 00                	mov    (%eax),%eax
c0109698:	8d 48 04             	lea    0x4(%eax),%ecx
c010969b:	8b 55 08             	mov    0x8(%ebp),%edx
c010969e:	89 0a                	mov    %ecx,(%edx)
c01096a0:	8b 00                	mov    (%eax),%eax
c01096a2:	99                   	cltd   
    }
}
c01096a3:	5d                   	pop    %ebp
c01096a4:	c3                   	ret    

c01096a5 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01096a5:	55                   	push   %ebp
c01096a6:	89 e5                	mov    %esp,%ebp
c01096a8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01096ab:	8d 45 14             	lea    0x14(%ebp),%eax
c01096ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01096b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01096b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01096bb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01096bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01096c9:	89 04 24             	mov    %eax,(%esp)
c01096cc:	e8 05 00 00 00       	call   c01096d6 <vprintfmt>
    va_end(ap);
}
c01096d1:	90                   	nop
c01096d2:	89 ec                	mov    %ebp,%esp
c01096d4:	5d                   	pop    %ebp
c01096d5:	c3                   	ret    

c01096d6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01096d6:	55                   	push   %ebp
c01096d7:	89 e5                	mov    %esp,%ebp
c01096d9:	56                   	push   %esi
c01096da:	53                   	push   %ebx
c01096db:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01096de:	eb 17                	jmp    c01096f7 <vprintfmt+0x21>
            if (ch == '\0') {
c01096e0:	85 db                	test   %ebx,%ebx
c01096e2:	0f 84 bf 03 00 00    	je     c0109aa7 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01096e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096ef:	89 1c 24             	mov    %ebx,(%esp)
c01096f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01096f5:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01096f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01096fa:	8d 50 01             	lea    0x1(%eax),%edx
c01096fd:	89 55 10             	mov    %edx,0x10(%ebp)
c0109700:	0f b6 00             	movzbl (%eax),%eax
c0109703:	0f b6 d8             	movzbl %al,%ebx
c0109706:	83 fb 25             	cmp    $0x25,%ebx
c0109709:	75 d5                	jne    c01096e0 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010970b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010970f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0109716:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109719:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010971c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0109723:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109726:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0109729:	8b 45 10             	mov    0x10(%ebp),%eax
c010972c:	8d 50 01             	lea    0x1(%eax),%edx
c010972f:	89 55 10             	mov    %edx,0x10(%ebp)
c0109732:	0f b6 00             	movzbl (%eax),%eax
c0109735:	0f b6 d8             	movzbl %al,%ebx
c0109738:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010973b:	83 f8 55             	cmp    $0x55,%eax
c010973e:	0f 87 37 03 00 00    	ja     c0109a7b <vprintfmt+0x3a5>
c0109744:	8b 04 85 38 c3 10 c0 	mov    -0x3fef3cc8(,%eax,4),%eax
c010974b:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010974d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0109751:	eb d6                	jmp    c0109729 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0109753:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0109757:	eb d0                	jmp    c0109729 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0109759:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0109760:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109763:	89 d0                	mov    %edx,%eax
c0109765:	c1 e0 02             	shl    $0x2,%eax
c0109768:	01 d0                	add    %edx,%eax
c010976a:	01 c0                	add    %eax,%eax
c010976c:	01 d8                	add    %ebx,%eax
c010976e:	83 e8 30             	sub    $0x30,%eax
c0109771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0109774:	8b 45 10             	mov    0x10(%ebp),%eax
c0109777:	0f b6 00             	movzbl (%eax),%eax
c010977a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010977d:	83 fb 2f             	cmp    $0x2f,%ebx
c0109780:	7e 38                	jle    c01097ba <vprintfmt+0xe4>
c0109782:	83 fb 39             	cmp    $0x39,%ebx
c0109785:	7f 33                	jg     c01097ba <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0109787:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010978a:	eb d4                	jmp    c0109760 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010978c:	8b 45 14             	mov    0x14(%ebp),%eax
c010978f:	8d 50 04             	lea    0x4(%eax),%edx
c0109792:	89 55 14             	mov    %edx,0x14(%ebp)
c0109795:	8b 00                	mov    (%eax),%eax
c0109797:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010979a:	eb 1f                	jmp    c01097bb <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010979c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01097a0:	79 87                	jns    c0109729 <vprintfmt+0x53>
                width = 0;
c01097a2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01097a9:	e9 7b ff ff ff       	jmp    c0109729 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01097ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01097b5:	e9 6f ff ff ff       	jmp    c0109729 <vprintfmt+0x53>
            goto process_precision;
c01097ba:	90                   	nop

        process_precision:
            if (width < 0)
c01097bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01097bf:	0f 89 64 ff ff ff    	jns    c0109729 <vprintfmt+0x53>
                width = precision, precision = -1;
c01097c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01097c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01097cb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01097d2:	e9 52 ff ff ff       	jmp    c0109729 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01097d7:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c01097da:	e9 4a ff ff ff       	jmp    c0109729 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01097df:	8b 45 14             	mov    0x14(%ebp),%eax
c01097e2:	8d 50 04             	lea    0x4(%eax),%edx
c01097e5:	89 55 14             	mov    %edx,0x14(%ebp)
c01097e8:	8b 00                	mov    (%eax),%eax
c01097ea:	8b 55 0c             	mov    0xc(%ebp),%edx
c01097ed:	89 54 24 04          	mov    %edx,0x4(%esp)
c01097f1:	89 04 24             	mov    %eax,(%esp)
c01097f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f7:	ff d0                	call   *%eax
            break;
c01097f9:	e9 a4 02 00 00       	jmp    c0109aa2 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01097fe:	8b 45 14             	mov    0x14(%ebp),%eax
c0109801:	8d 50 04             	lea    0x4(%eax),%edx
c0109804:	89 55 14             	mov    %edx,0x14(%ebp)
c0109807:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0109809:	85 db                	test   %ebx,%ebx
c010980b:	79 02                	jns    c010980f <vprintfmt+0x139>
                err = -err;
c010980d:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010980f:	83 fb 06             	cmp    $0x6,%ebx
c0109812:	7f 0b                	jg     c010981f <vprintfmt+0x149>
c0109814:	8b 34 9d f8 c2 10 c0 	mov    -0x3fef3d08(,%ebx,4),%esi
c010981b:	85 f6                	test   %esi,%esi
c010981d:	75 23                	jne    c0109842 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010981f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0109823:	c7 44 24 08 25 c3 10 	movl   $0xc010c325,0x8(%esp)
c010982a:	c0 
c010982b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010982e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109832:	8b 45 08             	mov    0x8(%ebp),%eax
c0109835:	89 04 24             	mov    %eax,(%esp)
c0109838:	e8 68 fe ff ff       	call   c01096a5 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010983d:	e9 60 02 00 00       	jmp    c0109aa2 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0109842:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0109846:	c7 44 24 08 2e c3 10 	movl   $0xc010c32e,0x8(%esp)
c010984d:	c0 
c010984e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109851:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109855:	8b 45 08             	mov    0x8(%ebp),%eax
c0109858:	89 04 24             	mov    %eax,(%esp)
c010985b:	e8 45 fe ff ff       	call   c01096a5 <printfmt>
            break;
c0109860:	e9 3d 02 00 00       	jmp    c0109aa2 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0109865:	8b 45 14             	mov    0x14(%ebp),%eax
c0109868:	8d 50 04             	lea    0x4(%eax),%edx
c010986b:	89 55 14             	mov    %edx,0x14(%ebp)
c010986e:	8b 30                	mov    (%eax),%esi
c0109870:	85 f6                	test   %esi,%esi
c0109872:	75 05                	jne    c0109879 <vprintfmt+0x1a3>
                p = "(null)";
c0109874:	be 31 c3 10 c0       	mov    $0xc010c331,%esi
            }
            if (width > 0 && padc != '-') {
c0109879:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010987d:	7e 76                	jle    c01098f5 <vprintfmt+0x21f>
c010987f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0109883:	74 70                	je     c01098f5 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109888:	89 44 24 04          	mov    %eax,0x4(%esp)
c010988c:	89 34 24             	mov    %esi,(%esp)
c010988f:	e8 ee 03 00 00       	call   c0109c82 <strnlen>
c0109894:	89 c2                	mov    %eax,%edx
c0109896:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109899:	29 d0                	sub    %edx,%eax
c010989b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010989e:	eb 16                	jmp    c01098b6 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01098a0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01098a4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01098a7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01098ab:	89 04 24             	mov    %eax,(%esp)
c01098ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01098b1:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c01098b3:	ff 4d e8             	decl   -0x18(%ebp)
c01098b6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01098ba:	7f e4                	jg     c01098a0 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01098bc:	eb 37                	jmp    c01098f5 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c01098be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01098c2:	74 1f                	je     c01098e3 <vprintfmt+0x20d>
c01098c4:	83 fb 1f             	cmp    $0x1f,%ebx
c01098c7:	7e 05                	jle    c01098ce <vprintfmt+0x1f8>
c01098c9:	83 fb 7e             	cmp    $0x7e,%ebx
c01098cc:	7e 15                	jle    c01098e3 <vprintfmt+0x20d>
                    putch('?', putdat);
c01098ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098d5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01098dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01098df:	ff d0                	call   *%eax
c01098e1:	eb 0f                	jmp    c01098f2 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c01098e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098ea:	89 1c 24             	mov    %ebx,(%esp)
c01098ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01098f0:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01098f2:	ff 4d e8             	decl   -0x18(%ebp)
c01098f5:	89 f0                	mov    %esi,%eax
c01098f7:	8d 70 01             	lea    0x1(%eax),%esi
c01098fa:	0f b6 00             	movzbl (%eax),%eax
c01098fd:	0f be d8             	movsbl %al,%ebx
c0109900:	85 db                	test   %ebx,%ebx
c0109902:	74 27                	je     c010992b <vprintfmt+0x255>
c0109904:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109908:	78 b4                	js     c01098be <vprintfmt+0x1e8>
c010990a:	ff 4d e4             	decl   -0x1c(%ebp)
c010990d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109911:	79 ab                	jns    c01098be <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0109913:	eb 16                	jmp    c010992b <vprintfmt+0x255>
                putch(' ', putdat);
c0109915:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109918:	89 44 24 04          	mov    %eax,0x4(%esp)
c010991c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0109923:	8b 45 08             	mov    0x8(%ebp),%eax
c0109926:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0109928:	ff 4d e8             	decl   -0x18(%ebp)
c010992b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010992f:	7f e4                	jg     c0109915 <vprintfmt+0x23f>
            }
            break;
c0109931:	e9 6c 01 00 00       	jmp    c0109aa2 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0109936:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109939:	89 44 24 04          	mov    %eax,0x4(%esp)
c010993d:	8d 45 14             	lea    0x14(%ebp),%eax
c0109940:	89 04 24             	mov    %eax,(%esp)
c0109943:	e8 16 fd ff ff       	call   c010965e <getint>
c0109948:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010994b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010994e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109951:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109954:	85 d2                	test   %edx,%edx
c0109956:	79 26                	jns    c010997e <vprintfmt+0x2a8>
                putch('-', putdat);
c0109958:	8b 45 0c             	mov    0xc(%ebp),%eax
c010995b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010995f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0109966:	8b 45 08             	mov    0x8(%ebp),%eax
c0109969:	ff d0                	call   *%eax
                num = -(long long)num;
c010996b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010996e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109971:	f7 d8                	neg    %eax
c0109973:	83 d2 00             	adc    $0x0,%edx
c0109976:	f7 da                	neg    %edx
c0109978:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010997b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010997e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109985:	e9 a8 00 00 00       	jmp    c0109a32 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010998a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010998d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109991:	8d 45 14             	lea    0x14(%ebp),%eax
c0109994:	89 04 24             	mov    %eax,(%esp)
c0109997:	e8 73 fc ff ff       	call   c010960f <getuint>
c010999c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010999f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01099a2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01099a9:	e9 84 00 00 00       	jmp    c0109a32 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01099ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01099b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099b5:	8d 45 14             	lea    0x14(%ebp),%eax
c01099b8:	89 04 24             	mov    %eax,(%esp)
c01099bb:	e8 4f fc ff ff       	call   c010960f <getuint>
c01099c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01099c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01099c6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01099cd:	eb 63                	jmp    c0109a32 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c01099cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01099d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01099dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01099e0:	ff d0                	call   *%eax
            putch('x', putdat);
c01099e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01099e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099e9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01099f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099f3:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01099f5:	8b 45 14             	mov    0x14(%ebp),%eax
c01099f8:	8d 50 04             	lea    0x4(%eax),%edx
c01099fb:	89 55 14             	mov    %edx,0x14(%ebp)
c01099fe:	8b 00                	mov    (%eax),%eax
c0109a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0109a0a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0109a11:	eb 1f                	jmp    c0109a32 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0109a13:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109a16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a1a:	8d 45 14             	lea    0x14(%ebp),%eax
c0109a1d:	89 04 24             	mov    %eax,(%esp)
c0109a20:	e8 ea fb ff ff       	call   c010960f <getuint>
c0109a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a28:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109a2b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0109a32:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0109a36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a39:	89 54 24 18          	mov    %edx,0x18(%esp)
c0109a3d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109a40:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109a44:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a4e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109a52:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109a56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a60:	89 04 24             	mov    %eax,(%esp)
c0109a63:	e8 a5 fa ff ff       	call   c010950d <printnum>
            break;
c0109a68:	eb 38                	jmp    c0109aa2 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0109a6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a71:	89 1c 24             	mov    %ebx,(%esp)
c0109a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a77:	ff d0                	call   *%eax
            break;
c0109a79:	eb 27                	jmp    c0109aa2 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0109a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a82:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a8c:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109a8e:	ff 4d 10             	decl   0x10(%ebp)
c0109a91:	eb 03                	jmp    c0109a96 <vprintfmt+0x3c0>
c0109a93:	ff 4d 10             	decl   0x10(%ebp)
c0109a96:	8b 45 10             	mov    0x10(%ebp),%eax
c0109a99:	48                   	dec    %eax
c0109a9a:	0f b6 00             	movzbl (%eax),%eax
c0109a9d:	3c 25                	cmp    $0x25,%al
c0109a9f:	75 f2                	jne    c0109a93 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0109aa1:	90                   	nop
    while (1) {
c0109aa2:	e9 37 fc ff ff       	jmp    c01096de <vprintfmt+0x8>
                return;
c0109aa7:	90                   	nop
        }
    }
}
c0109aa8:	83 c4 40             	add    $0x40,%esp
c0109aab:	5b                   	pop    %ebx
c0109aac:	5e                   	pop    %esi
c0109aad:	5d                   	pop    %ebp
c0109aae:	c3                   	ret    

c0109aaf <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109aaf:	55                   	push   %ebp
c0109ab0:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ab5:	8b 40 08             	mov    0x8(%eax),%eax
c0109ab8:	8d 50 01             	lea    0x1(%eax),%edx
c0109abb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109abe:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ac4:	8b 10                	mov    (%eax),%edx
c0109ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ac9:	8b 40 04             	mov    0x4(%eax),%eax
c0109acc:	39 c2                	cmp    %eax,%edx
c0109ace:	73 12                	jae    c0109ae2 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ad3:	8b 00                	mov    (%eax),%eax
c0109ad5:	8d 48 01             	lea    0x1(%eax),%ecx
c0109ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109adb:	89 0a                	mov    %ecx,(%edx)
c0109add:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ae0:	88 10                	mov    %dl,(%eax)
    }
}
c0109ae2:	90                   	nop
c0109ae3:	5d                   	pop    %ebp
c0109ae4:	c3                   	ret    

c0109ae5 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0109ae5:	55                   	push   %ebp
c0109ae6:	89 e5                	mov    %esp,%ebp
c0109ae8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109aeb:	8d 45 14             	lea    0x14(%ebp),%eax
c0109aee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109af4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109af8:	8b 45 10             	mov    0x10(%ebp),%eax
c0109afb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109aff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b06:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b09:	89 04 24             	mov    %eax,(%esp)
c0109b0c:	e8 0a 00 00 00       	call   c0109b1b <vsnprintf>
c0109b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0109b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109b17:	89 ec                	mov    %ebp,%esp
c0109b19:	5d                   	pop    %ebp
c0109b1a:	c3                   	ret    

c0109b1b <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109b1b:	55                   	push   %ebp
c0109b1c:	89 e5                	mov    %esp,%ebp
c0109b1e:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109b21:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b24:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109b27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b2a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109b2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b30:	01 d0                	add    %edx,%eax
c0109b32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109b3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109b40:	74 0a                	je     c0109b4c <vsnprintf+0x31>
c0109b42:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b48:	39 c2                	cmp    %eax,%edx
c0109b4a:	76 07                	jbe    c0109b53 <vsnprintf+0x38>
        return -E_INVAL;
c0109b4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109b51:	eb 2a                	jmp    c0109b7d <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0109b53:	8b 45 14             	mov    0x14(%ebp),%eax
c0109b56:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109b5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0109b5d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109b61:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109b64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b68:	c7 04 24 af 9a 10 c0 	movl   $0xc0109aaf,(%esp)
c0109b6f:	e8 62 fb ff ff       	call   c01096d6 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0109b74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b77:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109b7d:	89 ec                	mov    %ebp,%esp
c0109b7f:	5d                   	pop    %ebp
c0109b80:	c3                   	ret    

c0109b81 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0109b81:	55                   	push   %ebp
c0109b82:	89 e5                	mov    %esp,%ebp
c0109b84:	57                   	push   %edi
c0109b85:	56                   	push   %esi
c0109b86:	53                   	push   %ebx
c0109b87:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109b8a:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c0109b8f:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c0109b95:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109b9b:	6b f0 05             	imul   $0x5,%eax,%esi
c0109b9e:	01 fe                	add    %edi,%esi
c0109ba0:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109ba5:	f7 e7                	mul    %edi
c0109ba7:	01 d6                	add    %edx,%esi
c0109ba9:	89 f2                	mov    %esi,%edx
c0109bab:	83 c0 0b             	add    $0xb,%eax
c0109bae:	83 d2 00             	adc    $0x0,%edx
c0109bb1:	89 c7                	mov    %eax,%edi
c0109bb3:	83 e7 ff             	and    $0xffffffff,%edi
c0109bb6:	89 f9                	mov    %edi,%ecx
c0109bb8:	0f b7 da             	movzwl %dx,%ebx
c0109bbb:	89 0d 88 8a 12 c0    	mov    %ecx,0xc0128a88
c0109bc1:	89 1d 8c 8a 12 c0    	mov    %ebx,0xc0128a8c
    unsigned long long result = (next >> 12);
c0109bc7:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c0109bcc:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c0109bd2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109bd6:	c1 ea 0c             	shr    $0xc,%edx
c0109bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109bdc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109bdf:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109be6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109be9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109bec:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109bef:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109bf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109bf8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109bfc:	74 1c                	je     c0109c1a <rand+0x99>
c0109bfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109c01:	ba 00 00 00 00       	mov    $0x0,%edx
c0109c06:	f7 75 dc             	divl   -0x24(%ebp)
c0109c09:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109c0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109c0f:	ba 00 00 00 00       	mov    $0x0,%edx
c0109c14:	f7 75 dc             	divl   -0x24(%ebp)
c0109c17:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109c1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109c1d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109c20:	f7 75 dc             	divl   -0x24(%ebp)
c0109c23:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109c26:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109c29:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109c2c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109c2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109c32:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109c35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109c38:	83 c4 24             	add    $0x24,%esp
c0109c3b:	5b                   	pop    %ebx
c0109c3c:	5e                   	pop    %esi
c0109c3d:	5f                   	pop    %edi
c0109c3e:	5d                   	pop    %ebp
c0109c3f:	c3                   	ret    

c0109c40 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109c40:	55                   	push   %ebp
c0109c41:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109c43:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c46:	ba 00 00 00 00       	mov    $0x0,%edx
c0109c4b:	a3 88 8a 12 c0       	mov    %eax,0xc0128a88
c0109c50:	89 15 8c 8a 12 c0    	mov    %edx,0xc0128a8c
}
c0109c56:	90                   	nop
c0109c57:	5d                   	pop    %ebp
c0109c58:	c3                   	ret    

c0109c59 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109c59:	55                   	push   %ebp
c0109c5a:	89 e5                	mov    %esp,%ebp
c0109c5c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109c5f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109c66:	eb 03                	jmp    c0109c6b <strlen+0x12>
        cnt ++;
c0109c68:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0109c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c6e:	8d 50 01             	lea    0x1(%eax),%edx
c0109c71:	89 55 08             	mov    %edx,0x8(%ebp)
c0109c74:	0f b6 00             	movzbl (%eax),%eax
c0109c77:	84 c0                	test   %al,%al
c0109c79:	75 ed                	jne    c0109c68 <strlen+0xf>
    }
    return cnt;
c0109c7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109c7e:	89 ec                	mov    %ebp,%esp
c0109c80:	5d                   	pop    %ebp
c0109c81:	c3                   	ret    

c0109c82 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109c82:	55                   	push   %ebp
c0109c83:	89 e5                	mov    %esp,%ebp
c0109c85:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109c88:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109c8f:	eb 03                	jmp    c0109c94 <strnlen+0x12>
        cnt ++;
c0109c91:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109c97:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109c9a:	73 10                	jae    c0109cac <strnlen+0x2a>
c0109c9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c9f:	8d 50 01             	lea    0x1(%eax),%edx
c0109ca2:	89 55 08             	mov    %edx,0x8(%ebp)
c0109ca5:	0f b6 00             	movzbl (%eax),%eax
c0109ca8:	84 c0                	test   %al,%al
c0109caa:	75 e5                	jne    c0109c91 <strnlen+0xf>
    }
    return cnt;
c0109cac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109caf:	89 ec                	mov    %ebp,%esp
c0109cb1:	5d                   	pop    %ebp
c0109cb2:	c3                   	ret    

c0109cb3 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109cb3:	55                   	push   %ebp
c0109cb4:	89 e5                	mov    %esp,%ebp
c0109cb6:	57                   	push   %edi
c0109cb7:	56                   	push   %esi
c0109cb8:	83 ec 20             	sub    $0x20,%esp
c0109cbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0109cc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ccd:	89 d1                	mov    %edx,%ecx
c0109ccf:	89 c2                	mov    %eax,%edx
c0109cd1:	89 ce                	mov    %ecx,%esi
c0109cd3:	89 d7                	mov    %edx,%edi
c0109cd5:	ac                   	lods   %ds:(%esi),%al
c0109cd6:	aa                   	stos   %al,%es:(%edi)
c0109cd7:	84 c0                	test   %al,%al
c0109cd9:	75 fa                	jne    c0109cd5 <strcpy+0x22>
c0109cdb:	89 fa                	mov    %edi,%edx
c0109cdd:	89 f1                	mov    %esi,%ecx
c0109cdf:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109ce2:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109ce5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0109ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0109ceb:	83 c4 20             	add    $0x20,%esp
c0109cee:	5e                   	pop    %esi
c0109cef:	5f                   	pop    %edi
c0109cf0:	5d                   	pop    %ebp
c0109cf1:	c3                   	ret    

c0109cf2 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109cf2:	55                   	push   %ebp
c0109cf3:	89 e5                	mov    %esp,%ebp
c0109cf5:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0109cf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cfb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109cfe:	eb 1e                	jmp    c0109d1e <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0109d00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d03:	0f b6 10             	movzbl (%eax),%edx
c0109d06:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d09:	88 10                	mov    %dl,(%eax)
c0109d0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d0e:	0f b6 00             	movzbl (%eax),%eax
c0109d11:	84 c0                	test   %al,%al
c0109d13:	74 03                	je     c0109d18 <strncpy+0x26>
            src ++;
c0109d15:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0109d18:	ff 45 fc             	incl   -0x4(%ebp)
c0109d1b:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0109d1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109d22:	75 dc                	jne    c0109d00 <strncpy+0xe>
    }
    return dst;
c0109d24:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109d27:	89 ec                	mov    %ebp,%esp
c0109d29:	5d                   	pop    %ebp
c0109d2a:	c3                   	ret    

c0109d2b <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0109d2b:	55                   	push   %ebp
c0109d2c:	89 e5                	mov    %esp,%ebp
c0109d2e:	57                   	push   %edi
c0109d2f:	56                   	push   %esi
c0109d30:	83 ec 20             	sub    $0x20,%esp
c0109d33:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109d39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0109d3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d45:	89 d1                	mov    %edx,%ecx
c0109d47:	89 c2                	mov    %eax,%edx
c0109d49:	89 ce                	mov    %ecx,%esi
c0109d4b:	89 d7                	mov    %edx,%edi
c0109d4d:	ac                   	lods   %ds:(%esi),%al
c0109d4e:	ae                   	scas   %es:(%edi),%al
c0109d4f:	75 08                	jne    c0109d59 <strcmp+0x2e>
c0109d51:	84 c0                	test   %al,%al
c0109d53:	75 f8                	jne    c0109d4d <strcmp+0x22>
c0109d55:	31 c0                	xor    %eax,%eax
c0109d57:	eb 04                	jmp    c0109d5d <strcmp+0x32>
c0109d59:	19 c0                	sbb    %eax,%eax
c0109d5b:	0c 01                	or     $0x1,%al
c0109d5d:	89 fa                	mov    %edi,%edx
c0109d5f:	89 f1                	mov    %esi,%ecx
c0109d61:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d64:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109d67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0109d6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0109d6d:	83 c4 20             	add    $0x20,%esp
c0109d70:	5e                   	pop    %esi
c0109d71:	5f                   	pop    %edi
c0109d72:	5d                   	pop    %ebp
c0109d73:	c3                   	ret    

c0109d74 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0109d74:	55                   	push   %ebp
c0109d75:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109d77:	eb 09                	jmp    c0109d82 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0109d79:	ff 4d 10             	decl   0x10(%ebp)
c0109d7c:	ff 45 08             	incl   0x8(%ebp)
c0109d7f:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109d82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109d86:	74 1a                	je     c0109da2 <strncmp+0x2e>
c0109d88:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d8b:	0f b6 00             	movzbl (%eax),%eax
c0109d8e:	84 c0                	test   %al,%al
c0109d90:	74 10                	je     c0109da2 <strncmp+0x2e>
c0109d92:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d95:	0f b6 10             	movzbl (%eax),%edx
c0109d98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d9b:	0f b6 00             	movzbl (%eax),%eax
c0109d9e:	38 c2                	cmp    %al,%dl
c0109da0:	74 d7                	je     c0109d79 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109da2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109da6:	74 18                	je     c0109dc0 <strncmp+0x4c>
c0109da8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dab:	0f b6 00             	movzbl (%eax),%eax
c0109dae:	0f b6 d0             	movzbl %al,%edx
c0109db1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109db4:	0f b6 00             	movzbl (%eax),%eax
c0109db7:	0f b6 c8             	movzbl %al,%ecx
c0109dba:	89 d0                	mov    %edx,%eax
c0109dbc:	29 c8                	sub    %ecx,%eax
c0109dbe:	eb 05                	jmp    c0109dc5 <strncmp+0x51>
c0109dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109dc5:	5d                   	pop    %ebp
c0109dc6:	c3                   	ret    

c0109dc7 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109dc7:	55                   	push   %ebp
c0109dc8:	89 e5                	mov    %esp,%ebp
c0109dca:	83 ec 04             	sub    $0x4,%esp
c0109dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109dd0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109dd3:	eb 13                	jmp    c0109de8 <strchr+0x21>
        if (*s == c) {
c0109dd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd8:	0f b6 00             	movzbl (%eax),%eax
c0109ddb:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0109dde:	75 05                	jne    c0109de5 <strchr+0x1e>
            return (char *)s;
c0109de0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109de3:	eb 12                	jmp    c0109df7 <strchr+0x30>
        }
        s ++;
c0109de5:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0109de8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109deb:	0f b6 00             	movzbl (%eax),%eax
c0109dee:	84 c0                	test   %al,%al
c0109df0:	75 e3                	jne    c0109dd5 <strchr+0xe>
    }
    return NULL;
c0109df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109df7:	89 ec                	mov    %ebp,%esp
c0109df9:	5d                   	pop    %ebp
c0109dfa:	c3                   	ret    

c0109dfb <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0109dfb:	55                   	push   %ebp
c0109dfc:	89 e5                	mov    %esp,%ebp
c0109dfe:	83 ec 04             	sub    $0x4,%esp
c0109e01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e04:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109e07:	eb 0e                	jmp    c0109e17 <strfind+0x1c>
        if (*s == c) {
c0109e09:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e0c:	0f b6 00             	movzbl (%eax),%eax
c0109e0f:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0109e12:	74 0f                	je     c0109e23 <strfind+0x28>
            break;
        }
        s ++;
c0109e14:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0109e17:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e1a:	0f b6 00             	movzbl (%eax),%eax
c0109e1d:	84 c0                	test   %al,%al
c0109e1f:	75 e8                	jne    c0109e09 <strfind+0xe>
c0109e21:	eb 01                	jmp    c0109e24 <strfind+0x29>
            break;
c0109e23:	90                   	nop
    }
    return (char *)s;
c0109e24:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109e27:	89 ec                	mov    %ebp,%esp
c0109e29:	5d                   	pop    %ebp
c0109e2a:	c3                   	ret    

c0109e2b <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0109e2b:	55                   	push   %ebp
c0109e2c:	89 e5                	mov    %esp,%ebp
c0109e2e:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109e31:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0109e38:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109e3f:	eb 03                	jmp    c0109e44 <strtol+0x19>
        s ++;
c0109e41:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0109e44:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e47:	0f b6 00             	movzbl (%eax),%eax
c0109e4a:	3c 20                	cmp    $0x20,%al
c0109e4c:	74 f3                	je     c0109e41 <strtol+0x16>
c0109e4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e51:	0f b6 00             	movzbl (%eax),%eax
c0109e54:	3c 09                	cmp    $0x9,%al
c0109e56:	74 e9                	je     c0109e41 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0109e58:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e5b:	0f b6 00             	movzbl (%eax),%eax
c0109e5e:	3c 2b                	cmp    $0x2b,%al
c0109e60:	75 05                	jne    c0109e67 <strtol+0x3c>
        s ++;
c0109e62:	ff 45 08             	incl   0x8(%ebp)
c0109e65:	eb 14                	jmp    c0109e7b <strtol+0x50>
    }
    else if (*s == '-') {
c0109e67:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e6a:	0f b6 00             	movzbl (%eax),%eax
c0109e6d:	3c 2d                	cmp    $0x2d,%al
c0109e6f:	75 0a                	jne    c0109e7b <strtol+0x50>
        s ++, neg = 1;
c0109e71:	ff 45 08             	incl   0x8(%ebp)
c0109e74:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0109e7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109e7f:	74 06                	je     c0109e87 <strtol+0x5c>
c0109e81:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0109e85:	75 22                	jne    c0109ea9 <strtol+0x7e>
c0109e87:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e8a:	0f b6 00             	movzbl (%eax),%eax
c0109e8d:	3c 30                	cmp    $0x30,%al
c0109e8f:	75 18                	jne    c0109ea9 <strtol+0x7e>
c0109e91:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e94:	40                   	inc    %eax
c0109e95:	0f b6 00             	movzbl (%eax),%eax
c0109e98:	3c 78                	cmp    $0x78,%al
c0109e9a:	75 0d                	jne    c0109ea9 <strtol+0x7e>
        s += 2, base = 16;
c0109e9c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0109ea0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0109ea7:	eb 29                	jmp    c0109ed2 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0109ea9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109ead:	75 16                	jne    c0109ec5 <strtol+0x9a>
c0109eaf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eb2:	0f b6 00             	movzbl (%eax),%eax
c0109eb5:	3c 30                	cmp    $0x30,%al
c0109eb7:	75 0c                	jne    c0109ec5 <strtol+0x9a>
        s ++, base = 8;
c0109eb9:	ff 45 08             	incl   0x8(%ebp)
c0109ebc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0109ec3:	eb 0d                	jmp    c0109ed2 <strtol+0xa7>
    }
    else if (base == 0) {
c0109ec5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109ec9:	75 07                	jne    c0109ed2 <strtol+0xa7>
        base = 10;
c0109ecb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0109ed2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ed5:	0f b6 00             	movzbl (%eax),%eax
c0109ed8:	3c 2f                	cmp    $0x2f,%al
c0109eda:	7e 1b                	jle    c0109ef7 <strtol+0xcc>
c0109edc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109edf:	0f b6 00             	movzbl (%eax),%eax
c0109ee2:	3c 39                	cmp    $0x39,%al
c0109ee4:	7f 11                	jg     c0109ef7 <strtol+0xcc>
            dig = *s - '0';
c0109ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee9:	0f b6 00             	movzbl (%eax),%eax
c0109eec:	0f be c0             	movsbl %al,%eax
c0109eef:	83 e8 30             	sub    $0x30,%eax
c0109ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ef5:	eb 48                	jmp    c0109f3f <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0109ef7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109efa:	0f b6 00             	movzbl (%eax),%eax
c0109efd:	3c 60                	cmp    $0x60,%al
c0109eff:	7e 1b                	jle    c0109f1c <strtol+0xf1>
c0109f01:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f04:	0f b6 00             	movzbl (%eax),%eax
c0109f07:	3c 7a                	cmp    $0x7a,%al
c0109f09:	7f 11                	jg     c0109f1c <strtol+0xf1>
            dig = *s - 'a' + 10;
c0109f0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f0e:	0f b6 00             	movzbl (%eax),%eax
c0109f11:	0f be c0             	movsbl %al,%eax
c0109f14:	83 e8 57             	sub    $0x57,%eax
c0109f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f1a:	eb 23                	jmp    c0109f3f <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0109f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f1f:	0f b6 00             	movzbl (%eax),%eax
c0109f22:	3c 40                	cmp    $0x40,%al
c0109f24:	7e 3b                	jle    c0109f61 <strtol+0x136>
c0109f26:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f29:	0f b6 00             	movzbl (%eax),%eax
c0109f2c:	3c 5a                	cmp    $0x5a,%al
c0109f2e:	7f 31                	jg     c0109f61 <strtol+0x136>
            dig = *s - 'A' + 10;
c0109f30:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f33:	0f b6 00             	movzbl (%eax),%eax
c0109f36:	0f be c0             	movsbl %al,%eax
c0109f39:	83 e8 37             	sub    $0x37,%eax
c0109f3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0109f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f42:	3b 45 10             	cmp    0x10(%ebp),%eax
c0109f45:	7d 19                	jge    c0109f60 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0109f47:	ff 45 08             	incl   0x8(%ebp)
c0109f4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109f4d:	0f af 45 10          	imul   0x10(%ebp),%eax
c0109f51:	89 c2                	mov    %eax,%edx
c0109f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f56:	01 d0                	add    %edx,%eax
c0109f58:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0109f5b:	e9 72 ff ff ff       	jmp    c0109ed2 <strtol+0xa7>
            break;
c0109f60:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0109f61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109f65:	74 08                	je     c0109f6f <strtol+0x144>
        *endptr = (char *) s;
c0109f67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f6a:	8b 55 08             	mov    0x8(%ebp),%edx
c0109f6d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0109f6f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109f73:	74 07                	je     c0109f7c <strtol+0x151>
c0109f75:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109f78:	f7 d8                	neg    %eax
c0109f7a:	eb 03                	jmp    c0109f7f <strtol+0x154>
c0109f7c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0109f7f:	89 ec                	mov    %ebp,%esp
c0109f81:	5d                   	pop    %ebp
c0109f82:	c3                   	ret    

c0109f83 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0109f83:	55                   	push   %ebp
c0109f84:	89 e5                	mov    %esp,%ebp
c0109f86:	83 ec 28             	sub    $0x28,%esp
c0109f89:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0109f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f8f:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0109f92:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0109f96:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f99:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0109f9c:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0109f9f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0109fa5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109fa8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0109fac:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109faf:	89 d7                	mov    %edx,%edi
c0109fb1:	f3 aa                	rep stos %al,%es:(%edi)
c0109fb3:	89 fa                	mov    %edi,%edx
c0109fb5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109fb8:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0109fbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109fbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0109fc1:	89 ec                	mov    %ebp,%esp
c0109fc3:	5d                   	pop    %ebp
c0109fc4:	c3                   	ret    

c0109fc5 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0109fc5:	55                   	push   %ebp
c0109fc6:	89 e5                	mov    %esp,%ebp
c0109fc8:	57                   	push   %edi
c0109fc9:	56                   	push   %esi
c0109fca:	53                   	push   %ebx
c0109fcb:	83 ec 30             	sub    $0x30,%esp
c0109fce:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109fd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109fda:	8b 45 10             	mov    0x10(%ebp),%eax
c0109fdd:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fe3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0109fe6:	73 42                	jae    c010a02a <memmove+0x65>
c0109fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109feb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ff1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109ff4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ff7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109ffa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109ffd:	c1 e8 02             	shr    $0x2,%eax
c010a000:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010a002:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a005:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a008:	89 d7                	mov    %edx,%edi
c010a00a:	89 c6                	mov    %eax,%esi
c010a00c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a00e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010a011:	83 e1 03             	and    $0x3,%ecx
c010a014:	74 02                	je     c010a018 <memmove+0x53>
c010a016:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a018:	89 f0                	mov    %esi,%eax
c010a01a:	89 fa                	mov    %edi,%edx
c010a01c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010a01f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a022:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010a025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010a028:	eb 36                	jmp    c010a060 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010a02a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a02d:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a030:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a033:	01 c2                	add    %eax,%edx
c010a035:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a038:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010a03b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a03e:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010a041:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a044:	89 c1                	mov    %eax,%ecx
c010a046:	89 d8                	mov    %ebx,%eax
c010a048:	89 d6                	mov    %edx,%esi
c010a04a:	89 c7                	mov    %eax,%edi
c010a04c:	fd                   	std    
c010a04d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a04f:	fc                   	cld    
c010a050:	89 f8                	mov    %edi,%eax
c010a052:	89 f2                	mov    %esi,%edx
c010a054:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010a057:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010a05a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010a05d:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010a060:	83 c4 30             	add    $0x30,%esp
c010a063:	5b                   	pop    %ebx
c010a064:	5e                   	pop    %esi
c010a065:	5f                   	pop    %edi
c010a066:	5d                   	pop    %ebp
c010a067:	c3                   	ret    

c010a068 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010a068:	55                   	push   %ebp
c010a069:	89 e5                	mov    %esp,%ebp
c010a06b:	57                   	push   %edi
c010a06c:	56                   	push   %esi
c010a06d:	83 ec 20             	sub    $0x20,%esp
c010a070:	8b 45 08             	mov    0x8(%ebp),%eax
c010a073:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a076:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a079:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a07c:	8b 45 10             	mov    0x10(%ebp),%eax
c010a07f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a082:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a085:	c1 e8 02             	shr    $0x2,%eax
c010a088:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010a08a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a08d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a090:	89 d7                	mov    %edx,%edi
c010a092:	89 c6                	mov    %eax,%esi
c010a094:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a096:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010a099:	83 e1 03             	and    $0x3,%ecx
c010a09c:	74 02                	je     c010a0a0 <memcpy+0x38>
c010a09e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a0a0:	89 f0                	mov    %esi,%eax
c010a0a2:	89 fa                	mov    %edi,%edx
c010a0a4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010a0a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a0aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010a0ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010a0b0:	83 c4 20             	add    $0x20,%esp
c010a0b3:	5e                   	pop    %esi
c010a0b4:	5f                   	pop    %edi
c010a0b5:	5d                   	pop    %ebp
c010a0b6:	c3                   	ret    

c010a0b7 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010a0b7:	55                   	push   %ebp
c010a0b8:	89 e5                	mov    %esp,%ebp
c010a0ba:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010a0bd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010a0c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a0c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010a0c9:	eb 2e                	jmp    c010a0f9 <memcmp+0x42>
        if (*s1 != *s2) {
c010a0cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a0ce:	0f b6 10             	movzbl (%eax),%edx
c010a0d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a0d4:	0f b6 00             	movzbl (%eax),%eax
c010a0d7:	38 c2                	cmp    %al,%dl
c010a0d9:	74 18                	je     c010a0f3 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010a0db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a0de:	0f b6 00             	movzbl (%eax),%eax
c010a0e1:	0f b6 d0             	movzbl %al,%edx
c010a0e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a0e7:	0f b6 00             	movzbl (%eax),%eax
c010a0ea:	0f b6 c8             	movzbl %al,%ecx
c010a0ed:	89 d0                	mov    %edx,%eax
c010a0ef:	29 c8                	sub    %ecx,%eax
c010a0f1:	eb 18                	jmp    c010a10b <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010a0f3:	ff 45 fc             	incl   -0x4(%ebp)
c010a0f6:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010a0f9:	8b 45 10             	mov    0x10(%ebp),%eax
c010a0fc:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a0ff:	89 55 10             	mov    %edx,0x10(%ebp)
c010a102:	85 c0                	test   %eax,%eax
c010a104:	75 c5                	jne    c010a0cb <memcmp+0x14>
    }
    return 0;
c010a106:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a10b:	89 ec                	mov    %ebp,%esp
c010a10d:	5d                   	pop    %ebp
c010a10e:	c3                   	ret    
