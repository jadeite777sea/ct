
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
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
c010003c:	b8 2c cf 11 c0       	mov    $0xc011cf2c,%eax
c0100041:	2d 00 c0 11 c0       	sub    $0xc011c000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c0100059:	e8 06 60 00 00       	call   c0106064 <memset>

    cons_init();                // init the console
c010005e:	e8 0e 16 00 00       	call   c0101671 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 00 62 10 c0 	movl   $0xc0106200,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 1c 62 10 c0 	movl   $0xc010621c,(%esp)
c0100078:	e8 d9 02 00 00       	call   c0100356 <cprintf>

    print_kerninfo();
c010007d:	e8 f7 07 00 00       	call   c0100879 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 90 00 00 00       	call   c0100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 eb 44 00 00       	call   c0104577 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 61 17 00 00       	call   c01017f2 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 e8 18 00 00       	call   c010197e <idt_init>

    clock_init();               // init clock interrupt
c0100096:	e8 35 0d 00 00       	call   c0100dd0 <clock_init>
    intr_enable();              // enable irq interrupt
c010009b:	e8 b0 16 00 00       	call   c0101750 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a0:	eb fe                	jmp    c01000a0 <kern_init+0x6a>

c01000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a2:	55                   	push   %ebp
c01000a3:	89 e5                	mov    %esp,%ebp
c01000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000af:	00 
c01000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000b7:	00 
c01000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000bf:	e8 27 0c 00 00       	call   c0100ceb <mon_backtrace>
}
c01000c4:	90                   	nop
c01000c5:	89 ec                	mov    %ebp,%esp
c01000c7:	5d                   	pop    %ebp
c01000c8:	c3                   	ret    

c01000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000c9:	55                   	push   %ebp
c01000ca:	89 e5                	mov    %esp,%ebp
c01000cc:	83 ec 18             	sub    $0x18,%esp
c01000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b0 ff ff ff       	call   c01000a2 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f6:	89 ec                	mov    %ebp,%esp
c01000f8:	5d                   	pop    %ebp
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100100:	8b 45 10             	mov    0x10(%ebp),%eax
c0100103:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100107:	8b 45 08             	mov    0x8(%ebp),%eax
c010010a:	89 04 24             	mov    %eax,(%esp)
c010010d:	e8 b7 ff ff ff       	call   c01000c9 <grade_backtrace1>
}
c0100112:	90                   	nop
c0100113:	89 ec                	mov    %ebp,%esp
c0100115:	5d                   	pop    %ebp
c0100116:	c3                   	ret    

c0100117 <grade_backtrace>:

void
grade_backtrace(void) {
c0100117:	55                   	push   %ebp
c0100118:	89 e5                	mov    %esp,%ebp
c010011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011d:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100129:	ff 
c010012a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100135:	e8 c0 ff ff ff       	call   c01000fa <grade_backtrace0>
}
c010013a:	90                   	nop
c010013b:	89 ec                	mov    %ebp,%esp
c010013d:	5d                   	pop    %ebp
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 21 62 10 c0 	movl   $0xc0106221,(%esp)
c010016e:	e8 e3 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 2f 62 10 c0 	movl   $0xc010622f,(%esp)
c010018d:	e8 c4 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 3d 62 10 c0 	movl   $0xc010623d,(%esp)
c01001ac:	e8 a5 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 4b 62 10 c0 	movl   $0xc010624b,(%esp)
c01001cb:	e8 86 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 59 62 10 c0 	movl   $0xc0106259,(%esp)
c01001ea:	e8 67 01 00 00       	call   c0100356 <cprintf>
    round ++;
c01001ef:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c01001fa:	90                   	nop
c01001fb:	89 ec                	mov    %ebp,%esp
c01001fd:	5d                   	pop    %ebp
c01001fe:	c3                   	ret    

c01001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ff:	55                   	push   %ebp
c0100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100202:	90                   	nop
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100208:	90                   	nop
c0100209:	5d                   	pop    %ebp
c010020a:	c3                   	ret    

c010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
c010020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100211:	e8 29 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100216:	c7 04 24 68 62 10 c0 	movl   $0xc0106268,(%esp)
c010021d:	e8 34 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_user();
c0100222:	e8 d8 ff ff ff       	call   c01001ff <lab1_switch_to_user>
    lab1_print_cur_status();
c0100227:	e8 13 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010022c:	c7 04 24 88 62 10 c0 	movl   $0xc0106288,(%esp)
c0100233:	e8 1e 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_kernel();
c0100238:	e8 c8 ff ff ff       	call   c0100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010023d:	e8 fd fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c0100242:	90                   	nop
c0100243:	89 ec                	mov    %ebp,%esp
c0100245:	5d                   	pop    %ebp
c0100246:	c3                   	ret    

c0100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100247:	55                   	push   %ebp
c0100248:	89 e5                	mov    %esp,%ebp
c010024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100251:	74 13                	je     c0100266 <readline+0x1f>
        cprintf("%s", prompt);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025a:	c7 04 24 a7 62 10 c0 	movl   $0xc01062a7,(%esp)
c0100261:	e8 f0 00 00 00       	call   c0100356 <cprintf>
    }
    int i = 0, c;
c0100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010026d:	e8 73 01 00 00       	call   c01003e5 <getchar>
c0100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100279:	79 07                	jns    c0100282 <readline+0x3b>
            return NULL;
c010027b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100280:	eb 78                	jmp    c01002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100286:	7e 28                	jle    c01002b0 <readline+0x69>
c0100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010028f:	7f 1f                	jg     c01002b0 <readline+0x69>
            cputchar(c);
c0100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100294:	89 04 24             	mov    %eax,(%esp)
c0100297:	e8 e2 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010029f:	8d 50 01             	lea    0x1(%eax),%edx
c01002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a8:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
c01002ae:	eb 45                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b4:	75 16                	jne    c01002cc <readline+0x85>
c01002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ba:	7e 10                	jle    c01002cc <readline+0x85>
            cputchar(c);
c01002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 b7 00 00 00       	call   c010037e <cputchar>
            i --;
c01002c7:	ff 4d f4             	decl   -0xc(%ebp)
c01002ca:	eb 29                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d0:	74 06                	je     c01002d8 <readline+0x91>
c01002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002d6:	75 95                	jne    c010026d <readline+0x26>
            cputchar(c);
c01002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 9b 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e6:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c01002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002ee:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
c01002f3:	eb 05                	jmp    c01002fa <readline+0xb3>
        c = getchar();
c01002f5:	e9 73 ff ff ff       	jmp    c010026d <readline+0x26>
        }
    }
}
c01002fa:	89 ec                	mov    %ebp,%esp
c01002fc:	5d                   	pop    %ebp
c01002fd:	c3                   	ret    

c01002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100304:	8b 45 08             	mov    0x8(%ebp),%eax
c0100307:	89 04 24             	mov    %eax,(%esp)
c010030a:	e8 91 13 00 00       	call   c01016a0 <cons_putc>
    (*cnt) ++;
c010030f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100312:	8b 00                	mov    (%eax),%eax
c0100314:	8d 50 01             	lea    0x1(%eax),%edx
c0100317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031a:	89 10                	mov    %edx,(%eax)
}
c010031c:	90                   	nop
c010031d:	89 ec                	mov    %ebp,%esp
c010031f:	5d                   	pop    %ebp
c0100320:	c3                   	ret    

c0100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100321:	55                   	push   %ebp
c0100322:	89 e5                	mov    %esp,%ebp
c0100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100335:	8b 45 08             	mov    0x8(%ebp),%eax
c0100338:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100343:	c7 04 24 fe 02 10 c0 	movl   $0xc01002fe,(%esp)
c010034a:	e8 40 55 00 00       	call   c010588f <vprintfmt>
    return cnt;
c010034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100352:	89 ec                	mov    %ebp,%esp
c0100354:	5d                   	pop    %ebp
c0100355:	c3                   	ret    

c0100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100356:	55                   	push   %ebp
c0100357:	89 e5                	mov    %esp,%ebp
c0100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035c:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100365:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100369:	8b 45 08             	mov    0x8(%ebp),%eax
c010036c:	89 04 24             	mov    %eax,(%esp)
c010036f:	e8 ad ff ff ff       	call   c0100321 <vcprintf>
c0100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	89 ec                	mov    %ebp,%esp
c010037c:	5d                   	pop    %ebp
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 11 13 00 00       	call   c01016a0 <cons_putc>
}
c010038f:	90                   	nop
c0100390:	89 ec                	mov    %ebp,%esp
c0100392:	5d                   	pop    %ebp
c0100393:	c3                   	ret    

c0100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100394:	55                   	push   %ebp
c0100395:	89 e5                	mov    %esp,%ebp
c0100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a1:	eb 13                	jmp    c01003b6 <cputs+0x22>
        cputch(c, &cnt);
c01003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ae:	89 04 24             	mov    %eax,(%esp)
c01003b1:	e8 48 ff ff ff       	call   c01002fe <cputch>
    while ((c = *str ++) != '\0') {
c01003b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b9:	8d 50 01             	lea    0x1(%eax),%edx
c01003bc:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bf:	0f b6 00             	movzbl (%eax),%eax
c01003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c9:	75 d8                	jne    c01003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d9:	e8 20 ff ff ff       	call   c01002fe <cputch>
    return cnt;
c01003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e1:	89 ec                	mov    %ebp,%esp
c01003e3:	5d                   	pop    %ebp
c01003e4:	c3                   	ret    

c01003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e5:	55                   	push   %ebp
c01003e6:	89 e5                	mov    %esp,%ebp
c01003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003eb:	90                   	nop
c01003ec:	e8 ee 12 00 00       	call   c01016df <cons_getc>
c01003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f8:	74 f2                	je     c01003ec <getchar+0x7>
        /* do nothing */;
    return c;
c01003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003fd:	89 ec                	mov    %ebp,%esp
c01003ff:	5d                   	pop    %ebp
c0100400:	c3                   	ret    

c0100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100401:	55                   	push   %ebp
c0100402:	89 e5                	mov    %esp,%ebp
c0100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010040f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100412:	8b 00                	mov    (%eax),%eax
c0100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010041e:	e9 ca 00 00 00       	jmp    c01004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100429:	01 d0                	add    %edx,%eax
c010042b:	89 c2                	mov    %eax,%edx
c010042d:	c1 ea 1f             	shr    $0x1f,%edx
c0100430:	01 d0                	add    %edx,%eax
c0100432:	d1 f8                	sar    %eax
c0100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043d:	eb 03                	jmp    c0100442 <stab_binsearch+0x41>
            m --;
c010043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100448:	7c 1f                	jl     c0100469 <stab_binsearch+0x68>
c010044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044d:	89 d0                	mov    %edx,%eax
c010044f:	01 c0                	add    %eax,%eax
c0100451:	01 d0                	add    %edx,%eax
c0100453:	c1 e0 02             	shl    $0x2,%eax
c0100456:	89 c2                	mov    %eax,%edx
c0100458:	8b 45 08             	mov    0x8(%ebp),%eax
c010045b:	01 d0                	add    %edx,%eax
c010045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100461:	0f b6 c0             	movzbl %al,%eax
c0100464:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100467:	75 d6                	jne    c010043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046f:	7d 09                	jge    c010047a <stab_binsearch+0x79>
            l = true_m + 1;
c0100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100474:	40                   	inc    %eax
c0100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100478:	eb 73                	jmp    c01004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100484:	89 d0                	mov    %edx,%eax
c0100486:	01 c0                	add    %eax,%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	c1 e0 02             	shl    $0x2,%eax
c010048d:	89 c2                	mov    %eax,%edx
c010048f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100492:	01 d0                	add    %edx,%eax
c0100494:	8b 40 08             	mov    0x8(%eax),%eax
c0100497:	39 45 18             	cmp    %eax,0x18(%ebp)
c010049a:	76 11                	jbe    c01004ad <stab_binsearch+0xac>
            *region_left = m;
c010049c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a7:	40                   	inc    %eax
c01004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ab:	eb 40                	jmp    c01004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b0:	89 d0                	mov    %edx,%eax
c01004b2:	01 c0                	add    %eax,%eax
c01004b4:	01 d0                	add    %edx,%eax
c01004b6:	c1 e0 02             	shl    $0x2,%eax
c01004b9:	89 c2                	mov    %eax,%edx
c01004bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01004be:	01 d0                	add    %edx,%eax
c01004c0:	8b 40 08             	mov    0x8(%eax),%eax
c01004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004c6:	73 14                	jae    c01004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	48                   	dec    %eax
c01004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004da:	eb 11                	jmp    c01004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e2:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 2a ff ff ff    	jle    c0100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010050c:	eb 3e                	jmp    c010054c <stab_binsearch+0x14b>
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 03                	jmp    c010051b <stab_binsearch+0x11a>
c0100518:	ff 4d fc             	decl   -0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100523:	7e 1f                	jle    c0100544 <stab_binsearch+0x143>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100542:	75 d4                	jne    c0100518 <stab_binsearch+0x117>
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
}
c010054c:	90                   	nop
c010054d:	89 ec                	mov    %ebp,%esp
c010054f:	5d                   	pop    %ebp
c0100550:	c3                   	ret    

c0100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100551:	55                   	push   %ebp
c0100552:	89 e5                	mov    %esp,%ebp
c0100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055a:	c7 00 ac 62 10 c0    	movl   $0xc01062ac,(%eax)
    info->eip_line = 0;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	c7 40 08 ac 62 10 c0 	movl   $0xc01062ac,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100581:	8b 55 08             	mov    0x8(%ebp),%edx
c0100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100587:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100591:	c7 45 f4 48 75 10 c0 	movl   $0xc0107548,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100598:	c7 45 f0 6c 2f 11 c0 	movl   $0xc0112f6c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059f:	c7 45 ec 6d 2f 11 c0 	movl   $0xc0112f6d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a6:	c7 45 e8 47 65 11 c0 	movl   $0xc0116547,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b3:	76 0b                	jbe    c01005c0 <debuginfo_eip+0x6f>
c01005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b8:	48                   	dec    %eax
c01005b9:	0f b6 00             	movzbl (%eax),%eax
c01005bc:	84 c0                	test   %al,%al
c01005be:	74 0a                	je     c01005ca <debuginfo_eip+0x79>
        return -1;
c01005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c5:	e9 ab 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005d7:	c1 f8 02             	sar    $0x2,%eax
c01005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e0:	48                   	dec    %eax
c01005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f2:	00 
c01005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100604:	89 04 24             	mov    %eax,(%esp)
c0100607:	e8 f5 fd ff ff       	call   c0100401 <stab_binsearch>
    if (lfile == 0)
c010060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060f:	85 c0                	test   %eax,%eax
c0100611:	75 0a                	jne    c010061d <debuginfo_eip+0xcc>
        return -1;
c0100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100618:	e9 58 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100629:	8b 45 08             	mov    0x8(%ebp),%eax
c010062c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100637:	00 
c0100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	89 04 24             	mov    %eax,(%esp)
c010064c:	e8 b0 fd ff ff       	call   c0100401 <stab_binsearch>

    if (lfun <= rfun) {
c0100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100657:	39 c2                	cmp    %eax,%edx
c0100659:	7f 78                	jg     c01006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065e:	89 c2                	mov    %eax,%edx
c0100660:	89 d0                	mov    %edx,%eax
c0100662:	01 c0                	add    %eax,%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	c1 e0 02             	shl    $0x2,%eax
c0100669:	89 c2                	mov    %eax,%edx
c010066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066e:	01 d0                	add    %edx,%eax
c0100670:	8b 10                	mov    (%eax),%edx
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100678:	39 c2                	cmp    %eax,%edx
c010067a:	73 22                	jae    c010069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010067f:	89 c2                	mov    %eax,%edx
c0100681:	89 d0                	mov    %edx,%eax
c0100683:	01 c0                	add    %eax,%eax
c0100685:	01 d0                	add    %edx,%eax
c0100687:	c1 e0 02             	shl    $0x2,%eax
c010068a:	89 c2                	mov    %eax,%edx
c010068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068f:	01 d0                	add    %edx,%eax
c0100691:	8b 10                	mov    (%eax),%edx
c0100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100696:	01 c2                	add    %eax,%edx
c0100698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	89 d0                	mov    %edx,%eax
c01006a5:	01 c0                	add    %eax,%eax
c01006a7:	01 d0                	add    %edx,%eax
c01006a9:	c1 e0 02             	shl    $0x2,%eax
c01006ac:	89 c2                	mov    %eax,%edx
c01006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	8b 50 08             	mov    0x8(%eax),%edx
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006bf:	8b 40 10             	mov    0x10(%eax),%eax
c01006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d1:	eb 15                	jmp    c01006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006eb:	8b 40 08             	mov    0x8(%eax),%eax
c01006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006f5:	00 
c01006f6:	89 04 24             	mov    %eax,(%esp)
c01006f9:	e8 de 57 00 00       	call   c0105edc <strfind>
c01006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100701:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100704:	29 c8                	sub    %ecx,%eax
c0100706:	89 c2                	mov    %eax,%edx
c0100708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010070e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100711:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010071c:	00 
c010071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100720:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	89 04 24             	mov    %eax,(%esp)
c0100731:	e8 cb fc ff ff       	call   c0100401 <stab_binsearch>
    if (lline <= rline) {
c0100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073c:	39 c2                	cmp    %eax,%edx
c010073e:	7f 23                	jg     c0100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	89 d0                	mov    %edx,%eax
c0100747:	01 c0                	add    %eax,%eax
c0100749:	01 d0                	add    %edx,%eax
c010074b:	c1 e0 02             	shl    $0x2,%eax
c010074e:	89 c2                	mov    %eax,%edx
c0100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100759:	89 c2                	mov    %eax,%edx
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100761:	eb 11                	jmp    c0100774 <debuginfo_eip+0x223>
        return -1;
c0100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100768:	e9 08 01 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100770:	48                   	dec    %eax
c0100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010077a:	39 c2                	cmp    %eax,%edx
c010077c:	7c 56                	jl     c01007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100781:	89 c2                	mov    %eax,%edx
c0100783:	89 d0                	mov    %edx,%eax
c0100785:	01 c0                	add    %eax,%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	c1 e0 02             	shl    $0x2,%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100791:	01 d0                	add    %edx,%eax
c0100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100797:	3c 84                	cmp    $0x84,%al
c0100799:	74 39                	je     c01007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b4:	3c 64                	cmp    $0x64,%al
c01007b6:	75 b5                	jne    c010076d <debuginfo_eip+0x21c>
c01007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	89 d0                	mov    %edx,%eax
c01007bf:	01 c0                	add    %eax,%eax
c01007c1:	01 d0                	add    %edx,%eax
c01007c3:	c1 e0 02             	shl    $0x2,%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cb:	01 d0                	add    %edx,%eax
c01007cd:	8b 40 08             	mov    0x8(%eax),%eax
c01007d0:	85 c0                	test   %eax,%eax
c01007d2:	74 99                	je     c010076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007da:	39 c2                	cmp    %eax,%edx
c01007dc:	7c 42                	jl     c0100820 <debuginfo_eip+0x2cf>
c01007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e1:	89 c2                	mov    %eax,%edx
c01007e3:	89 d0                	mov    %edx,%eax
c01007e5:	01 c0                	add    %eax,%eax
c01007e7:	01 d0                	add    %edx,%eax
c01007e9:	c1 e0 02             	shl    $0x2,%eax
c01007ec:	89 c2                	mov    %eax,%edx
c01007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f1:	01 d0                	add    %edx,%eax
c01007f3:	8b 10                	mov    (%eax),%edx
c01007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01007fb:	39 c2                	cmp    %eax,%edx
c01007fd:	73 21                	jae    c0100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	89 d0                	mov    %edx,%eax
c0100806:	01 c0                	add    %eax,%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	c1 e0 02             	shl    $0x2,%eax
c010080d:	89 c2                	mov    %eax,%edx
c010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100812:	01 d0                	add    %edx,%eax
c0100814:	8b 10                	mov    (%eax),%edx
c0100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100819:	01 c2                	add    %eax,%edx
c010081b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100826:	39 c2                	cmp    %eax,%edx
c0100828:	7d 46                	jge    c0100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082d:	40                   	inc    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100831:	eb 16                	jmp    c0100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	8b 40 14             	mov    0x14(%eax),%eax
c0100839:	8d 50 01             	lea    0x1(%eax),%edx
c010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100845:	40                   	inc    %eax
c0100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010084f:	39 c2                	cmp    %eax,%edx
c0100851:	7d 1d                	jge    c0100870 <debuginfo_eip+0x31f>
c0100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	89 d0                	mov    %edx,%eax
c010085a:	01 c0                	add    %eax,%eax
c010085c:	01 d0                	add    %edx,%eax
c010085e:	c1 e0 02             	shl    $0x2,%eax
c0100861:	89 c2                	mov    %eax,%edx
c0100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086c:	3c a0                	cmp    $0xa0,%al
c010086e:	74 c3                	je     c0100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100875:	89 ec                	mov    %ebp,%esp
c0100877:	5d                   	pop    %ebp
c0100878:	c3                   	ret    

c0100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100879:	55                   	push   %ebp
c010087a:	89 e5                	mov    %esp,%ebp
c010087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010087f:	c7 04 24 b6 62 10 c0 	movl   $0xc01062b6,(%esp)
c0100886:	e8 cb fa ff ff       	call   c0100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088b:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100892:	c0 
c0100893:	c7 04 24 cf 62 10 c0 	movl   $0xc01062cf,(%esp)
c010089a:	e8 b7 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010089f:	c7 44 24 04 f0 61 10 	movl   $0xc01061f0,0x4(%esp)
c01008a6:	c0 
c01008a7:	c7 04 24 e7 62 10 c0 	movl   $0xc01062e7,(%esp)
c01008ae:	e8 a3 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b3:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c01008ba:	c0 
c01008bb:	c7 04 24 ff 62 10 c0 	movl   $0xc01062ff,(%esp)
c01008c2:	e8 8f fa ff ff       	call   c0100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008c7:	c7 44 24 04 2c cf 11 	movl   $0xc011cf2c,0x4(%esp)
c01008ce:	c0 
c01008cf:	c7 04 24 17 63 10 c0 	movl   $0xc0106317,(%esp)
c01008d6:	e8 7b fa ff ff       	call   c0100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008db:	b8 2c cf 11 c0       	mov    $0xc011cf2c,%eax
c01008e0:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f0:	85 c0                	test   %eax,%eax
c01008f2:	0f 48 c2             	cmovs  %edx,%eax
c01008f5:	c1 f8 0a             	sar    $0xa,%eax
c01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008fc:	c7 04 24 30 63 10 c0 	movl   $0xc0106330,(%esp)
c0100903:	e8 4e fa ff ff       	call   c0100356 <cprintf>
}
c0100908:	90                   	nop
c0100909:	89 ec                	mov    %ebp,%esp
c010090b:	5d                   	pop    %ebp
c010090c:	c3                   	ret    

c010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010090d:	55                   	push   %ebp
c010090e:	89 e5                	mov    %esp,%ebp
c0100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100920:	89 04 24             	mov    %eax,(%esp)
c0100923:	e8 29 fc ff ff       	call   c0100551 <debuginfo_eip>
c0100928:	85 c0                	test   %eax,%eax
c010092a:	74 15                	je     c0100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100933:	c7 04 24 5a 63 10 c0 	movl   $0xc010635a,(%esp)
c010093a:	e8 17 fa ff ff       	call   c0100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010093f:	eb 6c                	jmp    c01009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100948:	eb 1b                	jmp    c0100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100950:	01 d0                	add    %edx,%eax
c0100952:	0f b6 10             	movzbl (%eax),%edx
c0100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095e:	01 c8                	add    %ecx,%eax
c0100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100962:	ff 45 f4             	incl   -0xc(%ebp)
c0100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010096b:	7c dd                	jl     c010094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100976:	01 d0                	add    %edx,%eax
c0100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010097e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100981:	29 d0                	sub    %edx,%eax
c0100983:	89 c1                	mov    %eax,%ecx
c0100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100999:	89 54 24 08          	mov    %edx,0x8(%esp)
c010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a1:	c7 04 24 76 63 10 c0 	movl   $0xc0106376,(%esp)
c01009a8:	e8 a9 f9 ff ff       	call   c0100356 <cprintf>
}
c01009ad:	90                   	nop
c01009ae:	89 ec                	mov    %ebp,%esp
c01009b0:	5d                   	pop    %ebp
c01009b1:	c3                   	ret    

c01009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b2:	55                   	push   %ebp
c01009b3:	89 e5                	mov    %esp,%ebp
c01009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009b8:	8b 45 04             	mov    0x4(%ebp),%eax
c01009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c1:	89 ec                	mov    %ebp,%esp
c01009c3:	5d                   	pop    %ebp
c01009c4:	c3                   	ret    

c01009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cb:	89 e8                	mov    %ebp,%eax
c01009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
c01009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
c01009d6:	e8 d7 ff ff ff       	call   c01009b2 <read_eip>
c01009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i,j;
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
c01009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e5:	e9 a8 00 00 00       	jmp    c0100a92 <print_stackframe+0xcd>
      {
        cprintf("%08x",ebp);
c01009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f1:	c7 04 24 88 63 10 c0 	movl   $0xc0106388,(%esp)
c01009f8:	e8 59 f9 ff ff       	call   c0100356 <cprintf>
        cprintf(" ");
c01009fd:	c7 04 24 8d 63 10 c0 	movl   $0xc010638d,(%esp)
c0100a04:	e8 4d f9 ff ff       	call   c0100356 <cprintf>
        cprintf("%08x",eip);
c0100a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a10:	c7 04 24 88 63 10 c0 	movl   $0xc0106388,(%esp)
c0100a17:	e8 3a f9 ff ff       	call   c0100356 <cprintf>
        uint32_t* a=(uint32_t*)ebp+2;
c0100a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a1f:	83 c0 08             	add    $0x8,%eax
c0100a22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j=0;j<4;j++)
c0100a25:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a2c:	eb 30                	jmp    c0100a5e <print_stackframe+0x99>
        {
            cprintf(" ");
c0100a2e:	c7 04 24 8d 63 10 c0 	movl   $0xc010638d,(%esp)
c0100a35:	e8 1c f9 ff ff       	call   c0100356 <cprintf>
            cprintf("%08x",a[j]);
c0100a3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a47:	01 d0                	add    %edx,%eax
c0100a49:	8b 00                	mov    (%eax),%eax
c0100a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4f:	c7 04 24 88 63 10 c0 	movl   $0xc0106388,(%esp)
c0100a56:	e8 fb f8 ff ff       	call   c0100356 <cprintf>
        for(j=0;j<4;j++)
c0100a5b:	ff 45 e8             	incl   -0x18(%ebp)
c0100a5e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a62:	7e ca                	jle    c0100a2e <print_stackframe+0x69>
        }
        cprintf("\n");
c0100a64:	c7 04 24 8f 63 10 c0 	movl   $0xc010638f,(%esp)
c0100a6b:	e8 e6 f8 ff ff       	call   c0100356 <cprintf>

        print_debuginfo(eip-1);
c0100a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a73:	48                   	dec    %eax
c0100a74:	89 04 24             	mov    %eax,(%esp)
c0100a77:	e8 91 fe ff ff       	call   c010090d <print_debuginfo>

        eip=((uint32_t*)ebp)[1];
c0100a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7f:	83 c0 04             	add    $0x4,%eax
c0100a82:	8b 00                	mov    (%eax),%eax
c0100a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp=((uint32_t*)ebp)[0];
c0100a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a8a:	8b 00                	mov    (%eax),%eax
c0100a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
c0100a8f:	ff 45 ec             	incl   -0x14(%ebp)
c0100a92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a96:	74 0a                	je     c0100aa2 <print_stackframe+0xdd>
c0100a98:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a9c:	0f 8e 48 ff ff ff    	jle    c01009ea <print_stackframe+0x25>


      }
}
c0100aa2:	90                   	nop
c0100aa3:	89 ec                	mov    %ebp,%esp
c0100aa5:	5d                   	pop    %ebp
c0100aa6:	c3                   	ret    

c0100aa7 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100aa7:	55                   	push   %ebp
c0100aa8:	89 e5                	mov    %esp,%ebp
c0100aaa:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100aad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ab4:	eb 0c                	jmp    c0100ac2 <parse+0x1b>
            *buf ++ = '\0';
c0100ab6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab9:	8d 50 01             	lea    0x1(%eax),%edx
c0100abc:	89 55 08             	mov    %edx,0x8(%ebp)
c0100abf:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ac2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac5:	0f b6 00             	movzbl (%eax),%eax
c0100ac8:	84 c0                	test   %al,%al
c0100aca:	74 1d                	je     c0100ae9 <parse+0x42>
c0100acc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100acf:	0f b6 00             	movzbl (%eax),%eax
c0100ad2:	0f be c0             	movsbl %al,%eax
c0100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad9:	c7 04 24 14 64 10 c0 	movl   $0xc0106414,(%esp)
c0100ae0:	e8 c3 53 00 00       	call   c0105ea8 <strchr>
c0100ae5:	85 c0                	test   %eax,%eax
c0100ae7:	75 cd                	jne    c0100ab6 <parse+0xf>
        }
        if (*buf == '\0') {
c0100ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aec:	0f b6 00             	movzbl (%eax),%eax
c0100aef:	84 c0                	test   %al,%al
c0100af1:	74 65                	je     c0100b58 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100af3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100af7:	75 14                	jne    c0100b0d <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100af9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b00:	00 
c0100b01:	c7 04 24 19 64 10 c0 	movl   $0xc0106419,(%esp)
c0100b08:	e8 49 f8 ff ff       	call   c0100356 <cprintf>
        }
        argv[argc ++] = buf;
c0100b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b10:	8d 50 01             	lea    0x1(%eax),%edx
c0100b13:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b20:	01 c2                	add    %eax,%edx
c0100b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b25:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b27:	eb 03                	jmp    c0100b2c <parse+0x85>
            buf ++;
c0100b29:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b2f:	0f b6 00             	movzbl (%eax),%eax
c0100b32:	84 c0                	test   %al,%al
c0100b34:	74 8c                	je     c0100ac2 <parse+0x1b>
c0100b36:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b39:	0f b6 00             	movzbl (%eax),%eax
c0100b3c:	0f be c0             	movsbl %al,%eax
c0100b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b43:	c7 04 24 14 64 10 c0 	movl   $0xc0106414,(%esp)
c0100b4a:	e8 59 53 00 00       	call   c0105ea8 <strchr>
c0100b4f:	85 c0                	test   %eax,%eax
c0100b51:	74 d6                	je     c0100b29 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b53:	e9 6a ff ff ff       	jmp    c0100ac2 <parse+0x1b>
            break;
c0100b58:	90                   	nop
        }
    }
    return argc;
c0100b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b5c:	89 ec                	mov    %ebp,%esp
c0100b5e:	5d                   	pop    %ebp
c0100b5f:	c3                   	ret    

c0100b60 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b60:	55                   	push   %ebp
c0100b61:	89 e5                	mov    %esp,%ebp
c0100b63:	83 ec 68             	sub    $0x68,%esp
c0100b66:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b69:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b70:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b73:	89 04 24             	mov    %eax,(%esp)
c0100b76:	e8 2c ff ff ff       	call   c0100aa7 <parse>
c0100b7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b82:	75 0a                	jne    c0100b8e <runcmd+0x2e>
        return 0;
c0100b84:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b89:	e9 83 00 00 00       	jmp    c0100c11 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b95:	eb 5a                	jmp    c0100bf1 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b97:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100b9a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100b9d:	89 c8                	mov    %ecx,%eax
c0100b9f:	01 c0                	add    %eax,%eax
c0100ba1:	01 c8                	add    %ecx,%eax
c0100ba3:	c1 e0 02             	shl    $0x2,%eax
c0100ba6:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100bab:	8b 00                	mov    (%eax),%eax
c0100bad:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bb1:	89 04 24             	mov    %eax,(%esp)
c0100bb4:	e8 53 52 00 00       	call   c0105e0c <strcmp>
c0100bb9:	85 c0                	test   %eax,%eax
c0100bbb:	75 31                	jne    c0100bee <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bc0:	89 d0                	mov    %edx,%eax
c0100bc2:	01 c0                	add    %eax,%eax
c0100bc4:	01 d0                	add    %edx,%eax
c0100bc6:	c1 e0 02             	shl    $0x2,%eax
c0100bc9:	05 08 90 11 c0       	add    $0xc0119008,%eax
c0100bce:	8b 10                	mov    (%eax),%edx
c0100bd0:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bd3:	83 c0 04             	add    $0x4,%eax
c0100bd6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bd9:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100be3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be7:	89 1c 24             	mov    %ebx,(%esp)
c0100bea:	ff d2                	call   *%edx
c0100bec:	eb 23                	jmp    c0100c11 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bee:	ff 45 f4             	incl   -0xc(%ebp)
c0100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf4:	83 f8 02             	cmp    $0x2,%eax
c0100bf7:	76 9e                	jbe    c0100b97 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bf9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c00:	c7 04 24 37 64 10 c0 	movl   $0xc0106437,(%esp)
c0100c07:	e8 4a f7 ff ff       	call   c0100356 <cprintf>
    return 0;
c0100c0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c14:	89 ec                	mov    %ebp,%esp
c0100c16:	5d                   	pop    %ebp
c0100c17:	c3                   	ret    

c0100c18 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c18:	55                   	push   %ebp
c0100c19:	89 e5                	mov    %esp,%ebp
c0100c1b:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c1e:	c7 04 24 50 64 10 c0 	movl   $0xc0106450,(%esp)
c0100c25:	e8 2c f7 ff ff       	call   c0100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c2a:	c7 04 24 78 64 10 c0 	movl   $0xc0106478,(%esp)
c0100c31:	e8 20 f7 ff ff       	call   c0100356 <cprintf>

    if (tf != NULL) {
c0100c36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c3a:	74 0b                	je     c0100c47 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c3f:	89 04 24             	mov    %eax,(%esp)
c0100c42:	e8 f1 0e 00 00       	call   c0101b38 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c47:	c7 04 24 9d 64 10 c0 	movl   $0xc010649d,(%esp)
c0100c4e:	e8 f4 f5 ff ff       	call   c0100247 <readline>
c0100c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c5a:	74 eb                	je     c0100c47 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c66:	89 04 24             	mov    %eax,(%esp)
c0100c69:	e8 f2 fe ff ff       	call   c0100b60 <runcmd>
c0100c6e:	85 c0                	test   %eax,%eax
c0100c70:	78 02                	js     c0100c74 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c72:	eb d3                	jmp    c0100c47 <kmonitor+0x2f>
                break;
c0100c74:	90                   	nop
            }
        }
    }
}
c0100c75:	90                   	nop
c0100c76:	89 ec                	mov    %ebp,%esp
c0100c78:	5d                   	pop    %ebp
c0100c79:	c3                   	ret    

c0100c7a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c7a:	55                   	push   %ebp
c0100c7b:	89 e5                	mov    %esp,%ebp
c0100c7d:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c87:	eb 3d                	jmp    c0100cc6 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c8c:	89 d0                	mov    %edx,%eax
c0100c8e:	01 c0                	add    %eax,%eax
c0100c90:	01 d0                	add    %edx,%eax
c0100c92:	c1 e0 02             	shl    $0x2,%eax
c0100c95:	05 04 90 11 c0       	add    $0xc0119004,%eax
c0100c9a:	8b 10                	mov    (%eax),%edx
c0100c9c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c9f:	89 c8                	mov    %ecx,%eax
c0100ca1:	01 c0                	add    %eax,%eax
c0100ca3:	01 c8                	add    %ecx,%eax
c0100ca5:	c1 e0 02             	shl    $0x2,%eax
c0100ca8:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100cad:	8b 00                	mov    (%eax),%eax
c0100caf:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cb7:	c7 04 24 a1 64 10 c0 	movl   $0xc01064a1,(%esp)
c0100cbe:	e8 93 f6 ff ff       	call   c0100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cc3:	ff 45 f4             	incl   -0xc(%ebp)
c0100cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cc9:	83 f8 02             	cmp    $0x2,%eax
c0100ccc:	76 bb                	jbe    c0100c89 <mon_help+0xf>
    }
    return 0;
c0100cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd3:	89 ec                	mov    %ebp,%esp
c0100cd5:	5d                   	pop    %ebp
c0100cd6:	c3                   	ret    

c0100cd7 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cd7:	55                   	push   %ebp
c0100cd8:	89 e5                	mov    %esp,%ebp
c0100cda:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cdd:	e8 97 fb ff ff       	call   c0100879 <print_kerninfo>
    return 0;
c0100ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ce7:	89 ec                	mov    %ebp,%esp
c0100ce9:	5d                   	pop    %ebp
c0100cea:	c3                   	ret    

c0100ceb <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ceb:	55                   	push   %ebp
c0100cec:	89 e5                	mov    %esp,%ebp
c0100cee:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cf1:	e8 cf fc ff ff       	call   c01009c5 <print_stackframe>
    return 0;
c0100cf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cfb:	89 ec                	mov    %ebp,%esp
c0100cfd:	5d                   	pop    %ebp
c0100cfe:	c3                   	ret    

c0100cff <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cff:	55                   	push   %ebp
c0100d00:	89 e5                	mov    %esp,%ebp
c0100d02:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100d05:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c0100d0a:	85 c0                	test   %eax,%eax
c0100d0c:	75 5b                	jne    c0100d69 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100d0e:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c0100d15:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d18:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d21:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d25:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d2c:	c7 04 24 aa 64 10 c0 	movl   $0xc01064aa,(%esp)
c0100d33:	e8 1e f6 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d3f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d42:	89 04 24             	mov    %eax,(%esp)
c0100d45:	e8 d7 f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d4a:	c7 04 24 c6 64 10 c0 	movl   $0xc01064c6,(%esp)
c0100d51:	e8 00 f6 ff ff       	call   c0100356 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d56:	c7 04 24 c8 64 10 c0 	movl   $0xc01064c8,(%esp)
c0100d5d:	e8 f4 f5 ff ff       	call   c0100356 <cprintf>
    print_stackframe();
c0100d62:	e8 5e fc ff ff       	call   c01009c5 <print_stackframe>
c0100d67:	eb 01                	jmp    c0100d6a <__panic+0x6b>
        goto panic_dead;
c0100d69:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d6a:	e8 e9 09 00 00       	call   c0101758 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d76:	e8 9d fe ff ff       	call   c0100c18 <kmonitor>
c0100d7b:	eb f2                	jmp    c0100d6f <__panic+0x70>

c0100d7d <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d7d:	55                   	push   %ebp
c0100d7e:	89 e5                	mov    %esp,%ebp
c0100d80:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d83:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d8c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d90:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d97:	c7 04 24 da 64 10 c0 	movl   $0xc01064da,(%esp)
c0100d9e:	e8 b3 f5 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100da6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100daa:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dad:	89 04 24             	mov    %eax,(%esp)
c0100db0:	e8 6c f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100db5:	c7 04 24 c6 64 10 c0 	movl   $0xc01064c6,(%esp)
c0100dbc:	e8 95 f5 ff ff       	call   c0100356 <cprintf>
    va_end(ap);
}
c0100dc1:	90                   	nop
c0100dc2:	89 ec                	mov    %ebp,%esp
c0100dc4:	5d                   	pop    %ebp
c0100dc5:	c3                   	ret    

c0100dc6 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100dc6:	55                   	push   %ebp
c0100dc7:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100dc9:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c0100dce:	5d                   	pop    %ebp
c0100dcf:	c3                   	ret    

c0100dd0 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dd0:	55                   	push   %ebp
c0100dd1:	89 e5                	mov    %esp,%ebp
c0100dd3:	83 ec 28             	sub    $0x28,%esp
c0100dd6:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100ddc:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100de0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100de4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100de8:	ee                   	out    %al,(%dx)
}
c0100de9:	90                   	nop
c0100dea:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100df0:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100df4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100df8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dfc:	ee                   	out    %al,(%dx)
}
c0100dfd:	90                   	nop
c0100dfe:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e04:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e08:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e0c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e10:	ee                   	out    %al,(%dx)
}
c0100e11:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e12:	c7 05 24 c4 11 c0 00 	movl   $0x0,0xc011c424
c0100e19:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e1c:	c7 04 24 f8 64 10 c0 	movl   $0xc01064f8,(%esp)
c0100e23:	e8 2e f5 ff ff       	call   c0100356 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e2f:	e8 89 09 00 00       	call   c01017bd <pic_enable>
}
c0100e34:	90                   	nop
c0100e35:	89 ec                	mov    %ebp,%esp
c0100e37:	5d                   	pop    %ebp
c0100e38:	c3                   	ret    

c0100e39 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e39:	55                   	push   %ebp
c0100e3a:	89 e5                	mov    %esp,%ebp
c0100e3c:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e3f:	9c                   	pushf  
c0100e40:	58                   	pop    %eax
c0100e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e47:	25 00 02 00 00       	and    $0x200,%eax
c0100e4c:	85 c0                	test   %eax,%eax
c0100e4e:	74 0c                	je     c0100e5c <__intr_save+0x23>
        intr_disable();
c0100e50:	e8 03 09 00 00       	call   c0101758 <intr_disable>
        return 1;
c0100e55:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e5a:	eb 05                	jmp    c0100e61 <__intr_save+0x28>
    }
    return 0;
c0100e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e61:	89 ec                	mov    %ebp,%esp
c0100e63:	5d                   	pop    %ebp
c0100e64:	c3                   	ret    

c0100e65 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e65:	55                   	push   %ebp
c0100e66:	89 e5                	mov    %esp,%ebp
c0100e68:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e6f:	74 05                	je     c0100e76 <__intr_restore+0x11>
        intr_enable();
c0100e71:	e8 da 08 00 00       	call   c0101750 <intr_enable>
    }
}
c0100e76:	90                   	nop
c0100e77:	89 ec                	mov    %ebp,%esp
c0100e79:	5d                   	pop    %ebp
c0100e7a:	c3                   	ret    

c0100e7b <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e7b:	55                   	push   %ebp
c0100e7c:	89 e5                	mov    %esp,%ebp
c0100e7e:	83 ec 10             	sub    $0x10,%esp
c0100e81:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e87:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e8b:	89 c2                	mov    %eax,%edx
c0100e8d:	ec                   	in     (%dx),%al
c0100e8e:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e91:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e97:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e9b:	89 c2                	mov    %eax,%edx
c0100e9d:	ec                   	in     (%dx),%al
c0100e9e:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100ea1:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100ea7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100eab:	89 c2                	mov    %eax,%edx
c0100ead:	ec                   	in     (%dx),%al
c0100eae:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100eb1:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100eb7:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ebb:	89 c2                	mov    %eax,%edx
c0100ebd:	ec                   	in     (%dx),%al
c0100ebe:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ec1:	90                   	nop
c0100ec2:	89 ec                	mov    %ebp,%esp
c0100ec4:	5d                   	pop    %ebp
c0100ec5:	c3                   	ret    

c0100ec6 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ec6:	55                   	push   %ebp
c0100ec7:	89 e5                	mov    %esp,%ebp
c0100ec9:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ecc:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed6:	0f b7 00             	movzwl (%eax),%eax
c0100ed9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100edd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee0:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee8:	0f b7 00             	movzwl (%eax),%eax
c0100eeb:	0f b7 c0             	movzwl %ax,%eax
c0100eee:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ef3:	74 12                	je     c0100f07 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ef5:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100efc:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100f03:	b4 03 
c0100f05:	eb 13                	jmp    c0100f1a <cga_init+0x54>
    } else {
        *cp = was;
c0100f07:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f0a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f0e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f11:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100f18:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f1a:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f21:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f25:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f29:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f2d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f31:	ee                   	out    %al,(%dx)
}
c0100f32:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f33:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f3a:	40                   	inc    %eax
c0100f3b:	0f b7 c0             	movzwl %ax,%eax
c0100f3e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f42:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f46:	89 c2                	mov    %eax,%edx
c0100f48:	ec                   	in     (%dx),%al
c0100f49:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f4c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f50:	0f b6 c0             	movzbl %al,%eax
c0100f53:	c1 e0 08             	shl    $0x8,%eax
c0100f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f59:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f60:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f64:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f68:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f6c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f70:	ee                   	out    %al,(%dx)
}
c0100f71:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f72:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f79:	40                   	inc    %eax
c0100f7a:	0f b7 c0             	movzwl %ax,%eax
c0100f7d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f81:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f85:	89 c2                	mov    %eax,%edx
c0100f87:	ec                   	in     (%dx),%al
c0100f88:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f8b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f8f:	0f b6 c0             	movzbl %al,%eax
c0100f92:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f98:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fa0:	0f b7 c0             	movzwl %ax,%eax
c0100fa3:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100fa9:	90                   	nop
c0100faa:	89 ec                	mov    %ebp,%esp
c0100fac:	5d                   	pop    %ebp
c0100fad:	c3                   	ret    

c0100fae <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fae:	55                   	push   %ebp
c0100faf:	89 e5                	mov    %esp,%ebp
c0100fb1:	83 ec 48             	sub    $0x48,%esp
c0100fb4:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fba:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fbe:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fc2:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fc6:	ee                   	out    %al,(%dx)
}
c0100fc7:	90                   	nop
c0100fc8:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100fce:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fd2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fd6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fda:	ee                   	out    %al,(%dx)
}
c0100fdb:	90                   	nop
c0100fdc:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fe2:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fea:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fee:	ee                   	out    %al,(%dx)
}
c0100fef:	90                   	nop
c0100ff0:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100ff6:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ffa:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ffe:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101002:	ee                   	out    %al,(%dx)
}
c0101003:	90                   	nop
c0101004:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c010100a:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010100e:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101012:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101016:	ee                   	out    %al,(%dx)
}
c0101017:	90                   	nop
c0101018:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010101e:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101022:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101026:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010102a:	ee                   	out    %al,(%dx)
}
c010102b:	90                   	nop
c010102c:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101032:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101036:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010103a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010103e:	ee                   	out    %al,(%dx)
}
c010103f:	90                   	nop
c0101040:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101046:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010104a:	89 c2                	mov    %eax,%edx
c010104c:	ec                   	in     (%dx),%al
c010104d:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101050:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101054:	3c ff                	cmp    $0xff,%al
c0101056:	0f 95 c0             	setne  %al
c0101059:	0f b6 c0             	movzbl %al,%eax
c010105c:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c0101061:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101067:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010106b:	89 c2                	mov    %eax,%edx
c010106d:	ec                   	in     (%dx),%al
c010106e:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101071:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101077:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010107b:	89 c2                	mov    %eax,%edx
c010107d:	ec                   	in     (%dx),%al
c010107e:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101081:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101086:	85 c0                	test   %eax,%eax
c0101088:	74 0c                	je     c0101096 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c010108a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101091:	e8 27 07 00 00       	call   c01017bd <pic_enable>
    }
}
c0101096:	90                   	nop
c0101097:	89 ec                	mov    %ebp,%esp
c0101099:	5d                   	pop    %ebp
c010109a:	c3                   	ret    

c010109b <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010109b:	55                   	push   %ebp
c010109c:	89 e5                	mov    %esp,%ebp
c010109e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010a8:	eb 08                	jmp    c01010b2 <lpt_putc_sub+0x17>
        delay();
c01010aa:	e8 cc fd ff ff       	call   c0100e7b <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010af:	ff 45 fc             	incl   -0x4(%ebp)
c01010b2:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010b8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010bc:	89 c2                	mov    %eax,%edx
c01010be:	ec                   	in     (%dx),%al
c01010bf:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010c2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010c6:	84 c0                	test   %al,%al
c01010c8:	78 09                	js     c01010d3 <lpt_putc_sub+0x38>
c01010ca:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010d1:	7e d7                	jle    c01010aa <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d6:	0f b6 c0             	movzbl %al,%eax
c01010d9:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010df:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010e2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010e6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010ea:	ee                   	out    %al,(%dx)
}
c01010eb:	90                   	nop
c01010ec:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010f2:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010f6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010fa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010fe:	ee                   	out    %al,(%dx)
}
c01010ff:	90                   	nop
c0101100:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101106:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010110a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010110e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101112:	ee                   	out    %al,(%dx)
}
c0101113:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101114:	90                   	nop
c0101115:	89 ec                	mov    %ebp,%esp
c0101117:	5d                   	pop    %ebp
c0101118:	c3                   	ret    

c0101119 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101119:	55                   	push   %ebp
c010111a:	89 e5                	mov    %esp,%ebp
c010111c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010111f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101123:	74 0d                	je     c0101132 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101125:	8b 45 08             	mov    0x8(%ebp),%eax
c0101128:	89 04 24             	mov    %eax,(%esp)
c010112b:	e8 6b ff ff ff       	call   c010109b <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101130:	eb 24                	jmp    c0101156 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101132:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101139:	e8 5d ff ff ff       	call   c010109b <lpt_putc_sub>
        lpt_putc_sub(' ');
c010113e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101145:	e8 51 ff ff ff       	call   c010109b <lpt_putc_sub>
        lpt_putc_sub('\b');
c010114a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101151:	e8 45 ff ff ff       	call   c010109b <lpt_putc_sub>
}
c0101156:	90                   	nop
c0101157:	89 ec                	mov    %ebp,%esp
c0101159:	5d                   	pop    %ebp
c010115a:	c3                   	ret    

c010115b <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010115b:	55                   	push   %ebp
c010115c:	89 e5                	mov    %esp,%ebp
c010115e:	83 ec 38             	sub    $0x38,%esp
c0101161:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101164:	8b 45 08             	mov    0x8(%ebp),%eax
c0101167:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010116c:	85 c0                	test   %eax,%eax
c010116e:	75 07                	jne    c0101177 <cga_putc+0x1c>
        c |= 0x0700;
c0101170:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101177:	8b 45 08             	mov    0x8(%ebp),%eax
c010117a:	0f b6 c0             	movzbl %al,%eax
c010117d:	83 f8 0d             	cmp    $0xd,%eax
c0101180:	74 72                	je     c01011f4 <cga_putc+0x99>
c0101182:	83 f8 0d             	cmp    $0xd,%eax
c0101185:	0f 8f a3 00 00 00    	jg     c010122e <cga_putc+0xd3>
c010118b:	83 f8 08             	cmp    $0x8,%eax
c010118e:	74 0a                	je     c010119a <cga_putc+0x3f>
c0101190:	83 f8 0a             	cmp    $0xa,%eax
c0101193:	74 4c                	je     c01011e1 <cga_putc+0x86>
c0101195:	e9 94 00 00 00       	jmp    c010122e <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c010119a:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011a1:	85 c0                	test   %eax,%eax
c01011a3:	0f 84 af 00 00 00    	je     c0101258 <cga_putc+0xfd>
            crt_pos --;
c01011a9:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011b0:	48                   	dec    %eax
c01011b1:	0f b7 c0             	movzwl %ax,%eax
c01011b4:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01011bd:	98                   	cwtl   
c01011be:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011c3:	98                   	cwtl   
c01011c4:	83 c8 20             	or     $0x20,%eax
c01011c7:	98                   	cwtl   
c01011c8:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c01011ce:	0f b7 15 44 c4 11 c0 	movzwl 0xc011c444,%edx
c01011d5:	01 d2                	add    %edx,%edx
c01011d7:	01 ca                	add    %ecx,%edx
c01011d9:	0f b7 c0             	movzwl %ax,%eax
c01011dc:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011df:	eb 77                	jmp    c0101258 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011e1:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011e8:	83 c0 50             	add    $0x50,%eax
c01011eb:	0f b7 c0             	movzwl %ax,%eax
c01011ee:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011f4:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c01011fb:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c0101202:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101207:	89 c8                	mov    %ecx,%eax
c0101209:	f7 e2                	mul    %edx
c010120b:	c1 ea 06             	shr    $0x6,%edx
c010120e:	89 d0                	mov    %edx,%eax
c0101210:	c1 e0 02             	shl    $0x2,%eax
c0101213:	01 d0                	add    %edx,%eax
c0101215:	c1 e0 04             	shl    $0x4,%eax
c0101218:	29 c1                	sub    %eax,%ecx
c010121a:	89 ca                	mov    %ecx,%edx
c010121c:	0f b7 d2             	movzwl %dx,%edx
c010121f:	89 d8                	mov    %ebx,%eax
c0101221:	29 d0                	sub    %edx,%eax
c0101223:	0f b7 c0             	movzwl %ax,%eax
c0101226:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c010122c:	eb 2b                	jmp    c0101259 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010122e:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c0101234:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010123b:	8d 50 01             	lea    0x1(%eax),%edx
c010123e:	0f b7 d2             	movzwl %dx,%edx
c0101241:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c0101248:	01 c0                	add    %eax,%eax
c010124a:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010124d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101250:	0f b7 c0             	movzwl %ax,%eax
c0101253:	66 89 02             	mov    %ax,(%edx)
        break;
c0101256:	eb 01                	jmp    c0101259 <cga_putc+0xfe>
        break;
c0101258:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101259:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101260:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101265:	76 5e                	jbe    c01012c5 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101267:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010126c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101272:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101277:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010127e:	00 
c010127f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101283:	89 04 24             	mov    %eax,(%esp)
c0101286:	e8 1b 4e 00 00       	call   c01060a6 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010128b:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101292:	eb 15                	jmp    c01012a9 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101294:	8b 15 40 c4 11 c0    	mov    0xc011c440,%edx
c010129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010129d:	01 c0                	add    %eax,%eax
c010129f:	01 d0                	add    %edx,%eax
c01012a1:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012a6:	ff 45 f4             	incl   -0xc(%ebp)
c01012a9:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012b0:	7e e2                	jle    c0101294 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012b2:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012b9:	83 e8 50             	sub    $0x50,%eax
c01012bc:	0f b7 c0             	movzwl %ax,%eax
c01012bf:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012c5:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c01012cc:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012d0:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012d4:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012d8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012dc:	ee                   	out    %al,(%dx)
}
c01012dd:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012de:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012e5:	c1 e8 08             	shr    $0x8,%eax
c01012e8:	0f b7 c0             	movzwl %ax,%eax
c01012eb:	0f b6 c0             	movzbl %al,%eax
c01012ee:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c01012f5:	42                   	inc    %edx
c01012f6:	0f b7 d2             	movzwl %dx,%edx
c01012f9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012fd:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101300:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101304:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101308:	ee                   	out    %al,(%dx)
}
c0101309:	90                   	nop
    outb(addr_6845, 15);
c010130a:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0101311:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101315:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101319:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010131d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101321:	ee                   	out    %al,(%dx)
}
c0101322:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101323:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010132a:	0f b6 c0             	movzbl %al,%eax
c010132d:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c0101334:	42                   	inc    %edx
c0101335:	0f b7 d2             	movzwl %dx,%edx
c0101338:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010133c:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010133f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101343:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101347:	ee                   	out    %al,(%dx)
}
c0101348:	90                   	nop
}
c0101349:	90                   	nop
c010134a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010134d:	89 ec                	mov    %ebp,%esp
c010134f:	5d                   	pop    %ebp
c0101350:	c3                   	ret    

c0101351 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101351:	55                   	push   %ebp
c0101352:	89 e5                	mov    %esp,%ebp
c0101354:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101357:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010135e:	eb 08                	jmp    c0101368 <serial_putc_sub+0x17>
        delay();
c0101360:	e8 16 fb ff ff       	call   c0100e7b <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101365:	ff 45 fc             	incl   -0x4(%ebp)
c0101368:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010136e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101372:	89 c2                	mov    %eax,%edx
c0101374:	ec                   	in     (%dx),%al
c0101375:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101378:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010137c:	0f b6 c0             	movzbl %al,%eax
c010137f:	83 e0 20             	and    $0x20,%eax
c0101382:	85 c0                	test   %eax,%eax
c0101384:	75 09                	jne    c010138f <serial_putc_sub+0x3e>
c0101386:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010138d:	7e d1                	jle    c0101360 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010138f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101392:	0f b6 c0             	movzbl %al,%eax
c0101395:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010139b:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010139e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013a2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013a6:	ee                   	out    %al,(%dx)
}
c01013a7:	90                   	nop
}
c01013a8:	90                   	nop
c01013a9:	89 ec                	mov    %ebp,%esp
c01013ab:	5d                   	pop    %ebp
c01013ac:	c3                   	ret    

c01013ad <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013ad:	55                   	push   %ebp
c01013ae:	89 e5                	mov    %esp,%ebp
c01013b0:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013b3:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013b7:	74 0d                	je     c01013c6 <serial_putc+0x19>
        serial_putc_sub(c);
c01013b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01013bc:	89 04 24             	mov    %eax,(%esp)
c01013bf:	e8 8d ff ff ff       	call   c0101351 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013c4:	eb 24                	jmp    c01013ea <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013c6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013cd:	e8 7f ff ff ff       	call   c0101351 <serial_putc_sub>
        serial_putc_sub(' ');
c01013d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013d9:	e8 73 ff ff ff       	call   c0101351 <serial_putc_sub>
        serial_putc_sub('\b');
c01013de:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013e5:	e8 67 ff ff ff       	call   c0101351 <serial_putc_sub>
}
c01013ea:	90                   	nop
c01013eb:	89 ec                	mov    %ebp,%esp
c01013ed:	5d                   	pop    %ebp
c01013ee:	c3                   	ret    

c01013ef <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013ef:	55                   	push   %ebp
c01013f0:	89 e5                	mov    %esp,%ebp
c01013f2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01013f5:	eb 33                	jmp    c010142a <cons_intr+0x3b>
        if (c != 0) {
c01013f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013fb:	74 2d                	je     c010142a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013fd:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101402:	8d 50 01             	lea    0x1(%eax),%edx
c0101405:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c010140b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010140e:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101414:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101419:	3d 00 02 00 00       	cmp    $0x200,%eax
c010141e:	75 0a                	jne    c010142a <cons_intr+0x3b>
                cons.wpos = 0;
c0101420:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c0101427:	00 00 00 
    while ((c = (*proc)()) != -1) {
c010142a:	8b 45 08             	mov    0x8(%ebp),%eax
c010142d:	ff d0                	call   *%eax
c010142f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101432:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101436:	75 bf                	jne    c01013f7 <cons_intr+0x8>
            }
        }
    }
}
c0101438:	90                   	nop
c0101439:	90                   	nop
c010143a:	89 ec                	mov    %ebp,%esp
c010143c:	5d                   	pop    %ebp
c010143d:	c3                   	ret    

c010143e <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010143e:	55                   	push   %ebp
c010143f:	89 e5                	mov    %esp,%ebp
c0101441:	83 ec 10             	sub    $0x10,%esp
c0101444:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010144a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010144e:	89 c2                	mov    %eax,%edx
c0101450:	ec                   	in     (%dx),%al
c0101451:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101454:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101458:	0f b6 c0             	movzbl %al,%eax
c010145b:	83 e0 01             	and    $0x1,%eax
c010145e:	85 c0                	test   %eax,%eax
c0101460:	75 07                	jne    c0101469 <serial_proc_data+0x2b>
        return -1;
c0101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101467:	eb 2a                	jmp    c0101493 <serial_proc_data+0x55>
c0101469:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010146f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101473:	89 c2                	mov    %eax,%edx
c0101475:	ec                   	in     (%dx),%al
c0101476:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101479:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010147d:	0f b6 c0             	movzbl %al,%eax
c0101480:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101483:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101487:	75 07                	jne    c0101490 <serial_proc_data+0x52>
        c = '\b';
c0101489:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101490:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101493:	89 ec                	mov    %ebp,%esp
c0101495:	5d                   	pop    %ebp
c0101496:	c3                   	ret    

c0101497 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101497:	55                   	push   %ebp
c0101498:	89 e5                	mov    %esp,%ebp
c010149a:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010149d:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01014a2:	85 c0                	test   %eax,%eax
c01014a4:	74 0c                	je     c01014b2 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01014a6:	c7 04 24 3e 14 10 c0 	movl   $0xc010143e,(%esp)
c01014ad:	e8 3d ff ff ff       	call   c01013ef <cons_intr>
    }
}
c01014b2:	90                   	nop
c01014b3:	89 ec                	mov    %ebp,%esp
c01014b5:	5d                   	pop    %ebp
c01014b6:	c3                   	ret    

c01014b7 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014b7:	55                   	push   %ebp
c01014b8:	89 e5                	mov    %esp,%ebp
c01014ba:	83 ec 38             	sub    $0x38,%esp
c01014bd:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014c6:	89 c2                	mov    %eax,%edx
c01014c8:	ec                   	in     (%dx),%al
c01014c9:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014d0:	0f b6 c0             	movzbl %al,%eax
c01014d3:	83 e0 01             	and    $0x1,%eax
c01014d6:	85 c0                	test   %eax,%eax
c01014d8:	75 0a                	jne    c01014e4 <kbd_proc_data+0x2d>
        return -1;
c01014da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014df:	e9 56 01 00 00       	jmp    c010163a <kbd_proc_data+0x183>
c01014e4:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014ed:	89 c2                	mov    %eax,%edx
c01014ef:	ec                   	in     (%dx),%al
c01014f0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01014f3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01014f7:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01014fa:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01014fe:	75 17                	jne    c0101517 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101500:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101505:	83 c8 40             	or     $0x40,%eax
c0101508:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c010150d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101512:	e9 23 01 00 00       	jmp    c010163a <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101517:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151b:	84 c0                	test   %al,%al
c010151d:	79 45                	jns    c0101564 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010151f:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101524:	83 e0 40             	and    $0x40,%eax
c0101527:	85 c0                	test   %eax,%eax
c0101529:	75 08                	jne    c0101533 <kbd_proc_data+0x7c>
c010152b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152f:	24 7f                	and    $0x7f,%al
c0101531:	eb 04                	jmp    c0101537 <kbd_proc_data+0x80>
c0101533:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101537:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010153a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010153e:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101545:	0c 40                	or     $0x40,%al
c0101547:	0f b6 c0             	movzbl %al,%eax
c010154a:	f7 d0                	not    %eax
c010154c:	89 c2                	mov    %eax,%edx
c010154e:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101553:	21 d0                	and    %edx,%eax
c0101555:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c010155a:	b8 00 00 00 00       	mov    $0x0,%eax
c010155f:	e9 d6 00 00 00       	jmp    c010163a <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101564:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101569:	83 e0 40             	and    $0x40,%eax
c010156c:	85 c0                	test   %eax,%eax
c010156e:	74 11                	je     c0101581 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101570:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101574:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101579:	83 e0 bf             	and    $0xffffffbf,%eax
c010157c:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c0101581:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101585:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c010158c:	0f b6 d0             	movzbl %al,%edx
c010158f:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101594:	09 d0                	or     %edx,%eax
c0101596:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c010159b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010159f:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c01015a6:	0f b6 d0             	movzbl %al,%edx
c01015a9:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015ae:	31 d0                	xor    %edx,%eax
c01015b0:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015b5:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015ba:	83 e0 03             	and    $0x3,%eax
c01015bd:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c01015c4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015c8:	01 d0                	add    %edx,%eax
c01015ca:	0f b6 00             	movzbl (%eax),%eax
c01015cd:	0f b6 c0             	movzbl %al,%eax
c01015d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015d3:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015d8:	83 e0 08             	and    $0x8,%eax
c01015db:	85 c0                	test   %eax,%eax
c01015dd:	74 22                	je     c0101601 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015df:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015e3:	7e 0c                	jle    c01015f1 <kbd_proc_data+0x13a>
c01015e5:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015e9:	7f 06                	jg     c01015f1 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015eb:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015ef:	eb 10                	jmp    c0101601 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01015f1:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01015f5:	7e 0a                	jle    c0101601 <kbd_proc_data+0x14a>
c01015f7:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01015fb:	7f 04                	jg     c0101601 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01015fd:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101601:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101606:	f7 d0                	not    %eax
c0101608:	83 e0 06             	and    $0x6,%eax
c010160b:	85 c0                	test   %eax,%eax
c010160d:	75 28                	jne    c0101637 <kbd_proc_data+0x180>
c010160f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101616:	75 1f                	jne    c0101637 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101618:	c7 04 24 13 65 10 c0 	movl   $0xc0106513,(%esp)
c010161f:	e8 32 ed ff ff       	call   c0100356 <cprintf>
c0101624:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c010162a:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010162e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101632:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101635:	ee                   	out    %al,(%dx)
}
c0101636:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101637:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010163a:	89 ec                	mov    %ebp,%esp
c010163c:	5d                   	pop    %ebp
c010163d:	c3                   	ret    

c010163e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010163e:	55                   	push   %ebp
c010163f:	89 e5                	mov    %esp,%ebp
c0101641:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101644:	c7 04 24 b7 14 10 c0 	movl   $0xc01014b7,(%esp)
c010164b:	e8 9f fd ff ff       	call   c01013ef <cons_intr>
}
c0101650:	90                   	nop
c0101651:	89 ec                	mov    %ebp,%esp
c0101653:	5d                   	pop    %ebp
c0101654:	c3                   	ret    

c0101655 <kbd_init>:

static void
kbd_init(void) {
c0101655:	55                   	push   %ebp
c0101656:	89 e5                	mov    %esp,%ebp
c0101658:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010165b:	e8 de ff ff ff       	call   c010163e <kbd_intr>
    pic_enable(IRQ_KBD);
c0101660:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101667:	e8 51 01 00 00       	call   c01017bd <pic_enable>
}
c010166c:	90                   	nop
c010166d:	89 ec                	mov    %ebp,%esp
c010166f:	5d                   	pop    %ebp
c0101670:	c3                   	ret    

c0101671 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101671:	55                   	push   %ebp
c0101672:	89 e5                	mov    %esp,%ebp
c0101674:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101677:	e8 4a f8 ff ff       	call   c0100ec6 <cga_init>
    serial_init();
c010167c:	e8 2d f9 ff ff       	call   c0100fae <serial_init>
    kbd_init();
c0101681:	e8 cf ff ff ff       	call   c0101655 <kbd_init>
    if (!serial_exists) {
c0101686:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c010168b:	85 c0                	test   %eax,%eax
c010168d:	75 0c                	jne    c010169b <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010168f:	c7 04 24 1f 65 10 c0 	movl   $0xc010651f,(%esp)
c0101696:	e8 bb ec ff ff       	call   c0100356 <cprintf>
    }
}
c010169b:	90                   	nop
c010169c:	89 ec                	mov    %ebp,%esp
c010169e:	5d                   	pop    %ebp
c010169f:	c3                   	ret    

c01016a0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016a0:	55                   	push   %ebp
c01016a1:	89 e5                	mov    %esp,%ebp
c01016a3:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016a6:	e8 8e f7 ff ff       	call   c0100e39 <__intr_save>
c01016ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01016b1:	89 04 24             	mov    %eax,(%esp)
c01016b4:	e8 60 fa ff ff       	call   c0101119 <lpt_putc>
        cga_putc(c);
c01016b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01016bc:	89 04 24             	mov    %eax,(%esp)
c01016bf:	e8 97 fa ff ff       	call   c010115b <cga_putc>
        serial_putc(c);
c01016c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c7:	89 04 24             	mov    %eax,(%esp)
c01016ca:	e8 de fc ff ff       	call   c01013ad <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016d2:	89 04 24             	mov    %eax,(%esp)
c01016d5:	e8 8b f7 ff ff       	call   c0100e65 <__intr_restore>
}
c01016da:	90                   	nop
c01016db:	89 ec                	mov    %ebp,%esp
c01016dd:	5d                   	pop    %ebp
c01016de:	c3                   	ret    

c01016df <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016df:	55                   	push   %ebp
c01016e0:	89 e5                	mov    %esp,%ebp
c01016e2:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016ec:	e8 48 f7 ff ff       	call   c0100e39 <__intr_save>
c01016f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01016f4:	e8 9e fd ff ff       	call   c0101497 <serial_intr>
        kbd_intr();
c01016f9:	e8 40 ff ff ff       	call   c010163e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01016fe:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c0101704:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101709:	39 c2                	cmp    %eax,%edx
c010170b:	74 31                	je     c010173e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010170d:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c0101712:	8d 50 01             	lea    0x1(%eax),%edx
c0101715:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c010171b:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c0101722:	0f b6 c0             	movzbl %al,%eax
c0101725:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101728:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c010172d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101732:	75 0a                	jne    c010173e <cons_getc+0x5f>
                cons.rpos = 0;
c0101734:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c010173b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101741:	89 04 24             	mov    %eax,(%esp)
c0101744:	e8 1c f7 ff ff       	call   c0100e65 <__intr_restore>
    return c;
c0101749:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010174c:	89 ec                	mov    %ebp,%esp
c010174e:	5d                   	pop    %ebp
c010174f:	c3                   	ret    

c0101750 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101750:	55                   	push   %ebp
c0101751:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101753:	fb                   	sti    
}
c0101754:	90                   	nop
    sti();
}
c0101755:	90                   	nop
c0101756:	5d                   	pop    %ebp
c0101757:	c3                   	ret    

c0101758 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101758:	55                   	push   %ebp
c0101759:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010175b:	fa                   	cli    
}
c010175c:	90                   	nop
    cli();
}
c010175d:	90                   	nop
c010175e:	5d                   	pop    %ebp
c010175f:	c3                   	ret    

c0101760 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101760:	55                   	push   %ebp
c0101761:	89 e5                	mov    %esp,%ebp
c0101763:	83 ec 14             	sub    $0x14,%esp
c0101766:	8b 45 08             	mov    0x8(%ebp),%eax
c0101769:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010176d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101770:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c0101776:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c010177b:	85 c0                	test   %eax,%eax
c010177d:	74 39                	je     c01017b8 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c010177f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101782:	0f b6 c0             	movzbl %al,%eax
c0101785:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c010178b:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010178e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101792:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101796:	ee                   	out    %al,(%dx)
}
c0101797:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101798:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010179c:	c1 e8 08             	shr    $0x8,%eax
c010179f:	0f b7 c0             	movzwl %ax,%eax
c01017a2:	0f b6 c0             	movzbl %al,%eax
c01017a5:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01017ab:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017ae:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01017b2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01017b6:	ee                   	out    %al,(%dx)
}
c01017b7:	90                   	nop
    }
}
c01017b8:	90                   	nop
c01017b9:	89 ec                	mov    %ebp,%esp
c01017bb:	5d                   	pop    %ebp
c01017bc:	c3                   	ret    

c01017bd <pic_enable>:

void
pic_enable(unsigned int irq) {
c01017bd:	55                   	push   %ebp
c01017be:	89 e5                	mov    %esp,%ebp
c01017c0:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01017c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01017c6:	ba 01 00 00 00       	mov    $0x1,%edx
c01017cb:	88 c1                	mov    %al,%cl
c01017cd:	d3 e2                	shl    %cl,%edx
c01017cf:	89 d0                	mov    %edx,%eax
c01017d1:	98                   	cwtl   
c01017d2:	f7 d0                	not    %eax
c01017d4:	0f bf d0             	movswl %ax,%edx
c01017d7:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c01017de:	98                   	cwtl   
c01017df:	21 d0                	and    %edx,%eax
c01017e1:	98                   	cwtl   
c01017e2:	0f b7 c0             	movzwl %ax,%eax
c01017e5:	89 04 24             	mov    %eax,(%esp)
c01017e8:	e8 73 ff ff ff       	call   c0101760 <pic_setmask>
}
c01017ed:	90                   	nop
c01017ee:	89 ec                	mov    %ebp,%esp
c01017f0:	5d                   	pop    %ebp
c01017f1:	c3                   	ret    

c01017f2 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01017f2:	55                   	push   %ebp
c01017f3:	89 e5                	mov    %esp,%ebp
c01017f5:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01017f8:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c01017ff:	00 00 00 
c0101802:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101808:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010180c:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101810:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101814:	ee                   	out    %al,(%dx)
}
c0101815:	90                   	nop
c0101816:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c010181c:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101820:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101824:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101828:	ee                   	out    %al,(%dx)
}
c0101829:	90                   	nop
c010182a:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101830:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101834:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101838:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010183c:	ee                   	out    %al,(%dx)
}
c010183d:	90                   	nop
c010183e:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101844:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101848:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010184c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101850:	ee                   	out    %al,(%dx)
}
c0101851:	90                   	nop
c0101852:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101858:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010185c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101860:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101864:	ee                   	out    %al,(%dx)
}
c0101865:	90                   	nop
c0101866:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010186c:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101870:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101874:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101878:	ee                   	out    %al,(%dx)
}
c0101879:	90                   	nop
c010187a:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0101880:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101884:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101888:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010188c:	ee                   	out    %al,(%dx)
}
c010188d:	90                   	nop
c010188e:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0101894:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101898:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010189c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018a0:	ee                   	out    %al,(%dx)
}
c01018a1:	90                   	nop
c01018a2:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01018a8:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ac:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018b0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018b4:	ee                   	out    %al,(%dx)
}
c01018b5:	90                   	nop
c01018b6:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01018bc:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018c4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018c8:	ee                   	out    %al,(%dx)
}
c01018c9:	90                   	nop
c01018ca:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01018d0:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018d8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018dc:	ee                   	out    %al,(%dx)
}
c01018dd:	90                   	nop
c01018de:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01018e4:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01018ec:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018f0:	ee                   	out    %al,(%dx)
}
c01018f1:	90                   	nop
c01018f2:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01018f8:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101900:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101904:	ee                   	out    %al,(%dx)
}
c0101905:	90                   	nop
c0101906:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010190c:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101910:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101914:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101918:	ee                   	out    %al,(%dx)
}
c0101919:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010191a:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101921:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101926:	74 0f                	je     c0101937 <pic_init+0x145>
        pic_setmask(irq_mask);
c0101928:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c010192f:	89 04 24             	mov    %eax,(%esp)
c0101932:	e8 29 fe ff ff       	call   c0101760 <pic_setmask>
    }
}
c0101937:	90                   	nop
c0101938:	89 ec                	mov    %ebp,%esp
c010193a:	5d                   	pop    %ebp
c010193b:	c3                   	ret    

c010193c <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010193c:	55                   	push   %ebp
c010193d:	89 e5                	mov    %esp,%ebp
c010193f:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101942:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101949:	00 
c010194a:	c7 04 24 40 65 10 c0 	movl   $0xc0106540,(%esp)
c0101951:	e8 00 ea ff ff       	call   c0100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0101956:	c7 04 24 4a 65 10 c0 	movl   $0xc010654a,(%esp)
c010195d:	e8 f4 e9 ff ff       	call   c0100356 <cprintf>
    panic("EOT: kernel seems ok.");
c0101962:	c7 44 24 08 58 65 10 	movl   $0xc0106558,0x8(%esp)
c0101969:	c0 
c010196a:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c0101971:	00 
c0101972:	c7 04 24 6e 65 10 c0 	movl   $0xc010656e,(%esp)
c0101979:	e8 81 f3 ff ff       	call   c0100cff <__panic>

c010197e <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010197e:	55                   	push   %ebp
c010197f:	89 e5                	mov    %esp,%ebp
c0101981:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */

     extern uintptr_t __vectors[];
     int i;
     for(i=0;i<256;i++)
c0101984:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010198b:	e9 c4 00 00 00       	jmp    c0101a54 <idt_init+0xd6>
     {
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
c0101990:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101993:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c010199a:	0f b7 d0             	movzwl %ax,%edx
c010199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a0:	66 89 14 c5 80 c6 11 	mov    %dx,-0x3fee3980(,%eax,8)
c01019a7:	c0 
c01019a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019ab:	66 c7 04 c5 82 c6 11 	movw   $0x8,-0x3fee397e(,%eax,8)
c01019b2:	c0 08 00 
c01019b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b8:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c01019bf:	c0 
c01019c0:	80 e2 e0             	and    $0xe0,%dl
c01019c3:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c01019ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019cd:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c01019d4:	c0 
c01019d5:	80 e2 1f             	and    $0x1f,%dl
c01019d8:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c01019df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019e2:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c01019e9:	c0 
c01019ea:	80 e2 f0             	and    $0xf0,%dl
c01019ed:	80 ca 0e             	or     $0xe,%dl
c01019f0:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c01019f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019fa:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a01:	c0 
c0101a02:	80 e2 ef             	and    $0xef,%dl
c0101a05:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a0f:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a16:	c0 
c0101a17:	80 e2 9f             	and    $0x9f,%dl
c0101a1a:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a24:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a2b:	c0 
c0101a2c:	80 ca 80             	or     $0x80,%dl
c0101a2f:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a36:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a39:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101a40:	c1 e8 10             	shr    $0x10,%eax
c0101a43:	0f b7 d0             	movzwl %ax,%edx
c0101a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a49:	66 89 14 c5 86 c6 11 	mov    %dx,-0x3fee397a(,%eax,8)
c0101a50:	c0 
     for(i=0;i<256;i++)
c0101a51:	ff 45 fc             	incl   -0x4(%ebp)
c0101a54:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0101a5b:	0f 8e 2f ff ff ff    	jle    c0101990 <idt_init+0x12>
     }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], 3);
c0101a61:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101a66:	0f b7 c0             	movzwl %ax,%eax
c0101a69:	66 a3 48 ca 11 c0    	mov    %ax,0xc011ca48
c0101a6f:	66 c7 05 4a ca 11 c0 	movw   $0x8,0xc011ca4a
c0101a76:	08 00 
c0101a78:	0f b6 05 4c ca 11 c0 	movzbl 0xc011ca4c,%eax
c0101a7f:	24 e0                	and    $0xe0,%al
c0101a81:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c0101a86:	0f b6 05 4c ca 11 c0 	movzbl 0xc011ca4c,%eax
c0101a8d:	24 1f                	and    $0x1f,%al
c0101a8f:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c0101a94:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101a9b:	24 f0                	and    $0xf0,%al
c0101a9d:	0c 0e                	or     $0xe,%al
c0101a9f:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101aa4:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101aab:	24 ef                	and    $0xef,%al
c0101aad:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101ab2:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101ab9:	0c 60                	or     $0x60,%al
c0101abb:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101ac0:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101ac7:	0c 80                	or     $0x80,%al
c0101ac9:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101ace:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101ad3:	c1 e8 10             	shr    $0x10,%eax
c0101ad6:	0f b7 c0             	movzwl %ax,%eax
c0101ad9:	66 a3 4e ca 11 c0    	mov    %ax,0xc011ca4e
c0101adf:	c7 45 f8 60 95 11 c0 	movl   $0xc0119560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101ae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101ae9:	0f 01 18             	lidtl  (%eax)
}
c0101aec:	90                   	nop





}
c0101aed:	90                   	nop
c0101aee:	89 ec                	mov    %ebp,%esp
c0101af0:	5d                   	pop    %ebp
c0101af1:	c3                   	ret    

c0101af2 <trapname>:

static const char *
trapname(int trapno) {
c0101af2:	55                   	push   %ebp
c0101af3:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101af5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af8:	83 f8 13             	cmp    $0x13,%eax
c0101afb:	77 0c                	ja     c0101b09 <trapname+0x17>
        return excnames[trapno];
c0101afd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b00:	8b 04 85 c0 68 10 c0 	mov    -0x3fef9740(,%eax,4),%eax
c0101b07:	eb 18                	jmp    c0101b21 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101b09:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101b0d:	7e 0d                	jle    c0101b1c <trapname+0x2a>
c0101b0f:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101b13:	7f 07                	jg     c0101b1c <trapname+0x2a>
        return "Hardware Interrupt";
c0101b15:	b8 7f 65 10 c0       	mov    $0xc010657f,%eax
c0101b1a:	eb 05                	jmp    c0101b21 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101b1c:	b8 92 65 10 c0       	mov    $0xc0106592,%eax
}
c0101b21:	5d                   	pop    %ebp
c0101b22:	c3                   	ret    

c0101b23 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101b23:	55                   	push   %ebp
c0101b24:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101b26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b29:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b2d:	83 f8 08             	cmp    $0x8,%eax
c0101b30:	0f 94 c0             	sete   %al
c0101b33:	0f b6 c0             	movzbl %al,%eax
}
c0101b36:	5d                   	pop    %ebp
c0101b37:	c3                   	ret    

c0101b38 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b38:	55                   	push   %ebp
c0101b39:	89 e5                	mov    %esp,%ebp
c0101b3b:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b45:	c7 04 24 d3 65 10 c0 	movl   $0xc01065d3,(%esp)
c0101b4c:	e8 05 e8 ff ff       	call   c0100356 <cprintf>
    print_regs(&tf->tf_regs);
c0101b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b54:	89 04 24             	mov    %eax,(%esp)
c0101b57:	e8 8f 01 00 00       	call   c0101ceb <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5f:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101b63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b67:	c7 04 24 e4 65 10 c0 	movl   $0xc01065e4,(%esp)
c0101b6e:	e8 e3 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b76:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7e:	c7 04 24 f7 65 10 c0 	movl   $0xc01065f7,(%esp)
c0101b85:	e8 cc e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b95:	c7 04 24 0a 66 10 c0 	movl   $0xc010660a,(%esp)
c0101b9c:	e8 b5 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba4:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bac:	c7 04 24 1d 66 10 c0 	movl   $0xc010661d,(%esp)
c0101bb3:	e8 9e e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbb:	8b 40 30             	mov    0x30(%eax),%eax
c0101bbe:	89 04 24             	mov    %eax,(%esp)
c0101bc1:	e8 2c ff ff ff       	call   c0101af2 <trapname>
c0101bc6:	8b 55 08             	mov    0x8(%ebp),%edx
c0101bc9:	8b 52 30             	mov    0x30(%edx),%edx
c0101bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101bd0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101bd4:	c7 04 24 30 66 10 c0 	movl   $0xc0106630,(%esp)
c0101bdb:	e8 76 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be3:	8b 40 34             	mov    0x34(%eax),%eax
c0101be6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bea:	c7 04 24 42 66 10 c0 	movl   $0xc0106642,(%esp)
c0101bf1:	e8 60 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf9:	8b 40 38             	mov    0x38(%eax),%eax
c0101bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c00:	c7 04 24 51 66 10 c0 	movl   $0xc0106651,(%esp)
c0101c07:	e8 4a e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101c13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c17:	c7 04 24 60 66 10 c0 	movl   $0xc0106660,(%esp)
c0101c1e:	e8 33 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101c23:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c26:	8b 40 40             	mov    0x40(%eax),%eax
c0101c29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c2d:	c7 04 24 73 66 10 c0 	movl   $0xc0106673,(%esp)
c0101c34:	e8 1d e7 ff ff       	call   c0100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101c40:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101c47:	eb 3d                	jmp    c0101c86 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101c49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4c:	8b 50 40             	mov    0x40(%eax),%edx
c0101c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c52:	21 d0                	and    %edx,%eax
c0101c54:	85 c0                	test   %eax,%eax
c0101c56:	74 28                	je     c0101c80 <print_trapframe+0x148>
c0101c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c5b:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101c62:	85 c0                	test   %eax,%eax
c0101c64:	74 1a                	je     c0101c80 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c0101c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c69:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101c70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c74:	c7 04 24 82 66 10 c0 	movl   $0xc0106682,(%esp)
c0101c7b:	e8 d6 e6 ff ff       	call   c0100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c80:	ff 45 f4             	incl   -0xc(%ebp)
c0101c83:	d1 65 f0             	shll   -0x10(%ebp)
c0101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c89:	83 f8 17             	cmp    $0x17,%eax
c0101c8c:	76 bb                	jbe    c0101c49 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c91:	8b 40 40             	mov    0x40(%eax),%eax
c0101c94:	c1 e8 0c             	shr    $0xc,%eax
c0101c97:	83 e0 03             	and    $0x3,%eax
c0101c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c9e:	c7 04 24 86 66 10 c0 	movl   $0xc0106686,(%esp)
c0101ca5:	e8 ac e6 ff ff       	call   c0100356 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101caa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cad:	89 04 24             	mov    %eax,(%esp)
c0101cb0:	e8 6e fe ff ff       	call   c0101b23 <trap_in_kernel>
c0101cb5:	85 c0                	test   %eax,%eax
c0101cb7:	75 2d                	jne    c0101ce6 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cbc:	8b 40 44             	mov    0x44(%eax),%eax
c0101cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc3:	c7 04 24 8f 66 10 c0 	movl   $0xc010668f,(%esp)
c0101cca:	e8 87 e6 ff ff       	call   c0100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd2:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cda:	c7 04 24 9e 66 10 c0 	movl   $0xc010669e,(%esp)
c0101ce1:	e8 70 e6 ff ff       	call   c0100356 <cprintf>
    }
}
c0101ce6:	90                   	nop
c0101ce7:	89 ec                	mov    %ebp,%esp
c0101ce9:	5d                   	pop    %ebp
c0101cea:	c3                   	ret    

c0101ceb <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101ceb:	55                   	push   %ebp
c0101cec:	89 e5                	mov    %esp,%ebp
c0101cee:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf4:	8b 00                	mov    (%eax),%eax
c0101cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cfa:	c7 04 24 b1 66 10 c0 	movl   $0xc01066b1,(%esp)
c0101d01:	e8 50 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101d06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d09:	8b 40 04             	mov    0x4(%eax),%eax
c0101d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d10:	c7 04 24 c0 66 10 c0 	movl   $0xc01066c0,(%esp)
c0101d17:	e8 3a e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d1f:	8b 40 08             	mov    0x8(%eax),%eax
c0101d22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d26:	c7 04 24 cf 66 10 c0 	movl   $0xc01066cf,(%esp)
c0101d2d:	e8 24 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d35:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d3c:	c7 04 24 de 66 10 c0 	movl   $0xc01066de,(%esp)
c0101d43:	e8 0e e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d4b:	8b 40 10             	mov    0x10(%eax),%eax
c0101d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d52:	c7 04 24 ed 66 10 c0 	movl   $0xc01066ed,(%esp)
c0101d59:	e8 f8 e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101d5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d61:	8b 40 14             	mov    0x14(%eax),%eax
c0101d64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d68:	c7 04 24 fc 66 10 c0 	movl   $0xc01066fc,(%esp)
c0101d6f:	e8 e2 e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101d74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d77:	8b 40 18             	mov    0x18(%eax),%eax
c0101d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d7e:	c7 04 24 0b 67 10 c0 	movl   $0xc010670b,(%esp)
c0101d85:	e8 cc e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d94:	c7 04 24 1a 67 10 c0 	movl   $0xc010671a,(%esp)
c0101d9b:	e8 b6 e5 ff ff       	call   c0100356 <cprintf>
}
c0101da0:	90                   	nop
c0101da1:	89 ec                	mov    %ebp,%esp
c0101da3:	5d                   	pop    %ebp
c0101da4:	c3                   	ret    

c0101da5 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101da5:	55                   	push   %ebp
c0101da6:	89 e5                	mov    %esp,%ebp
c0101da8:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101dab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dae:	8b 40 30             	mov    0x30(%eax),%eax
c0101db1:	83 f8 79             	cmp    $0x79,%eax
c0101db4:	0f 87 e6 00 00 00    	ja     c0101ea0 <trap_dispatch+0xfb>
c0101dba:	83 f8 78             	cmp    $0x78,%eax
c0101dbd:	0f 83 c1 00 00 00    	jae    c0101e84 <trap_dispatch+0xdf>
c0101dc3:	83 f8 2f             	cmp    $0x2f,%eax
c0101dc6:	0f 87 d4 00 00 00    	ja     c0101ea0 <trap_dispatch+0xfb>
c0101dcc:	83 f8 2e             	cmp    $0x2e,%eax
c0101dcf:	0f 83 00 01 00 00    	jae    c0101ed5 <trap_dispatch+0x130>
c0101dd5:	83 f8 24             	cmp    $0x24,%eax
c0101dd8:	74 5e                	je     c0101e38 <trap_dispatch+0x93>
c0101dda:	83 f8 24             	cmp    $0x24,%eax
c0101ddd:	0f 87 bd 00 00 00    	ja     c0101ea0 <trap_dispatch+0xfb>
c0101de3:	83 f8 20             	cmp    $0x20,%eax
c0101de6:	74 0a                	je     c0101df2 <trap_dispatch+0x4d>
c0101de8:	83 f8 21             	cmp    $0x21,%eax
c0101deb:	74 71                	je     c0101e5e <trap_dispatch+0xb9>
c0101ded:	e9 ae 00 00 00       	jmp    c0101ea0 <trap_dispatch+0xfb>
    case IRQ_OFFSET + IRQ_TIMER:
        ticks+=1;
c0101df2:	a1 24 c4 11 c0       	mov    0xc011c424,%eax
c0101df7:	40                   	inc    %eax
c0101df8:	a3 24 c4 11 c0       	mov    %eax,0xc011c424
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        if (ticks % TICK_NUM == 0) {
c0101dfd:	8b 0d 24 c4 11 c0    	mov    0xc011c424,%ecx
c0101e03:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101e08:	89 c8                	mov    %ecx,%eax
c0101e0a:	f7 e2                	mul    %edx
c0101e0c:	c1 ea 05             	shr    $0x5,%edx
c0101e0f:	89 d0                	mov    %edx,%eax
c0101e11:	c1 e0 02             	shl    $0x2,%eax
c0101e14:	01 d0                	add    %edx,%eax
c0101e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e1d:	01 d0                	add    %edx,%eax
c0101e1f:	c1 e0 02             	shl    $0x2,%eax
c0101e22:	29 c1                	sub    %eax,%ecx
c0101e24:	89 ca                	mov    %ecx,%edx
c0101e26:	85 d2                	test   %edx,%edx
c0101e28:	0f 85 aa 00 00 00    	jne    c0101ed8 <trap_dispatch+0x133>
            print_ticks();
c0101e2e:	e8 09 fb ff ff       	call   c010193c <print_ticks>
        }
        break;
c0101e33:	e9 a0 00 00 00       	jmp    c0101ed8 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101e38:	e8 a2 f8 ff ff       	call   c01016df <cons_getc>
c0101e3d:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101e40:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e44:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e48:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e50:	c7 04 24 29 67 10 c0 	movl   $0xc0106729,(%esp)
c0101e57:	e8 fa e4 ff ff       	call   c0100356 <cprintf>
        break;
c0101e5c:	eb 7b                	jmp    c0101ed9 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101e5e:	e8 7c f8 ff ff       	call   c01016df <cons_getc>
c0101e63:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101e66:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e6a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e6e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e76:	c7 04 24 3b 67 10 c0 	movl   $0xc010673b,(%esp)
c0101e7d:	e8 d4 e4 ff ff       	call   c0100356 <cprintf>
        break;
c0101e82:	eb 55                	jmp    c0101ed9 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101e84:	c7 44 24 08 4a 67 10 	movl   $0xc010674a,0x8(%esp)
c0101e8b:	c0 
c0101e8c:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0101e93:	00 
c0101e94:	c7 04 24 6e 65 10 c0 	movl   $0xc010656e,(%esp)
c0101e9b:	e8 5f ee ff ff       	call   c0100cff <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ea7:	83 e0 03             	and    $0x3,%eax
c0101eaa:	85 c0                	test   %eax,%eax
c0101eac:	75 2b                	jne    c0101ed9 <trap_dispatch+0x134>
            print_trapframe(tf);
c0101eae:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb1:	89 04 24             	mov    %eax,(%esp)
c0101eb4:	e8 7f fc ff ff       	call   c0101b38 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101eb9:	c7 44 24 08 5a 67 10 	movl   $0xc010675a,0x8(%esp)
c0101ec0:	c0 
c0101ec1:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0101ec8:	00 
c0101ec9:	c7 04 24 6e 65 10 c0 	movl   $0xc010656e,(%esp)
c0101ed0:	e8 2a ee ff ff       	call   c0100cff <__panic>
        break;
c0101ed5:	90                   	nop
c0101ed6:	eb 01                	jmp    c0101ed9 <trap_dispatch+0x134>
        break;
c0101ed8:	90                   	nop
        }
    }
}
c0101ed9:	90                   	nop
c0101eda:	89 ec                	mov    %ebp,%esp
c0101edc:	5d                   	pop    %ebp
c0101edd:	c3                   	ret    

c0101ede <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101ede:	55                   	push   %ebp
c0101edf:	89 e5                	mov    %esp,%ebp
c0101ee1:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee7:	89 04 24             	mov    %eax,(%esp)
c0101eea:	e8 b6 fe ff ff       	call   c0101da5 <trap_dispatch>


}
c0101eef:	90                   	nop
c0101ef0:	89 ec                	mov    %ebp,%esp
c0101ef2:	5d                   	pop    %ebp
c0101ef3:	c3                   	ret    

c0101ef4 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101ef4:	1e                   	push   %ds
    pushl %es
c0101ef5:	06                   	push   %es
    pushl %fs
c0101ef6:	0f a0                	push   %fs
    pushl %gs
c0101ef8:	0f a8                	push   %gs
    pushal
c0101efa:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101efb:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101f00:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101f02:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101f04:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101f05:	e8 d4 ff ff ff       	call   c0101ede <trap>

    # pop the pushed stack pointer
    popl %esp
c0101f0a:	5c                   	pop    %esp

c0101f0b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101f0b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101f0c:	0f a9                	pop    %gs
    popl %fs
c0101f0e:	0f a1                	pop    %fs
    popl %es
c0101f10:	07                   	pop    %es
    popl %ds
c0101f11:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101f12:	83 c4 08             	add    $0x8,%esp
    iret
c0101f15:	cf                   	iret   

c0101f16 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101f16:	6a 00                	push   $0x0
  pushl $0
c0101f18:	6a 00                	push   $0x0
  jmp __alltraps
c0101f1a:	e9 d5 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f1f <vector1>:
.globl vector1
vector1:
  pushl $0
c0101f1f:	6a 00                	push   $0x0
  pushl $1
c0101f21:	6a 01                	push   $0x1
  jmp __alltraps
c0101f23:	e9 cc ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f28 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101f28:	6a 00                	push   $0x0
  pushl $2
c0101f2a:	6a 02                	push   $0x2
  jmp __alltraps
c0101f2c:	e9 c3 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f31 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101f31:	6a 00                	push   $0x0
  pushl $3
c0101f33:	6a 03                	push   $0x3
  jmp __alltraps
c0101f35:	e9 ba ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f3a <vector4>:
.globl vector4
vector4:
  pushl $0
c0101f3a:	6a 00                	push   $0x0
  pushl $4
c0101f3c:	6a 04                	push   $0x4
  jmp __alltraps
c0101f3e:	e9 b1 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f43 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101f43:	6a 00                	push   $0x0
  pushl $5
c0101f45:	6a 05                	push   $0x5
  jmp __alltraps
c0101f47:	e9 a8 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f4c <vector6>:
.globl vector6
vector6:
  pushl $0
c0101f4c:	6a 00                	push   $0x0
  pushl $6
c0101f4e:	6a 06                	push   $0x6
  jmp __alltraps
c0101f50:	e9 9f ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f55 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101f55:	6a 00                	push   $0x0
  pushl $7
c0101f57:	6a 07                	push   $0x7
  jmp __alltraps
c0101f59:	e9 96 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f5e <vector8>:
.globl vector8
vector8:
  pushl $8
c0101f5e:	6a 08                	push   $0x8
  jmp __alltraps
c0101f60:	e9 8f ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f65 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $9
c0101f67:	6a 09                	push   $0x9
  jmp __alltraps
c0101f69:	e9 86 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f6e <vector10>:
.globl vector10
vector10:
  pushl $10
c0101f6e:	6a 0a                	push   $0xa
  jmp __alltraps
c0101f70:	e9 7f ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f75 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101f75:	6a 0b                	push   $0xb
  jmp __alltraps
c0101f77:	e9 78 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f7c <vector12>:
.globl vector12
vector12:
  pushl $12
c0101f7c:	6a 0c                	push   $0xc
  jmp __alltraps
c0101f7e:	e9 71 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f83 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101f83:	6a 0d                	push   $0xd
  jmp __alltraps
c0101f85:	e9 6a ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f8a <vector14>:
.globl vector14
vector14:
  pushl $14
c0101f8a:	6a 0e                	push   $0xe
  jmp __alltraps
c0101f8c:	e9 63 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f91 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101f91:	6a 00                	push   $0x0
  pushl $15
c0101f93:	6a 0f                	push   $0xf
  jmp __alltraps
c0101f95:	e9 5a ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101f9a <vector16>:
.globl vector16
vector16:
  pushl $0
c0101f9a:	6a 00                	push   $0x0
  pushl $16
c0101f9c:	6a 10                	push   $0x10
  jmp __alltraps
c0101f9e:	e9 51 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fa3 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101fa3:	6a 11                	push   $0x11
  jmp __alltraps
c0101fa5:	e9 4a ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101faa <vector18>:
.globl vector18
vector18:
  pushl $0
c0101faa:	6a 00                	push   $0x0
  pushl $18
c0101fac:	6a 12                	push   $0x12
  jmp __alltraps
c0101fae:	e9 41 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fb3 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101fb3:	6a 00                	push   $0x0
  pushl $19
c0101fb5:	6a 13                	push   $0x13
  jmp __alltraps
c0101fb7:	e9 38 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fbc <vector20>:
.globl vector20
vector20:
  pushl $0
c0101fbc:	6a 00                	push   $0x0
  pushl $20
c0101fbe:	6a 14                	push   $0x14
  jmp __alltraps
c0101fc0:	e9 2f ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fc5 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101fc5:	6a 00                	push   $0x0
  pushl $21
c0101fc7:	6a 15                	push   $0x15
  jmp __alltraps
c0101fc9:	e9 26 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fce <vector22>:
.globl vector22
vector22:
  pushl $0
c0101fce:	6a 00                	push   $0x0
  pushl $22
c0101fd0:	6a 16                	push   $0x16
  jmp __alltraps
c0101fd2:	e9 1d ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fd7 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101fd7:	6a 00                	push   $0x0
  pushl $23
c0101fd9:	6a 17                	push   $0x17
  jmp __alltraps
c0101fdb:	e9 14 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fe0 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101fe0:	6a 00                	push   $0x0
  pushl $24
c0101fe2:	6a 18                	push   $0x18
  jmp __alltraps
c0101fe4:	e9 0b ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101fe9 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101fe9:	6a 00                	push   $0x0
  pushl $25
c0101feb:	6a 19                	push   $0x19
  jmp __alltraps
c0101fed:	e9 02 ff ff ff       	jmp    c0101ef4 <__alltraps>

c0101ff2 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101ff2:	6a 00                	push   $0x0
  pushl $26
c0101ff4:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101ff6:	e9 f9 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0101ffb <vector27>:
.globl vector27
vector27:
  pushl $0
c0101ffb:	6a 00                	push   $0x0
  pushl $27
c0101ffd:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101fff:	e9 f0 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102004 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102004:	6a 00                	push   $0x0
  pushl $28
c0102006:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102008:	e9 e7 fe ff ff       	jmp    c0101ef4 <__alltraps>

c010200d <vector29>:
.globl vector29
vector29:
  pushl $0
c010200d:	6a 00                	push   $0x0
  pushl $29
c010200f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102011:	e9 de fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102016 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102016:	6a 00                	push   $0x0
  pushl $30
c0102018:	6a 1e                	push   $0x1e
  jmp __alltraps
c010201a:	e9 d5 fe ff ff       	jmp    c0101ef4 <__alltraps>

c010201f <vector31>:
.globl vector31
vector31:
  pushl $0
c010201f:	6a 00                	push   $0x0
  pushl $31
c0102021:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102023:	e9 cc fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102028 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102028:	6a 00                	push   $0x0
  pushl $32
c010202a:	6a 20                	push   $0x20
  jmp __alltraps
c010202c:	e9 c3 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102031 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102031:	6a 00                	push   $0x0
  pushl $33
c0102033:	6a 21                	push   $0x21
  jmp __alltraps
c0102035:	e9 ba fe ff ff       	jmp    c0101ef4 <__alltraps>

c010203a <vector34>:
.globl vector34
vector34:
  pushl $0
c010203a:	6a 00                	push   $0x0
  pushl $34
c010203c:	6a 22                	push   $0x22
  jmp __alltraps
c010203e:	e9 b1 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102043 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102043:	6a 00                	push   $0x0
  pushl $35
c0102045:	6a 23                	push   $0x23
  jmp __alltraps
c0102047:	e9 a8 fe ff ff       	jmp    c0101ef4 <__alltraps>

c010204c <vector36>:
.globl vector36
vector36:
  pushl $0
c010204c:	6a 00                	push   $0x0
  pushl $36
c010204e:	6a 24                	push   $0x24
  jmp __alltraps
c0102050:	e9 9f fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102055 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102055:	6a 00                	push   $0x0
  pushl $37
c0102057:	6a 25                	push   $0x25
  jmp __alltraps
c0102059:	e9 96 fe ff ff       	jmp    c0101ef4 <__alltraps>

c010205e <vector38>:
.globl vector38
vector38:
  pushl $0
c010205e:	6a 00                	push   $0x0
  pushl $38
c0102060:	6a 26                	push   $0x26
  jmp __alltraps
c0102062:	e9 8d fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102067 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102067:	6a 00                	push   $0x0
  pushl $39
c0102069:	6a 27                	push   $0x27
  jmp __alltraps
c010206b:	e9 84 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102070 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102070:	6a 00                	push   $0x0
  pushl $40
c0102072:	6a 28                	push   $0x28
  jmp __alltraps
c0102074:	e9 7b fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102079 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102079:	6a 00                	push   $0x0
  pushl $41
c010207b:	6a 29                	push   $0x29
  jmp __alltraps
c010207d:	e9 72 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102082 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102082:	6a 00                	push   $0x0
  pushl $42
c0102084:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102086:	e9 69 fe ff ff       	jmp    c0101ef4 <__alltraps>

c010208b <vector43>:
.globl vector43
vector43:
  pushl $0
c010208b:	6a 00                	push   $0x0
  pushl $43
c010208d:	6a 2b                	push   $0x2b
  jmp __alltraps
c010208f:	e9 60 fe ff ff       	jmp    c0101ef4 <__alltraps>

c0102094 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102094:	6a 00                	push   $0x0
  pushl $44
c0102096:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102098:	e9 57 fe ff ff       	jmp    c0101ef4 <__alltraps>

c010209d <vector45>:
.globl vector45
vector45:
  pushl $0
c010209d:	6a 00                	push   $0x0
  pushl $45
c010209f:	6a 2d                	push   $0x2d
  jmp __alltraps
c01020a1:	e9 4e fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020a6 <vector46>:
.globl vector46
vector46:
  pushl $0
c01020a6:	6a 00                	push   $0x0
  pushl $46
c01020a8:	6a 2e                	push   $0x2e
  jmp __alltraps
c01020aa:	e9 45 fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020af <vector47>:
.globl vector47
vector47:
  pushl $0
c01020af:	6a 00                	push   $0x0
  pushl $47
c01020b1:	6a 2f                	push   $0x2f
  jmp __alltraps
c01020b3:	e9 3c fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020b8 <vector48>:
.globl vector48
vector48:
  pushl $0
c01020b8:	6a 00                	push   $0x0
  pushl $48
c01020ba:	6a 30                	push   $0x30
  jmp __alltraps
c01020bc:	e9 33 fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020c1 <vector49>:
.globl vector49
vector49:
  pushl $0
c01020c1:	6a 00                	push   $0x0
  pushl $49
c01020c3:	6a 31                	push   $0x31
  jmp __alltraps
c01020c5:	e9 2a fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020ca <vector50>:
.globl vector50
vector50:
  pushl $0
c01020ca:	6a 00                	push   $0x0
  pushl $50
c01020cc:	6a 32                	push   $0x32
  jmp __alltraps
c01020ce:	e9 21 fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020d3 <vector51>:
.globl vector51
vector51:
  pushl $0
c01020d3:	6a 00                	push   $0x0
  pushl $51
c01020d5:	6a 33                	push   $0x33
  jmp __alltraps
c01020d7:	e9 18 fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020dc <vector52>:
.globl vector52
vector52:
  pushl $0
c01020dc:	6a 00                	push   $0x0
  pushl $52
c01020de:	6a 34                	push   $0x34
  jmp __alltraps
c01020e0:	e9 0f fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020e5 <vector53>:
.globl vector53
vector53:
  pushl $0
c01020e5:	6a 00                	push   $0x0
  pushl $53
c01020e7:	6a 35                	push   $0x35
  jmp __alltraps
c01020e9:	e9 06 fe ff ff       	jmp    c0101ef4 <__alltraps>

c01020ee <vector54>:
.globl vector54
vector54:
  pushl $0
c01020ee:	6a 00                	push   $0x0
  pushl $54
c01020f0:	6a 36                	push   $0x36
  jmp __alltraps
c01020f2:	e9 fd fd ff ff       	jmp    c0101ef4 <__alltraps>

c01020f7 <vector55>:
.globl vector55
vector55:
  pushl $0
c01020f7:	6a 00                	push   $0x0
  pushl $55
c01020f9:	6a 37                	push   $0x37
  jmp __alltraps
c01020fb:	e9 f4 fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102100 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102100:	6a 00                	push   $0x0
  pushl $56
c0102102:	6a 38                	push   $0x38
  jmp __alltraps
c0102104:	e9 eb fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102109 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102109:	6a 00                	push   $0x0
  pushl $57
c010210b:	6a 39                	push   $0x39
  jmp __alltraps
c010210d:	e9 e2 fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102112 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102112:	6a 00                	push   $0x0
  pushl $58
c0102114:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102116:	e9 d9 fd ff ff       	jmp    c0101ef4 <__alltraps>

c010211b <vector59>:
.globl vector59
vector59:
  pushl $0
c010211b:	6a 00                	push   $0x0
  pushl $59
c010211d:	6a 3b                	push   $0x3b
  jmp __alltraps
c010211f:	e9 d0 fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102124 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102124:	6a 00                	push   $0x0
  pushl $60
c0102126:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102128:	e9 c7 fd ff ff       	jmp    c0101ef4 <__alltraps>

c010212d <vector61>:
.globl vector61
vector61:
  pushl $0
c010212d:	6a 00                	push   $0x0
  pushl $61
c010212f:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102131:	e9 be fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102136 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102136:	6a 00                	push   $0x0
  pushl $62
c0102138:	6a 3e                	push   $0x3e
  jmp __alltraps
c010213a:	e9 b5 fd ff ff       	jmp    c0101ef4 <__alltraps>

c010213f <vector63>:
.globl vector63
vector63:
  pushl $0
c010213f:	6a 00                	push   $0x0
  pushl $63
c0102141:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102143:	e9 ac fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102148 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102148:	6a 00                	push   $0x0
  pushl $64
c010214a:	6a 40                	push   $0x40
  jmp __alltraps
c010214c:	e9 a3 fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102151 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102151:	6a 00                	push   $0x0
  pushl $65
c0102153:	6a 41                	push   $0x41
  jmp __alltraps
c0102155:	e9 9a fd ff ff       	jmp    c0101ef4 <__alltraps>

c010215a <vector66>:
.globl vector66
vector66:
  pushl $0
c010215a:	6a 00                	push   $0x0
  pushl $66
c010215c:	6a 42                	push   $0x42
  jmp __alltraps
c010215e:	e9 91 fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102163 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102163:	6a 00                	push   $0x0
  pushl $67
c0102165:	6a 43                	push   $0x43
  jmp __alltraps
c0102167:	e9 88 fd ff ff       	jmp    c0101ef4 <__alltraps>

c010216c <vector68>:
.globl vector68
vector68:
  pushl $0
c010216c:	6a 00                	push   $0x0
  pushl $68
c010216e:	6a 44                	push   $0x44
  jmp __alltraps
c0102170:	e9 7f fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102175 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102175:	6a 00                	push   $0x0
  pushl $69
c0102177:	6a 45                	push   $0x45
  jmp __alltraps
c0102179:	e9 76 fd ff ff       	jmp    c0101ef4 <__alltraps>

c010217e <vector70>:
.globl vector70
vector70:
  pushl $0
c010217e:	6a 00                	push   $0x0
  pushl $70
c0102180:	6a 46                	push   $0x46
  jmp __alltraps
c0102182:	e9 6d fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102187 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102187:	6a 00                	push   $0x0
  pushl $71
c0102189:	6a 47                	push   $0x47
  jmp __alltraps
c010218b:	e9 64 fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102190 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102190:	6a 00                	push   $0x0
  pushl $72
c0102192:	6a 48                	push   $0x48
  jmp __alltraps
c0102194:	e9 5b fd ff ff       	jmp    c0101ef4 <__alltraps>

c0102199 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102199:	6a 00                	push   $0x0
  pushl $73
c010219b:	6a 49                	push   $0x49
  jmp __alltraps
c010219d:	e9 52 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021a2 <vector74>:
.globl vector74
vector74:
  pushl $0
c01021a2:	6a 00                	push   $0x0
  pushl $74
c01021a4:	6a 4a                	push   $0x4a
  jmp __alltraps
c01021a6:	e9 49 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021ab <vector75>:
.globl vector75
vector75:
  pushl $0
c01021ab:	6a 00                	push   $0x0
  pushl $75
c01021ad:	6a 4b                	push   $0x4b
  jmp __alltraps
c01021af:	e9 40 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021b4 <vector76>:
.globl vector76
vector76:
  pushl $0
c01021b4:	6a 00                	push   $0x0
  pushl $76
c01021b6:	6a 4c                	push   $0x4c
  jmp __alltraps
c01021b8:	e9 37 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021bd <vector77>:
.globl vector77
vector77:
  pushl $0
c01021bd:	6a 00                	push   $0x0
  pushl $77
c01021bf:	6a 4d                	push   $0x4d
  jmp __alltraps
c01021c1:	e9 2e fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021c6 <vector78>:
.globl vector78
vector78:
  pushl $0
c01021c6:	6a 00                	push   $0x0
  pushl $78
c01021c8:	6a 4e                	push   $0x4e
  jmp __alltraps
c01021ca:	e9 25 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021cf <vector79>:
.globl vector79
vector79:
  pushl $0
c01021cf:	6a 00                	push   $0x0
  pushl $79
c01021d1:	6a 4f                	push   $0x4f
  jmp __alltraps
c01021d3:	e9 1c fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021d8 <vector80>:
.globl vector80
vector80:
  pushl $0
c01021d8:	6a 00                	push   $0x0
  pushl $80
c01021da:	6a 50                	push   $0x50
  jmp __alltraps
c01021dc:	e9 13 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021e1 <vector81>:
.globl vector81
vector81:
  pushl $0
c01021e1:	6a 00                	push   $0x0
  pushl $81
c01021e3:	6a 51                	push   $0x51
  jmp __alltraps
c01021e5:	e9 0a fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021ea <vector82>:
.globl vector82
vector82:
  pushl $0
c01021ea:	6a 00                	push   $0x0
  pushl $82
c01021ec:	6a 52                	push   $0x52
  jmp __alltraps
c01021ee:	e9 01 fd ff ff       	jmp    c0101ef4 <__alltraps>

c01021f3 <vector83>:
.globl vector83
vector83:
  pushl $0
c01021f3:	6a 00                	push   $0x0
  pushl $83
c01021f5:	6a 53                	push   $0x53
  jmp __alltraps
c01021f7:	e9 f8 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01021fc <vector84>:
.globl vector84
vector84:
  pushl $0
c01021fc:	6a 00                	push   $0x0
  pushl $84
c01021fe:	6a 54                	push   $0x54
  jmp __alltraps
c0102200:	e9 ef fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102205 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102205:	6a 00                	push   $0x0
  pushl $85
c0102207:	6a 55                	push   $0x55
  jmp __alltraps
c0102209:	e9 e6 fc ff ff       	jmp    c0101ef4 <__alltraps>

c010220e <vector86>:
.globl vector86
vector86:
  pushl $0
c010220e:	6a 00                	push   $0x0
  pushl $86
c0102210:	6a 56                	push   $0x56
  jmp __alltraps
c0102212:	e9 dd fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102217 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102217:	6a 00                	push   $0x0
  pushl $87
c0102219:	6a 57                	push   $0x57
  jmp __alltraps
c010221b:	e9 d4 fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102220 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102220:	6a 00                	push   $0x0
  pushl $88
c0102222:	6a 58                	push   $0x58
  jmp __alltraps
c0102224:	e9 cb fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102229 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102229:	6a 00                	push   $0x0
  pushl $89
c010222b:	6a 59                	push   $0x59
  jmp __alltraps
c010222d:	e9 c2 fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102232 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102232:	6a 00                	push   $0x0
  pushl $90
c0102234:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102236:	e9 b9 fc ff ff       	jmp    c0101ef4 <__alltraps>

c010223b <vector91>:
.globl vector91
vector91:
  pushl $0
c010223b:	6a 00                	push   $0x0
  pushl $91
c010223d:	6a 5b                	push   $0x5b
  jmp __alltraps
c010223f:	e9 b0 fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102244 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102244:	6a 00                	push   $0x0
  pushl $92
c0102246:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102248:	e9 a7 fc ff ff       	jmp    c0101ef4 <__alltraps>

c010224d <vector93>:
.globl vector93
vector93:
  pushl $0
c010224d:	6a 00                	push   $0x0
  pushl $93
c010224f:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102251:	e9 9e fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102256 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102256:	6a 00                	push   $0x0
  pushl $94
c0102258:	6a 5e                	push   $0x5e
  jmp __alltraps
c010225a:	e9 95 fc ff ff       	jmp    c0101ef4 <__alltraps>

c010225f <vector95>:
.globl vector95
vector95:
  pushl $0
c010225f:	6a 00                	push   $0x0
  pushl $95
c0102261:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102263:	e9 8c fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102268 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102268:	6a 00                	push   $0x0
  pushl $96
c010226a:	6a 60                	push   $0x60
  jmp __alltraps
c010226c:	e9 83 fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102271 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102271:	6a 00                	push   $0x0
  pushl $97
c0102273:	6a 61                	push   $0x61
  jmp __alltraps
c0102275:	e9 7a fc ff ff       	jmp    c0101ef4 <__alltraps>

c010227a <vector98>:
.globl vector98
vector98:
  pushl $0
c010227a:	6a 00                	push   $0x0
  pushl $98
c010227c:	6a 62                	push   $0x62
  jmp __alltraps
c010227e:	e9 71 fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102283 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102283:	6a 00                	push   $0x0
  pushl $99
c0102285:	6a 63                	push   $0x63
  jmp __alltraps
c0102287:	e9 68 fc ff ff       	jmp    c0101ef4 <__alltraps>

c010228c <vector100>:
.globl vector100
vector100:
  pushl $0
c010228c:	6a 00                	push   $0x0
  pushl $100
c010228e:	6a 64                	push   $0x64
  jmp __alltraps
c0102290:	e9 5f fc ff ff       	jmp    c0101ef4 <__alltraps>

c0102295 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102295:	6a 00                	push   $0x0
  pushl $101
c0102297:	6a 65                	push   $0x65
  jmp __alltraps
c0102299:	e9 56 fc ff ff       	jmp    c0101ef4 <__alltraps>

c010229e <vector102>:
.globl vector102
vector102:
  pushl $0
c010229e:	6a 00                	push   $0x0
  pushl $102
c01022a0:	6a 66                	push   $0x66
  jmp __alltraps
c01022a2:	e9 4d fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022a7 <vector103>:
.globl vector103
vector103:
  pushl $0
c01022a7:	6a 00                	push   $0x0
  pushl $103
c01022a9:	6a 67                	push   $0x67
  jmp __alltraps
c01022ab:	e9 44 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022b0 <vector104>:
.globl vector104
vector104:
  pushl $0
c01022b0:	6a 00                	push   $0x0
  pushl $104
c01022b2:	6a 68                	push   $0x68
  jmp __alltraps
c01022b4:	e9 3b fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022b9 <vector105>:
.globl vector105
vector105:
  pushl $0
c01022b9:	6a 00                	push   $0x0
  pushl $105
c01022bb:	6a 69                	push   $0x69
  jmp __alltraps
c01022bd:	e9 32 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022c2 <vector106>:
.globl vector106
vector106:
  pushl $0
c01022c2:	6a 00                	push   $0x0
  pushl $106
c01022c4:	6a 6a                	push   $0x6a
  jmp __alltraps
c01022c6:	e9 29 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022cb <vector107>:
.globl vector107
vector107:
  pushl $0
c01022cb:	6a 00                	push   $0x0
  pushl $107
c01022cd:	6a 6b                	push   $0x6b
  jmp __alltraps
c01022cf:	e9 20 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022d4 <vector108>:
.globl vector108
vector108:
  pushl $0
c01022d4:	6a 00                	push   $0x0
  pushl $108
c01022d6:	6a 6c                	push   $0x6c
  jmp __alltraps
c01022d8:	e9 17 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022dd <vector109>:
.globl vector109
vector109:
  pushl $0
c01022dd:	6a 00                	push   $0x0
  pushl $109
c01022df:	6a 6d                	push   $0x6d
  jmp __alltraps
c01022e1:	e9 0e fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022e6 <vector110>:
.globl vector110
vector110:
  pushl $0
c01022e6:	6a 00                	push   $0x0
  pushl $110
c01022e8:	6a 6e                	push   $0x6e
  jmp __alltraps
c01022ea:	e9 05 fc ff ff       	jmp    c0101ef4 <__alltraps>

c01022ef <vector111>:
.globl vector111
vector111:
  pushl $0
c01022ef:	6a 00                	push   $0x0
  pushl $111
c01022f1:	6a 6f                	push   $0x6f
  jmp __alltraps
c01022f3:	e9 fc fb ff ff       	jmp    c0101ef4 <__alltraps>

c01022f8 <vector112>:
.globl vector112
vector112:
  pushl $0
c01022f8:	6a 00                	push   $0x0
  pushl $112
c01022fa:	6a 70                	push   $0x70
  jmp __alltraps
c01022fc:	e9 f3 fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102301 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102301:	6a 00                	push   $0x0
  pushl $113
c0102303:	6a 71                	push   $0x71
  jmp __alltraps
c0102305:	e9 ea fb ff ff       	jmp    c0101ef4 <__alltraps>

c010230a <vector114>:
.globl vector114
vector114:
  pushl $0
c010230a:	6a 00                	push   $0x0
  pushl $114
c010230c:	6a 72                	push   $0x72
  jmp __alltraps
c010230e:	e9 e1 fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102313 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102313:	6a 00                	push   $0x0
  pushl $115
c0102315:	6a 73                	push   $0x73
  jmp __alltraps
c0102317:	e9 d8 fb ff ff       	jmp    c0101ef4 <__alltraps>

c010231c <vector116>:
.globl vector116
vector116:
  pushl $0
c010231c:	6a 00                	push   $0x0
  pushl $116
c010231e:	6a 74                	push   $0x74
  jmp __alltraps
c0102320:	e9 cf fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102325 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102325:	6a 00                	push   $0x0
  pushl $117
c0102327:	6a 75                	push   $0x75
  jmp __alltraps
c0102329:	e9 c6 fb ff ff       	jmp    c0101ef4 <__alltraps>

c010232e <vector118>:
.globl vector118
vector118:
  pushl $0
c010232e:	6a 00                	push   $0x0
  pushl $118
c0102330:	6a 76                	push   $0x76
  jmp __alltraps
c0102332:	e9 bd fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102337 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102337:	6a 00                	push   $0x0
  pushl $119
c0102339:	6a 77                	push   $0x77
  jmp __alltraps
c010233b:	e9 b4 fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102340 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102340:	6a 00                	push   $0x0
  pushl $120
c0102342:	6a 78                	push   $0x78
  jmp __alltraps
c0102344:	e9 ab fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102349 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102349:	6a 00                	push   $0x0
  pushl $121
c010234b:	6a 79                	push   $0x79
  jmp __alltraps
c010234d:	e9 a2 fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102352 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102352:	6a 00                	push   $0x0
  pushl $122
c0102354:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102356:	e9 99 fb ff ff       	jmp    c0101ef4 <__alltraps>

c010235b <vector123>:
.globl vector123
vector123:
  pushl $0
c010235b:	6a 00                	push   $0x0
  pushl $123
c010235d:	6a 7b                	push   $0x7b
  jmp __alltraps
c010235f:	e9 90 fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102364 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102364:	6a 00                	push   $0x0
  pushl $124
c0102366:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102368:	e9 87 fb ff ff       	jmp    c0101ef4 <__alltraps>

c010236d <vector125>:
.globl vector125
vector125:
  pushl $0
c010236d:	6a 00                	push   $0x0
  pushl $125
c010236f:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102371:	e9 7e fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102376 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102376:	6a 00                	push   $0x0
  pushl $126
c0102378:	6a 7e                	push   $0x7e
  jmp __alltraps
c010237a:	e9 75 fb ff ff       	jmp    c0101ef4 <__alltraps>

c010237f <vector127>:
.globl vector127
vector127:
  pushl $0
c010237f:	6a 00                	push   $0x0
  pushl $127
c0102381:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102383:	e9 6c fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102388 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102388:	6a 00                	push   $0x0
  pushl $128
c010238a:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010238f:	e9 60 fb ff ff       	jmp    c0101ef4 <__alltraps>

c0102394 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102394:	6a 00                	push   $0x0
  pushl $129
c0102396:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010239b:	e9 54 fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023a0 <vector130>:
.globl vector130
vector130:
  pushl $0
c01023a0:	6a 00                	push   $0x0
  pushl $130
c01023a2:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01023a7:	e9 48 fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023ac <vector131>:
.globl vector131
vector131:
  pushl $0
c01023ac:	6a 00                	push   $0x0
  pushl $131
c01023ae:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01023b3:	e9 3c fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023b8 <vector132>:
.globl vector132
vector132:
  pushl $0
c01023b8:	6a 00                	push   $0x0
  pushl $132
c01023ba:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01023bf:	e9 30 fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023c4 <vector133>:
.globl vector133
vector133:
  pushl $0
c01023c4:	6a 00                	push   $0x0
  pushl $133
c01023c6:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01023cb:	e9 24 fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023d0 <vector134>:
.globl vector134
vector134:
  pushl $0
c01023d0:	6a 00                	push   $0x0
  pushl $134
c01023d2:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01023d7:	e9 18 fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023dc <vector135>:
.globl vector135
vector135:
  pushl $0
c01023dc:	6a 00                	push   $0x0
  pushl $135
c01023de:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01023e3:	e9 0c fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023e8 <vector136>:
.globl vector136
vector136:
  pushl $0
c01023e8:	6a 00                	push   $0x0
  pushl $136
c01023ea:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01023ef:	e9 00 fb ff ff       	jmp    c0101ef4 <__alltraps>

c01023f4 <vector137>:
.globl vector137
vector137:
  pushl $0
c01023f4:	6a 00                	push   $0x0
  pushl $137
c01023f6:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01023fb:	e9 f4 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102400 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102400:	6a 00                	push   $0x0
  pushl $138
c0102402:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102407:	e9 e8 fa ff ff       	jmp    c0101ef4 <__alltraps>

c010240c <vector139>:
.globl vector139
vector139:
  pushl $0
c010240c:	6a 00                	push   $0x0
  pushl $139
c010240e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102413:	e9 dc fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102418 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102418:	6a 00                	push   $0x0
  pushl $140
c010241a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010241f:	e9 d0 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102424 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102424:	6a 00                	push   $0x0
  pushl $141
c0102426:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010242b:	e9 c4 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102430 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102430:	6a 00                	push   $0x0
  pushl $142
c0102432:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102437:	e9 b8 fa ff ff       	jmp    c0101ef4 <__alltraps>

c010243c <vector143>:
.globl vector143
vector143:
  pushl $0
c010243c:	6a 00                	push   $0x0
  pushl $143
c010243e:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102443:	e9 ac fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102448 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102448:	6a 00                	push   $0x0
  pushl $144
c010244a:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010244f:	e9 a0 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102454 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102454:	6a 00                	push   $0x0
  pushl $145
c0102456:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010245b:	e9 94 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102460 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102460:	6a 00                	push   $0x0
  pushl $146
c0102462:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102467:	e9 88 fa ff ff       	jmp    c0101ef4 <__alltraps>

c010246c <vector147>:
.globl vector147
vector147:
  pushl $0
c010246c:	6a 00                	push   $0x0
  pushl $147
c010246e:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102473:	e9 7c fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102478 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102478:	6a 00                	push   $0x0
  pushl $148
c010247a:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010247f:	e9 70 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102484 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102484:	6a 00                	push   $0x0
  pushl $149
c0102486:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010248b:	e9 64 fa ff ff       	jmp    c0101ef4 <__alltraps>

c0102490 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102490:	6a 00                	push   $0x0
  pushl $150
c0102492:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102497:	e9 58 fa ff ff       	jmp    c0101ef4 <__alltraps>

c010249c <vector151>:
.globl vector151
vector151:
  pushl $0
c010249c:	6a 00                	push   $0x0
  pushl $151
c010249e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01024a3:	e9 4c fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024a8 <vector152>:
.globl vector152
vector152:
  pushl $0
c01024a8:	6a 00                	push   $0x0
  pushl $152
c01024aa:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01024af:	e9 40 fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024b4 <vector153>:
.globl vector153
vector153:
  pushl $0
c01024b4:	6a 00                	push   $0x0
  pushl $153
c01024b6:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01024bb:	e9 34 fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024c0 <vector154>:
.globl vector154
vector154:
  pushl $0
c01024c0:	6a 00                	push   $0x0
  pushl $154
c01024c2:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01024c7:	e9 28 fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024cc <vector155>:
.globl vector155
vector155:
  pushl $0
c01024cc:	6a 00                	push   $0x0
  pushl $155
c01024ce:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01024d3:	e9 1c fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024d8 <vector156>:
.globl vector156
vector156:
  pushl $0
c01024d8:	6a 00                	push   $0x0
  pushl $156
c01024da:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01024df:	e9 10 fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024e4 <vector157>:
.globl vector157
vector157:
  pushl $0
c01024e4:	6a 00                	push   $0x0
  pushl $157
c01024e6:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01024eb:	e9 04 fa ff ff       	jmp    c0101ef4 <__alltraps>

c01024f0 <vector158>:
.globl vector158
vector158:
  pushl $0
c01024f0:	6a 00                	push   $0x0
  pushl $158
c01024f2:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01024f7:	e9 f8 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01024fc <vector159>:
.globl vector159
vector159:
  pushl $0
c01024fc:	6a 00                	push   $0x0
  pushl $159
c01024fe:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102503:	e9 ec f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102508 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102508:	6a 00                	push   $0x0
  pushl $160
c010250a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010250f:	e9 e0 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102514 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102514:	6a 00                	push   $0x0
  pushl $161
c0102516:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010251b:	e9 d4 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102520 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102520:	6a 00                	push   $0x0
  pushl $162
c0102522:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102527:	e9 c8 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c010252c <vector163>:
.globl vector163
vector163:
  pushl $0
c010252c:	6a 00                	push   $0x0
  pushl $163
c010252e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102533:	e9 bc f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102538 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102538:	6a 00                	push   $0x0
  pushl $164
c010253a:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010253f:	e9 b0 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102544 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102544:	6a 00                	push   $0x0
  pushl $165
c0102546:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010254b:	e9 a4 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102550 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102550:	6a 00                	push   $0x0
  pushl $166
c0102552:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102557:	e9 98 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c010255c <vector167>:
.globl vector167
vector167:
  pushl $0
c010255c:	6a 00                	push   $0x0
  pushl $167
c010255e:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102563:	e9 8c f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102568 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102568:	6a 00                	push   $0x0
  pushl $168
c010256a:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010256f:	e9 80 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102574 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102574:	6a 00                	push   $0x0
  pushl $169
c0102576:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010257b:	e9 74 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102580 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102580:	6a 00                	push   $0x0
  pushl $170
c0102582:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102587:	e9 68 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c010258c <vector171>:
.globl vector171
vector171:
  pushl $0
c010258c:	6a 00                	push   $0x0
  pushl $171
c010258e:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102593:	e9 5c f9 ff ff       	jmp    c0101ef4 <__alltraps>

c0102598 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102598:	6a 00                	push   $0x0
  pushl $172
c010259a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010259f:	e9 50 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025a4 <vector173>:
.globl vector173
vector173:
  pushl $0
c01025a4:	6a 00                	push   $0x0
  pushl $173
c01025a6:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01025ab:	e9 44 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025b0 <vector174>:
.globl vector174
vector174:
  pushl $0
c01025b0:	6a 00                	push   $0x0
  pushl $174
c01025b2:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01025b7:	e9 38 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025bc <vector175>:
.globl vector175
vector175:
  pushl $0
c01025bc:	6a 00                	push   $0x0
  pushl $175
c01025be:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01025c3:	e9 2c f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025c8 <vector176>:
.globl vector176
vector176:
  pushl $0
c01025c8:	6a 00                	push   $0x0
  pushl $176
c01025ca:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01025cf:	e9 20 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025d4 <vector177>:
.globl vector177
vector177:
  pushl $0
c01025d4:	6a 00                	push   $0x0
  pushl $177
c01025d6:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01025db:	e9 14 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025e0 <vector178>:
.globl vector178
vector178:
  pushl $0
c01025e0:	6a 00                	push   $0x0
  pushl $178
c01025e2:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01025e7:	e9 08 f9 ff ff       	jmp    c0101ef4 <__alltraps>

c01025ec <vector179>:
.globl vector179
vector179:
  pushl $0
c01025ec:	6a 00                	push   $0x0
  pushl $179
c01025ee:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01025f3:	e9 fc f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01025f8 <vector180>:
.globl vector180
vector180:
  pushl $0
c01025f8:	6a 00                	push   $0x0
  pushl $180
c01025fa:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01025ff:	e9 f0 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102604 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102604:	6a 00                	push   $0x0
  pushl $181
c0102606:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010260b:	e9 e4 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102610 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102610:	6a 00                	push   $0x0
  pushl $182
c0102612:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102617:	e9 d8 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c010261c <vector183>:
.globl vector183
vector183:
  pushl $0
c010261c:	6a 00                	push   $0x0
  pushl $183
c010261e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102623:	e9 cc f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102628 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102628:	6a 00                	push   $0x0
  pushl $184
c010262a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010262f:	e9 c0 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102634 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102634:	6a 00                	push   $0x0
  pushl $185
c0102636:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010263b:	e9 b4 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102640 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102640:	6a 00                	push   $0x0
  pushl $186
c0102642:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102647:	e9 a8 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c010264c <vector187>:
.globl vector187
vector187:
  pushl $0
c010264c:	6a 00                	push   $0x0
  pushl $187
c010264e:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102653:	e9 9c f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102658 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102658:	6a 00                	push   $0x0
  pushl $188
c010265a:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010265f:	e9 90 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102664 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102664:	6a 00                	push   $0x0
  pushl $189
c0102666:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010266b:	e9 84 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102670 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102670:	6a 00                	push   $0x0
  pushl $190
c0102672:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102677:	e9 78 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c010267c <vector191>:
.globl vector191
vector191:
  pushl $0
c010267c:	6a 00                	push   $0x0
  pushl $191
c010267e:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102683:	e9 6c f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102688 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102688:	6a 00                	push   $0x0
  pushl $192
c010268a:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010268f:	e9 60 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c0102694 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102694:	6a 00                	push   $0x0
  pushl $193
c0102696:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010269b:	e9 54 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026a0 <vector194>:
.globl vector194
vector194:
  pushl $0
c01026a0:	6a 00                	push   $0x0
  pushl $194
c01026a2:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01026a7:	e9 48 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026ac <vector195>:
.globl vector195
vector195:
  pushl $0
c01026ac:	6a 00                	push   $0x0
  pushl $195
c01026ae:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01026b3:	e9 3c f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026b8 <vector196>:
.globl vector196
vector196:
  pushl $0
c01026b8:	6a 00                	push   $0x0
  pushl $196
c01026ba:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01026bf:	e9 30 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026c4 <vector197>:
.globl vector197
vector197:
  pushl $0
c01026c4:	6a 00                	push   $0x0
  pushl $197
c01026c6:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01026cb:	e9 24 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026d0 <vector198>:
.globl vector198
vector198:
  pushl $0
c01026d0:	6a 00                	push   $0x0
  pushl $198
c01026d2:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01026d7:	e9 18 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026dc <vector199>:
.globl vector199
vector199:
  pushl $0
c01026dc:	6a 00                	push   $0x0
  pushl $199
c01026de:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01026e3:	e9 0c f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026e8 <vector200>:
.globl vector200
vector200:
  pushl $0
c01026e8:	6a 00                	push   $0x0
  pushl $200
c01026ea:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01026ef:	e9 00 f8 ff ff       	jmp    c0101ef4 <__alltraps>

c01026f4 <vector201>:
.globl vector201
vector201:
  pushl $0
c01026f4:	6a 00                	push   $0x0
  pushl $201
c01026f6:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01026fb:	e9 f4 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102700 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102700:	6a 00                	push   $0x0
  pushl $202
c0102702:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102707:	e9 e8 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c010270c <vector203>:
.globl vector203
vector203:
  pushl $0
c010270c:	6a 00                	push   $0x0
  pushl $203
c010270e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102713:	e9 dc f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102718 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102718:	6a 00                	push   $0x0
  pushl $204
c010271a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010271f:	e9 d0 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102724 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102724:	6a 00                	push   $0x0
  pushl $205
c0102726:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010272b:	e9 c4 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102730 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102730:	6a 00                	push   $0x0
  pushl $206
c0102732:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102737:	e9 b8 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c010273c <vector207>:
.globl vector207
vector207:
  pushl $0
c010273c:	6a 00                	push   $0x0
  pushl $207
c010273e:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102743:	e9 ac f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102748 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102748:	6a 00                	push   $0x0
  pushl $208
c010274a:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010274f:	e9 a0 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102754 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102754:	6a 00                	push   $0x0
  pushl $209
c0102756:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010275b:	e9 94 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102760 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102760:	6a 00                	push   $0x0
  pushl $210
c0102762:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102767:	e9 88 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c010276c <vector211>:
.globl vector211
vector211:
  pushl $0
c010276c:	6a 00                	push   $0x0
  pushl $211
c010276e:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102773:	e9 7c f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102778 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102778:	6a 00                	push   $0x0
  pushl $212
c010277a:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010277f:	e9 70 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102784 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102784:	6a 00                	push   $0x0
  pushl $213
c0102786:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010278b:	e9 64 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c0102790 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102790:	6a 00                	push   $0x0
  pushl $214
c0102792:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102797:	e9 58 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c010279c <vector215>:
.globl vector215
vector215:
  pushl $0
c010279c:	6a 00                	push   $0x0
  pushl $215
c010279e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01027a3:	e9 4c f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027a8 <vector216>:
.globl vector216
vector216:
  pushl $0
c01027a8:	6a 00                	push   $0x0
  pushl $216
c01027aa:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01027af:	e9 40 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027b4 <vector217>:
.globl vector217
vector217:
  pushl $0
c01027b4:	6a 00                	push   $0x0
  pushl $217
c01027b6:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01027bb:	e9 34 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027c0 <vector218>:
.globl vector218
vector218:
  pushl $0
c01027c0:	6a 00                	push   $0x0
  pushl $218
c01027c2:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01027c7:	e9 28 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027cc <vector219>:
.globl vector219
vector219:
  pushl $0
c01027cc:	6a 00                	push   $0x0
  pushl $219
c01027ce:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01027d3:	e9 1c f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027d8 <vector220>:
.globl vector220
vector220:
  pushl $0
c01027d8:	6a 00                	push   $0x0
  pushl $220
c01027da:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01027df:	e9 10 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027e4 <vector221>:
.globl vector221
vector221:
  pushl $0
c01027e4:	6a 00                	push   $0x0
  pushl $221
c01027e6:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01027eb:	e9 04 f7 ff ff       	jmp    c0101ef4 <__alltraps>

c01027f0 <vector222>:
.globl vector222
vector222:
  pushl $0
c01027f0:	6a 00                	push   $0x0
  pushl $222
c01027f2:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01027f7:	e9 f8 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01027fc <vector223>:
.globl vector223
vector223:
  pushl $0
c01027fc:	6a 00                	push   $0x0
  pushl $223
c01027fe:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102803:	e9 ec f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102808 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102808:	6a 00                	push   $0x0
  pushl $224
c010280a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010280f:	e9 e0 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102814 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102814:	6a 00                	push   $0x0
  pushl $225
c0102816:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010281b:	e9 d4 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102820 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102820:	6a 00                	push   $0x0
  pushl $226
c0102822:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102827:	e9 c8 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c010282c <vector227>:
.globl vector227
vector227:
  pushl $0
c010282c:	6a 00                	push   $0x0
  pushl $227
c010282e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102833:	e9 bc f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102838 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102838:	6a 00                	push   $0x0
  pushl $228
c010283a:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010283f:	e9 b0 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102844 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102844:	6a 00                	push   $0x0
  pushl $229
c0102846:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010284b:	e9 a4 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102850 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102850:	6a 00                	push   $0x0
  pushl $230
c0102852:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102857:	e9 98 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c010285c <vector231>:
.globl vector231
vector231:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $231
c010285e:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102863:	e9 8c f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102868 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102868:	6a 00                	push   $0x0
  pushl $232
c010286a:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010286f:	e9 80 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102874 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102874:	6a 00                	push   $0x0
  pushl $233
c0102876:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010287b:	e9 74 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102880 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $234
c0102882:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102887:	e9 68 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c010288c <vector235>:
.globl vector235
vector235:
  pushl $0
c010288c:	6a 00                	push   $0x0
  pushl $235
c010288e:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102893:	e9 5c f6 ff ff       	jmp    c0101ef4 <__alltraps>

c0102898 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102898:	6a 00                	push   $0x0
  pushl $236
c010289a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010289f:	e9 50 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028a4 <vector237>:
.globl vector237
vector237:
  pushl $0
c01028a4:	6a 00                	push   $0x0
  pushl $237
c01028a6:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01028ab:	e9 44 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028b0 <vector238>:
.globl vector238
vector238:
  pushl $0
c01028b0:	6a 00                	push   $0x0
  pushl $238
c01028b2:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01028b7:	e9 38 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028bc <vector239>:
.globl vector239
vector239:
  pushl $0
c01028bc:	6a 00                	push   $0x0
  pushl $239
c01028be:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01028c3:	e9 2c f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028c8 <vector240>:
.globl vector240
vector240:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $240
c01028ca:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01028cf:	e9 20 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028d4 <vector241>:
.globl vector241
vector241:
  pushl $0
c01028d4:	6a 00                	push   $0x0
  pushl $241
c01028d6:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01028db:	e9 14 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028e0 <vector242>:
.globl vector242
vector242:
  pushl $0
c01028e0:	6a 00                	push   $0x0
  pushl $242
c01028e2:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01028e7:	e9 08 f6 ff ff       	jmp    c0101ef4 <__alltraps>

c01028ec <vector243>:
.globl vector243
vector243:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $243
c01028ee:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01028f3:	e9 fc f5 ff ff       	jmp    c0101ef4 <__alltraps>

c01028f8 <vector244>:
.globl vector244
vector244:
  pushl $0
c01028f8:	6a 00                	push   $0x0
  pushl $244
c01028fa:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01028ff:	e9 f0 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102904 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102904:	6a 00                	push   $0x0
  pushl $245
c0102906:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010290b:	e9 e4 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102910 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $246
c0102912:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102917:	e9 d8 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c010291c <vector247>:
.globl vector247
vector247:
  pushl $0
c010291c:	6a 00                	push   $0x0
  pushl $247
c010291e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102923:	e9 cc f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102928 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102928:	6a 00                	push   $0x0
  pushl $248
c010292a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010292f:	e9 c0 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102934 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $249
c0102936:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010293b:	e9 b4 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102940 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102940:	6a 00                	push   $0x0
  pushl $250
c0102942:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102947:	e9 a8 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c010294c <vector251>:
.globl vector251
vector251:
  pushl $0
c010294c:	6a 00                	push   $0x0
  pushl $251
c010294e:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102953:	e9 9c f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102958 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $252
c010295a:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010295f:	e9 90 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102964 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102964:	6a 00                	push   $0x0
  pushl $253
c0102966:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010296b:	e9 84 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102970 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102970:	6a 00                	push   $0x0
  pushl $254
c0102972:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102977:	e9 78 f5 ff ff       	jmp    c0101ef4 <__alltraps>

c010297c <vector255>:
.globl vector255
vector255:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $255
c010297e:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102983:	e9 6c f5 ff ff       	jmp    c0101ef4 <__alltraps>

c0102988 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102988:	55                   	push   %ebp
c0102989:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010298b:	8b 15 a0 ce 11 c0    	mov    0xc011cea0,%edx
c0102991:	8b 45 08             	mov    0x8(%ebp),%eax
c0102994:	29 d0                	sub    %edx,%eax
c0102996:	c1 f8 02             	sar    $0x2,%eax
c0102999:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010299f:	5d                   	pop    %ebp
c01029a0:	c3                   	ret    

c01029a1 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01029a1:	55                   	push   %ebp
c01029a2:	89 e5                	mov    %esp,%ebp
c01029a4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01029a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01029aa:	89 04 24             	mov    %eax,(%esp)
c01029ad:	e8 d6 ff ff ff       	call   c0102988 <page2ppn>
c01029b2:	c1 e0 0c             	shl    $0xc,%eax
}
c01029b5:	89 ec                	mov    %ebp,%esp
c01029b7:	5d                   	pop    %ebp
c01029b8:	c3                   	ret    

c01029b9 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01029b9:	55                   	push   %ebp
c01029ba:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01029bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01029bf:	8b 00                	mov    (%eax),%eax
}
c01029c1:	5d                   	pop    %ebp
c01029c2:	c3                   	ret    

c01029c3 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01029c3:	55                   	push   %ebp
c01029c4:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01029c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029cc:	89 10                	mov    %edx,(%eax)
}
c01029ce:	90                   	nop
c01029cf:	5d                   	pop    %ebp
c01029d0:	c3                   	ret    

c01029d1 <default_init>:
//free_list本身不会对应Page结构
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01029d1:	55                   	push   %ebp
c01029d2:	89 e5                	mov    %esp,%ebp
c01029d4:	83 ec 10             	sub    $0x10,%esp
c01029d7:	c7 45 fc 80 ce 11 c0 	movl   $0xc011ce80,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01029de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01029e4:	89 50 04             	mov    %edx,0x4(%eax)
c01029e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029ea:	8b 50 04             	mov    0x4(%eax),%edx
c01029ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029f0:	89 10                	mov    %edx,(%eax)
}
c01029f2:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c01029f3:	c7 05 88 ce 11 c0 00 	movl   $0x0,0xc011ce88
c01029fa:	00 00 00 
}
c01029fd:	90                   	nop
c01029fe:	89 ec                	mov    %ebp,%esp
c0102a00:	5d                   	pop    %ebp
c0102a01:	c3                   	ret    

c0102a02 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102a02:	55                   	push   %ebp
c0102a03:	89 e5                	mov    %esp,%ebp
c0102a05:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0102a08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102a0c:	75 24                	jne    c0102a32 <default_init_memmap+0x30>
c0102a0e:	c7 44 24 0c 10 69 10 	movl   $0xc0106910,0xc(%esp)
c0102a15:	c0 
c0102a16:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0102a1d:	c0 
c0102a1e:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c0102a25:	00 
c0102a26:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0102a2d:	e8 cd e2 ff ff       	call   c0100cff <__panic>
    struct Page *p = base;
c0102a32:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //相邻的page结构在内存上也是相邻的
    for (; p != base + n; p ++) {
c0102a38:	e9 97 00 00 00       	jmp    c0102ad4 <default_init_memmap+0xd2>
        //检查是否被保留,是否有问题，
        assert(PageReserved(p));
c0102a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a40:	83 c0 04             	add    $0x4,%eax
c0102a43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102a4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a50:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102a53:	0f a3 10             	bt     %edx,(%eax)
c0102a56:	19 c0                	sbb    %eax,%eax
c0102a58:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102a5b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102a5f:	0f 95 c0             	setne  %al
c0102a62:	0f b6 c0             	movzbl %al,%eax
c0102a65:	85 c0                	test   %eax,%eax
c0102a67:	75 24                	jne    c0102a8d <default_init_memmap+0x8b>
c0102a69:	c7 44 24 0c 41 69 10 	movl   $0xc0106941,0xc(%esp)
c0102a70:	c0 
c0102a71:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0102a78:	c0 
c0102a79:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0102a80:	00 
c0102a81:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0102a88:	e8 72 e2 ff ff       	call   c0100cff <__panic>
        p->flags = p->property = 0;
c0102a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a90:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a9a:	8b 50 08             	mov    0x8(%eax),%edx
c0102a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102aa0:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0102aa3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102aaa:	00 
c0102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102aae:	89 04 24             	mov    %eax,(%esp)
c0102ab1:	e8 0d ff ff ff       	call   c01029c3 <set_page_ref>
        //my_add
        SetPageProperty(p);
c0102ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ab9:	83 c0 04             	add    $0x4,%eax
c0102abc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102ac3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ac9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102acc:	0f ab 10             	bts    %edx,(%eax)
}
c0102acf:	90                   	nop
    for (; p != base + n; p ++) {
c0102ad0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ad7:	89 d0                	mov    %edx,%eax
c0102ad9:	c1 e0 02             	shl    $0x2,%eax
c0102adc:	01 d0                	add    %edx,%eax
c0102ade:	c1 e0 02             	shl    $0x2,%eax
c0102ae1:	89 c2                	mov    %eax,%edx
c0102ae3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ae6:	01 d0                	add    %edx,%eax
c0102ae8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102aeb:	0f 85 4c ff ff ff    	jne    c0102a3d <default_init_memmap+0x3b>

    }
    base->property = n;
c0102af1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102af4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102af7:	89 50 08             	mov    %edx,0x8(%eax)
    //置位标志位代表可以分配
   //SetPageProperty(base);
    nr_free += n;
c0102afa:	8b 15 88 ce 11 c0    	mov    0xc011ce88,%edx
c0102b00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102b03:	01 d0                	add    %edx,%eax
c0102b05:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88
    list_add(&free_list, &(base->page_link));
c0102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b0d:	83 c0 0c             	add    $0xc,%eax
c0102b10:	c7 45 dc 80 ce 11 c0 	movl   $0xc011ce80,-0x24(%ebp)
c0102b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0102b1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b23:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102b26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102b29:	8b 40 04             	mov    0x4(%eax),%eax
c0102b2c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b2f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102b32:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b35:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102b38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * the prev/next entries already!
 * */
//前面带有两个横杠代表为各种调用函数的“基函数”，实质上不会调用，为了保持函数具有一个比较好的封装性。
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102b3e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b41:	89 10                	mov    %edx,(%eax)
c0102b43:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102b46:	8b 10                	mov    (%eax),%edx
c0102b48:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b4b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b4e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b51:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102b54:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b57:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b5a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102b5d:	89 10                	mov    %edx,(%eax)
}
c0102b5f:	90                   	nop
}
c0102b60:	90                   	nop
}
c0102b61:	90                   	nop
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
c0102b62:	90                   	nop
c0102b63:	89 ec                	mov    %ebp,%esp
c0102b65:	5d                   	pop    %ebp
c0102b66:	c3                   	ret    

c0102b67 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102b67:	55                   	push   %ebp
c0102b68:	89 e5                	mov    %esp,%ebp
c0102b6a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102b6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102b71:	75 24                	jne    c0102b97 <default_alloc_pages+0x30>
c0102b73:	c7 44 24 0c 10 69 10 	movl   $0xc0106910,0xc(%esp)
c0102b7a:	c0 
c0102b7b:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0102b82:	c0 
c0102b83:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0102b8a:	00 
c0102b8b:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0102b92:	e8 68 e1 ff ff       	call   c0100cff <__panic>
    if (n > nr_free) {
c0102b97:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102b9c:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102b9f:	76 0a                	jbe    c0102bab <default_alloc_pages+0x44>
        return NULL;
c0102ba1:	b8 00 00 00 00       	mov    $0x0,%eax
c0102ba6:	e9 82 01 00 00       	jmp    c0102d2d <default_alloc_pages+0x1c6>
    }
    struct Page *page = NULL;
c0102bab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102bb2:	c7 45 f0 80 ce 11 c0 	movl   $0xc011ce80,-0x10(%ebp)

    //遍历free_list
    while ((le = list_next(le)) != &free_list) {
c0102bb9:	eb 1c                	jmp    c0102bd7 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bbe:	83 e8 0c             	sub    $0xc,%eax
c0102bc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0102bc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bc7:	8b 40 08             	mov    0x8(%eax),%eax
c0102bca:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102bcd:	77 08                	ja     c0102bd7 <default_alloc_pages+0x70>
            page = p;
c0102bcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102bd5:	eb 18                	jmp    c0102bef <default_alloc_pages+0x88>
c0102bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bda:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0102bdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102be0:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0102be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102be6:	81 7d f0 80 ce 11 c0 	cmpl   $0xc011ce80,-0x10(%ebp)
c0102bed:	75 cc                	jne    c0102bbb <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0102bef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102bf3:	0f 84 31 01 00 00    	je     c0102d2a <default_alloc_pages+0x1c3>
        struct Page *temp=page;
c0102bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for(;temp!=page+n;temp++)
c0102bff:	eb 1e                	jmp    c0102c1f <default_alloc_pages+0xb8>
            ClearPageProperty(temp);
c0102c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c04:	83 c0 04             	add    $0x4,%eax
c0102c07:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0102c0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102c11:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102c14:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c17:	0f b3 10             	btr    %edx,(%eax)
}
c0102c1a:	90                   	nop
        for(;temp!=page+n;temp++)
c0102c1b:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
c0102c1f:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c22:	89 d0                	mov    %edx,%eax
c0102c24:	c1 e0 02             	shl    $0x2,%eax
c0102c27:	01 d0                	add    %edx,%eax
c0102c29:	c1 e0 02             	shl    $0x2,%eax
c0102c2c:	89 c2                	mov    %eax,%edx
c0102c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c31:	01 d0                	add    %edx,%eax
c0102c33:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0102c36:	75 c9                	jne    c0102c01 <default_alloc_pages+0x9a>
        if (page->property > n) {
c0102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c3b:	8b 40 08             	mov    0x8(%eax),%eax
c0102c3e:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102c41:	0f 83 8f 00 00 00    	jae    c0102cd6 <default_alloc_pages+0x16f>
            struct Page *p = page + n;
c0102c47:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c4a:	89 d0                	mov    %edx,%eax
c0102c4c:	c1 e0 02             	shl    $0x2,%eax
c0102c4f:	01 d0                	add    %edx,%eax
c0102c51:	c1 e0 02             	shl    $0x2,%eax
c0102c54:	89 c2                	mov    %eax,%edx
c0102c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c59:	01 d0                	add    %edx,%eax
c0102c5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c61:	8b 40 08             	mov    0x8(%eax),%eax
c0102c64:	2b 45 08             	sub    0x8(%ebp),%eax
c0102c67:	89 c2                	mov    %eax,%edx
c0102c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102c6c:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102c6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102c72:	83 c0 04             	add    $0x4,%eax
c0102c75:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102c7c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102c7f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102c82:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102c85:	0f ab 10             	bts    %edx,(%eax)
}
c0102c88:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c0102c89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102c8c:	83 c0 0c             	add    $0xc,%eax
c0102c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102c92:	83 c2 0c             	add    $0xc,%edx
c0102c95:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102c98:	89 45 d0             	mov    %eax,-0x30(%ebp)
    __list_add(elm, listelm, listelm->next);
c0102c9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102c9e:	8b 40 04             	mov    0x4(%eax),%eax
c0102ca1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102ca4:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102ca7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102caa:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102cad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c0102cb0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102cb3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102cb6:	89 10                	mov    %edx,(%eax)
c0102cb8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102cbb:	8b 10                	mov    (%eax),%edx
c0102cbd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102cc0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102cc3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102cc6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102cc9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102ccc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102ccf:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102cd2:	89 10                	mov    %edx,(%eax)
}
c0102cd4:	90                   	nop
}
c0102cd5:	90                   	nop
        }
        list_del(&(page->page_link));
c0102cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cd9:	83 c0 0c             	add    $0xc,%eax
c0102cdc:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102cdf:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102ce2:	8b 40 04             	mov    0x4(%eax),%eax
c0102ce5:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102ce8:	8b 12                	mov    (%edx),%edx
c0102cea:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0102ced:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102cf0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102cf3:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102cf6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102cf9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102cfc:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102cff:	89 10                	mov    %edx,(%eax)
}
c0102d01:	90                   	nop
}
c0102d02:	90                   	nop
        nr_free -= n;
c0102d03:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102d08:	2b 45 08             	sub    0x8(%ebp),%eax
c0102d0b:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88
        ClearPageProperty(page);
c0102d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d13:	83 c0 04             	add    $0x4,%eax
c0102d16:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102d1d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d20:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102d23:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102d26:	0f b3 10             	btr    %edx,(%eax)
}
c0102d29:	90                   	nop
    }
    return page;
c0102d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;*/
}
c0102d2d:	89 ec                	mov    %ebp,%esp
c0102d2f:	5d                   	pop    %ebp
c0102d30:	c3                   	ret    

c0102d31 <merge_backward>:

static bool merge_backward(struct  Page*base)
{
c0102d31:	55                   	push   %ebp
c0102d32:	89 e5                	mov    %esp,%ebp
c0102d34:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_next(&(base->page_link));
c0102d37:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d3a:	83 c0 0c             	add    $0xc,%eax
c0102d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->next;
c0102d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d43:	8b 40 04             	mov    0x4(%eax),%eax
c0102d46:	89 45 fc             	mov    %eax,-0x4(%ebp)
    //判断是否为头节点
    if (le==&free_list)
c0102d49:	81 7d fc 80 ce 11 c0 	cmpl   $0xc011ce80,-0x4(%ebp)
c0102d50:	75 0a                	jne    c0102d5c <merge_backward+0x2b>
    return 0;
c0102d52:	b8 00 00 00 00       	mov    $0x0,%eax
c0102d57:	e9 ac 00 00 00       	jmp    c0102e08 <merge_backward+0xd7>
    struct Page*p=le2page(le,page_link);
c0102d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102d5f:	83 e8 0c             	sub    $0xc,%eax
c0102d62:	89 45 f8             	mov    %eax,-0x8(%ebp)
    
    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c0102d65:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102d68:	83 c0 04             	add    $0x4,%eax
c0102d6b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102d72:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102d75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102d78:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102d7b:	0f a3 10             	bt     %edx,(%eax)
c0102d7e:	19 c0                	sbb    %eax,%eax
c0102d80:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102d83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102d87:	0f 95 c0             	setne  %al
c0102d8a:	0f b6 c0             	movzbl %al,%eax
c0102d8d:	85 c0                	test   %eax,%eax
c0102d8f:	75 07                	jne    c0102d98 <merge_backward+0x67>
c0102d91:	b8 00 00 00 00       	mov    $0x0,%eax
c0102d96:	eb 70                	jmp    c0102e08 <merge_backward+0xd7>
    //判断地址是否连续
    if(base+base->property==p)
c0102d98:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d9b:	8b 50 08             	mov    0x8(%eax),%edx
c0102d9e:	89 d0                	mov    %edx,%eax
c0102da0:	c1 e0 02             	shl    $0x2,%eax
c0102da3:	01 d0                	add    %edx,%eax
c0102da5:	c1 e0 02             	shl    $0x2,%eax
c0102da8:	89 c2                	mov    %eax,%edx
c0102daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dad:	01 d0                	add    %edx,%eax
c0102daf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c0102db2:	75 4f                	jne    c0102e03 <merge_backward+0xd2>
    {
        base->property+=p->property;
c0102db4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102db7:	8b 50 08             	mov    0x8(%eax),%edx
c0102dba:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102dbd:	8b 40 08             	mov    0x8(%eax),%eax
c0102dc0:	01 c2                	add    %eax,%edx
c0102dc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dc5:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
c0102dc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102dcb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102ddb:	8b 40 04             	mov    0x4(%eax),%eax
c0102dde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102de1:	8b 12                	mov    (%edx),%edx
c0102de3:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102de6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0102de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102def:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102df2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102df5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102df8:	89 10                	mov    %edx,(%eax)
}
c0102dfa:	90                   	nop
}
c0102dfb:	90                   	nop
        list_del(le);
        return 1;
c0102dfc:	b8 01 00 00 00       	mov    $0x1,%eax
c0102e01:	eb 05                	jmp    c0102e08 <merge_backward+0xd7>
        
    }
    else
    {
        return 0;
c0102e03:	b8 00 00 00 00       	mov    $0x0,%eax
    }

}
c0102e08:	89 ec                	mov    %ebp,%esp
c0102e0a:	5d                   	pop    %ebp
c0102e0b:	c3                   	ret    

c0102e0c <merge_beforeward>:
static bool merge_beforeward(struct Page*base)
{
c0102e0c:	55                   	push   %ebp
c0102e0d:	89 e5                	mov    %esp,%ebp
c0102e0f:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_prev(&(base->page_link));
c0102e12:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e15:	83 c0 0c             	add    $0xc,%eax
c0102e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->prev;
c0102e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e1e:	8b 00                	mov    (%eax),%eax
c0102e20:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le==&free_list)
c0102e23:	81 7d fc 80 ce 11 c0 	cmpl   $0xc011ce80,-0x4(%ebp)
c0102e2a:	75 0a                	jne    c0102e36 <merge_beforeward+0x2a>
    return 0;
c0102e2c:	b8 00 00 00 00       	mov    $0x0,%eax
c0102e31:	e9 b5 00 00 00       	jmp    c0102eeb <merge_beforeward+0xdf>
    struct Page*p=le2page(le,page_link);
c0102e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102e39:	83 e8 0c             	sub    $0xc,%eax
c0102e3c:	89 45 f8             	mov    %eax,-0x8(%ebp)

    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c0102e3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102e42:	83 c0 04             	add    $0x4,%eax
c0102e45:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102e4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102e4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e52:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102e55:	0f a3 10             	bt     %edx,(%eax)
c0102e58:	19 c0                	sbb    %eax,%eax
c0102e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102e5d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102e61:	0f 95 c0             	setne  %al
c0102e64:	0f b6 c0             	movzbl %al,%eax
c0102e67:	85 c0                	test   %eax,%eax
c0102e69:	75 07                	jne    c0102e72 <merge_beforeward+0x66>
c0102e6b:	b8 00 00 00 00       	mov    $0x0,%eax
c0102e70:	eb 79                	jmp    c0102eeb <merge_beforeward+0xdf>
    //判断地址是否连续
    if(p+p->property==base)
c0102e72:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102e75:	8b 50 08             	mov    0x8(%eax),%edx
c0102e78:	89 d0                	mov    %edx,%eax
c0102e7a:	c1 e0 02             	shl    $0x2,%eax
c0102e7d:	01 d0                	add    %edx,%eax
c0102e7f:	c1 e0 02             	shl    $0x2,%eax
c0102e82:	89 c2                	mov    %eax,%edx
c0102e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102e87:	01 d0                	add    %edx,%eax
c0102e89:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102e8c:	75 58                	jne    c0102ee6 <merge_beforeward+0xda>
    {
        p->property+=base->property;
c0102e8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102e91:	8b 50 08             	mov    0x8(%eax),%edx
c0102e94:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e97:	8b 40 08             	mov    0x8(%eax),%eax
c0102e9a:	01 c2                	add    %eax,%edx
c0102e9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102e9f:	89 50 08             	mov    %edx,0x8(%eax)
        base->property=0;
c0102ea2:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ea5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_del(&(base->page_link));
c0102eac:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eaf:	83 c0 0c             	add    $0xc,%eax
c0102eb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102eb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102eb8:	8b 40 04             	mov    0x4(%eax),%eax
c0102ebb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102ebe:	8b 12                	mov    (%edx),%edx
c0102ec0:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102ec3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0102ec6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ec9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ecc:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102ecf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102ed2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102ed5:	89 10                	mov    %edx,(%eax)
}
c0102ed7:	90                   	nop
}
c0102ed8:	90                   	nop
        base=p;
c0102ed9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102edc:	89 45 08             	mov    %eax,0x8(%ebp)
        return 1;   
c0102edf:	b8 01 00 00 00       	mov    $0x1,%eax
c0102ee4:	eb 05                	jmp    c0102eeb <merge_beforeward+0xdf>
    }
    else
    {
        return 0;
c0102ee6:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    

}
c0102eeb:	89 ec                	mov    %ebp,%esp
c0102eed:	5d                   	pop    %ebp
c0102eee:	c3                   	ret    

c0102eef <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102eef:	55                   	push   %ebp
c0102ef0:	89 e5                	mov    %esp,%ebp
c0102ef2:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102ef5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102ef9:	75 24                	jne    c0102f1f <default_free_pages+0x30>
c0102efb:	c7 44 24 0c 10 69 10 	movl   $0xc0106910,0xc(%esp)
c0102f02:	c0 
c0102f03:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0102f0a:	c0 
c0102f0b:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0102f12:	00 
c0102f13:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0102f1a:	e8 e0 dd ff ff       	call   c0100cff <__panic>
    struct Page *p = base;
c0102f1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f22:	89 45 f4             	mov    %eax,-0xc(%ebp)

    for (; p != base + n; p ++) {
c0102f25:	e9 ad 00 00 00       	jmp    c0102fd7 <default_free_pages+0xe8>
        
        //需要满足不是给内核的且不是空闲的
        assert(!PageReserved(p) && !PageProperty(p));
c0102f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f2d:	83 c0 04             	add    $0x4,%eax
c0102f30:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102f37:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102f3d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102f40:	0f a3 10             	bt     %edx,(%eax)
c0102f43:	19 c0                	sbb    %eax,%eax
c0102f45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102f48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f4c:	0f 95 c0             	setne  %al
c0102f4f:	0f b6 c0             	movzbl %al,%eax
c0102f52:	85 c0                	test   %eax,%eax
c0102f54:	75 2c                	jne    c0102f82 <default_free_pages+0x93>
c0102f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f59:	83 c0 04             	add    $0x4,%eax
c0102f5c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102f63:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102f66:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102f69:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102f6c:	0f a3 10             	bt     %edx,(%eax)
c0102f6f:	19 c0                	sbb    %eax,%eax
c0102f71:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102f74:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102f78:	0f 95 c0             	setne  %al
c0102f7b:	0f b6 c0             	movzbl %al,%eax
c0102f7e:	85 c0                	test   %eax,%eax
c0102f80:	74 24                	je     c0102fa6 <default_free_pages+0xb7>
c0102f82:	c7 44 24 0c 54 69 10 	movl   $0xc0106954,0xc(%esp)
c0102f89:	c0 
c0102f8a:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0102f91:	c0 
c0102f92:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0102f99:	00 
c0102f9a:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0102fa1:	e8 59 dd ff ff       	call   c0100cff <__panic>
        //p->flags = 0;
        SetPageProperty(p);
c0102fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fa9:	83 c0 04             	add    $0x4,%eax
c0102fac:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102fb3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fb9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102fbc:	0f ab 10             	bts    %edx,(%eax)
}
c0102fbf:	90                   	nop
        set_page_ref(p, 0);
c0102fc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102fc7:	00 
c0102fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fcb:	89 04 24             	mov    %eax,(%esp)
c0102fce:	e8 f0 f9 ff ff       	call   c01029c3 <set_page_ref>
    for (; p != base + n; p ++) {
c0102fd3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102fda:	89 d0                	mov    %edx,%eax
c0102fdc:	c1 e0 02             	shl    $0x2,%eax
c0102fdf:	01 d0                	add    %edx,%eax
c0102fe1:	c1 e0 02             	shl    $0x2,%eax
c0102fe4:	89 c2                	mov    %eax,%edx
c0102fe6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fe9:	01 d0                	add    %edx,%eax
c0102feb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102fee:	0f 85 36 ff ff ff    	jne    c0102f2a <default_free_pages+0x3b>
    }

    base->property = n;
c0102ff4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ffa:	89 50 08             	mov    %edx,0x8(%eax)
c0102ffd:	c7 45 cc 80 ce 11 c0 	movl   $0xc011ce80,-0x34(%ebp)
    return listelm->next;
c0103004:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103007:	8b 40 04             	mov    0x4(%eax),%eax
    //SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
c010300a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    for(;le!=&free_list && le<&(base->page_link);le=list_next(le));
c010300d:	eb 0f                	jmp    c010301e <default_free_pages+0x12f>
c010300f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103012:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103015:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103018:	8b 40 04             	mov    0x4(%eax),%eax
c010301b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010301e:	81 7d f0 80 ce 11 c0 	cmpl   $0xc011ce80,-0x10(%ebp)
c0103025:	74 0b                	je     c0103032 <default_free_pages+0x143>
c0103027:	8b 45 08             	mov    0x8(%ebp),%eax
c010302a:	83 c0 0c             	add    $0xc,%eax
c010302d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103030:	72 dd                	jb     c010300f <default_free_pages+0x120>

     nr_free += n;
c0103032:	8b 15 88 ce 11 c0    	mov    0xc011ce88,%edx
c0103038:	8b 45 0c             	mov    0xc(%ebp),%eax
c010303b:	01 d0                	add    %edx,%eax
c010303d:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88
    list_add_before(le,&base->page_link);
c0103042:	8b 45 08             	mov    0x8(%ebp),%eax
c0103045:	8d 50 0c             	lea    0xc(%eax),%edx
c0103048:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010304b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010304e:	89 55 c0             	mov    %edx,-0x40(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0103051:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103054:	8b 00                	mov    (%eax),%eax
c0103056:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103059:	89 55 bc             	mov    %edx,-0x44(%ebp)
c010305c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010305f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103062:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next->prev = elm;
c0103065:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103068:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010306b:	89 10                	mov    %edx,(%eax)
c010306d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103070:	8b 10                	mov    (%eax),%edx
c0103072:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103075:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103078:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010307b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010307e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103081:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103084:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103087:	89 10                	mov    %edx,(%eax)
}
c0103089:	90                   	nop
}
c010308a:	90                   	nop
    while(merge_backward(base));
c010308b:	90                   	nop
c010308c:	8b 45 08             	mov    0x8(%ebp),%eax
c010308f:	89 04 24             	mov    %eax,(%esp)
c0103092:	e8 9a fc ff ff       	call   c0102d31 <merge_backward>
c0103097:	85 c0                	test   %eax,%eax
c0103099:	75 f1                	jne    c010308c <default_free_pages+0x19d>
    while(merge_beforeward(base));
c010309b:	90                   	nop
c010309c:	8b 45 08             	mov    0x8(%ebp),%eax
c010309f:	89 04 24             	mov    %eax,(%esp)
c01030a2:	e8 65 fd ff ff       	call   c0102e0c <merge_beforeward>
c01030a7:	85 c0                	test   %eax,%eax
c01030a9:	75 f1                	jne    c010309c <default_free_pages+0x1ad>
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));*/


}
c01030ab:	90                   	nop
c01030ac:	90                   	nop
c01030ad:	89 ec                	mov    %ebp,%esp
c01030af:	5d                   	pop    %ebp
c01030b0:	c3                   	ret    

c01030b1 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01030b1:	55                   	push   %ebp
c01030b2:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01030b4:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
}
c01030b9:	5d                   	pop    %ebp
c01030ba:	c3                   	ret    

c01030bb <basic_check>:

static void
basic_check(void) {
c01030bb:	55                   	push   %ebp
c01030bc:	89 e5                	mov    %esp,%ebp
c01030be:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01030c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01030c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01030ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01030d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030db:	e8 ed 0e 00 00       	call   c0103fcd <alloc_pages>
c01030e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01030e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01030e7:	75 24                	jne    c010310d <basic_check+0x52>
c01030e9:	c7 44 24 0c 79 69 10 	movl   $0xc0106979,0xc(%esp)
c01030f0:	c0 
c01030f1:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01030f8:	c0 
c01030f9:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
c0103100:	00 
c0103101:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103108:	e8 f2 db ff ff       	call   c0100cff <__panic>
    assert((p1 = alloc_page()) != NULL);
c010310d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103114:	e8 b4 0e 00 00       	call   c0103fcd <alloc_pages>
c0103119:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010311c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103120:	75 24                	jne    c0103146 <basic_check+0x8b>
c0103122:	c7 44 24 0c 95 69 10 	movl   $0xc0106995,0xc(%esp)
c0103129:	c0 
c010312a:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103131:	c0 
c0103132:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0103139:	00 
c010313a:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103141:	e8 b9 db ff ff       	call   c0100cff <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103146:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010314d:	e8 7b 0e 00 00       	call   c0103fcd <alloc_pages>
c0103152:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103155:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103159:	75 24                	jne    c010317f <basic_check+0xc4>
c010315b:	c7 44 24 0c b1 69 10 	movl   $0xc01069b1,0xc(%esp)
c0103162:	c0 
c0103163:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010316a:	c0 
c010316b:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0103172:	00 
c0103173:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010317a:	e8 80 db ff ff       	call   c0100cff <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c010317f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103182:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103185:	74 10                	je     c0103197 <basic_check+0xdc>
c0103187:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010318a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010318d:	74 08                	je     c0103197 <basic_check+0xdc>
c010318f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103192:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103195:	75 24                	jne    c01031bb <basic_check+0x100>
c0103197:	c7 44 24 0c d0 69 10 	movl   $0xc01069d0,0xc(%esp)
c010319e:	c0 
c010319f:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01031a6:	c0 
c01031a7:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c01031ae:	00 
c01031af:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01031b6:	e8 44 db ff ff       	call   c0100cff <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01031bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031be:	89 04 24             	mov    %eax,(%esp)
c01031c1:	e8 f3 f7 ff ff       	call   c01029b9 <page_ref>
c01031c6:	85 c0                	test   %eax,%eax
c01031c8:	75 1e                	jne    c01031e8 <basic_check+0x12d>
c01031ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031cd:	89 04 24             	mov    %eax,(%esp)
c01031d0:	e8 e4 f7 ff ff       	call   c01029b9 <page_ref>
c01031d5:	85 c0                	test   %eax,%eax
c01031d7:	75 0f                	jne    c01031e8 <basic_check+0x12d>
c01031d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031dc:	89 04 24             	mov    %eax,(%esp)
c01031df:	e8 d5 f7 ff ff       	call   c01029b9 <page_ref>
c01031e4:	85 c0                	test   %eax,%eax
c01031e6:	74 24                	je     c010320c <basic_check+0x151>
c01031e8:	c7 44 24 0c f4 69 10 	movl   $0xc01069f4,0xc(%esp)
c01031ef:	c0 
c01031f0:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01031f7:	c0 
c01031f8:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c01031ff:	00 
c0103200:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103207:	e8 f3 da ff ff       	call   c0100cff <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010320c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010320f:	89 04 24             	mov    %eax,(%esp)
c0103212:	e8 8a f7 ff ff       	call   c01029a1 <page2pa>
c0103217:	8b 15 a4 ce 11 c0    	mov    0xc011cea4,%edx
c010321d:	c1 e2 0c             	shl    $0xc,%edx
c0103220:	39 d0                	cmp    %edx,%eax
c0103222:	72 24                	jb     c0103248 <basic_check+0x18d>
c0103224:	c7 44 24 0c 30 6a 10 	movl   $0xc0106a30,0xc(%esp)
c010322b:	c0 
c010322c:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103233:	c0 
c0103234:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c010323b:	00 
c010323c:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103243:	e8 b7 da ff ff       	call   c0100cff <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103248:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010324b:	89 04 24             	mov    %eax,(%esp)
c010324e:	e8 4e f7 ff ff       	call   c01029a1 <page2pa>
c0103253:	8b 15 a4 ce 11 c0    	mov    0xc011cea4,%edx
c0103259:	c1 e2 0c             	shl    $0xc,%edx
c010325c:	39 d0                	cmp    %edx,%eax
c010325e:	72 24                	jb     c0103284 <basic_check+0x1c9>
c0103260:	c7 44 24 0c 4d 6a 10 	movl   $0xc0106a4d,0xc(%esp)
c0103267:	c0 
c0103268:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010326f:	c0 
c0103270:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
c0103277:	00 
c0103278:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010327f:	e8 7b da ff ff       	call   c0100cff <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103284:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103287:	89 04 24             	mov    %eax,(%esp)
c010328a:	e8 12 f7 ff ff       	call   c01029a1 <page2pa>
c010328f:	8b 15 a4 ce 11 c0    	mov    0xc011cea4,%edx
c0103295:	c1 e2 0c             	shl    $0xc,%edx
c0103298:	39 d0                	cmp    %edx,%eax
c010329a:	72 24                	jb     c01032c0 <basic_check+0x205>
c010329c:	c7 44 24 0c 6a 6a 10 	movl   $0xc0106a6a,0xc(%esp)
c01032a3:	c0 
c01032a4:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01032ab:	c0 
c01032ac:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c01032b3:	00 
c01032b4:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01032bb:	e8 3f da ff ff       	call   c0100cff <__panic>

    list_entry_t free_list_store = free_list;
c01032c0:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c01032c5:	8b 15 84 ce 11 c0    	mov    0xc011ce84,%edx
c01032cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01032ce:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01032d1:	c7 45 dc 80 ce 11 c0 	movl   $0xc011ce80,-0x24(%ebp)
    elm->prev = elm->next = elm;
c01032d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01032db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01032de:	89 50 04             	mov    %edx,0x4(%eax)
c01032e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01032e4:	8b 50 04             	mov    0x4(%eax),%edx
c01032e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01032ea:	89 10                	mov    %edx,(%eax)
}
c01032ec:	90                   	nop
c01032ed:	c7 45 e0 80 ce 11 c0 	movl   $0xc011ce80,-0x20(%ebp)
    return list->next == list;
c01032f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032f7:	8b 40 04             	mov    0x4(%eax),%eax
c01032fa:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01032fd:	0f 94 c0             	sete   %al
c0103300:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103303:	85 c0                	test   %eax,%eax
c0103305:	75 24                	jne    c010332b <basic_check+0x270>
c0103307:	c7 44 24 0c 87 6a 10 	movl   $0xc0106a87,0xc(%esp)
c010330e:	c0 
c010330f:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103316:	c0 
c0103317:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c010331e:	00 
c010331f:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103326:	e8 d4 d9 ff ff       	call   c0100cff <__panic>

    unsigned int nr_free_store = nr_free;
c010332b:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0103330:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103333:	c7 05 88 ce 11 c0 00 	movl   $0x0,0xc011ce88
c010333a:	00 00 00 

    assert(alloc_page() == NULL);
c010333d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103344:	e8 84 0c 00 00       	call   c0103fcd <alloc_pages>
c0103349:	85 c0                	test   %eax,%eax
c010334b:	74 24                	je     c0103371 <basic_check+0x2b6>
c010334d:	c7 44 24 0c 9e 6a 10 	movl   $0xc0106a9e,0xc(%esp)
c0103354:	c0 
c0103355:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010335c:	c0 
c010335d:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
c0103364:	00 
c0103365:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010336c:	e8 8e d9 ff ff       	call   c0100cff <__panic>

    free_page(p0);
c0103371:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103378:	00 
c0103379:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010337c:	89 04 24             	mov    %eax,(%esp)
c010337f:	e8 83 0c 00 00       	call   c0104007 <free_pages>
    free_page(p1);
c0103384:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010338b:	00 
c010338c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010338f:	89 04 24             	mov    %eax,(%esp)
c0103392:	e8 70 0c 00 00       	call   c0104007 <free_pages>
    free_page(p2);
c0103397:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010339e:	00 
c010339f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a2:	89 04 24             	mov    %eax,(%esp)
c01033a5:	e8 5d 0c 00 00       	call   c0104007 <free_pages>
    assert(nr_free == 3);
c01033aa:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c01033af:	83 f8 03             	cmp    $0x3,%eax
c01033b2:	74 24                	je     c01033d8 <basic_check+0x31d>
c01033b4:	c7 44 24 0c b3 6a 10 	movl   $0xc0106ab3,0xc(%esp)
c01033bb:	c0 
c01033bc:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01033c3:	c0 
c01033c4:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c01033cb:	00 
c01033cc:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01033d3:	e8 27 d9 ff ff       	call   c0100cff <__panic>

    assert((p0 = alloc_page()) != NULL);
c01033d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033df:	e8 e9 0b 00 00       	call   c0103fcd <alloc_pages>
c01033e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01033e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01033eb:	75 24                	jne    c0103411 <basic_check+0x356>
c01033ed:	c7 44 24 0c 79 69 10 	movl   $0xc0106979,0xc(%esp)
c01033f4:	c0 
c01033f5:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01033fc:	c0 
c01033fd:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0103404:	00 
c0103405:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010340c:	e8 ee d8 ff ff       	call   c0100cff <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103411:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103418:	e8 b0 0b 00 00       	call   c0103fcd <alloc_pages>
c010341d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103424:	75 24                	jne    c010344a <basic_check+0x38f>
c0103426:	c7 44 24 0c 95 69 10 	movl   $0xc0106995,0xc(%esp)
c010342d:	c0 
c010342e:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103435:	c0 
c0103436:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
c010343d:	00 
c010343e:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103445:	e8 b5 d8 ff ff       	call   c0100cff <__panic>
    assert((p2 = alloc_page()) != NULL);
c010344a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103451:	e8 77 0b 00 00       	call   c0103fcd <alloc_pages>
c0103456:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103459:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010345d:	75 24                	jne    c0103483 <basic_check+0x3c8>
c010345f:	c7 44 24 0c b1 69 10 	movl   $0xc01069b1,0xc(%esp)
c0103466:	c0 
c0103467:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010346e:	c0 
c010346f:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
c0103476:	00 
c0103477:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010347e:	e8 7c d8 ff ff       	call   c0100cff <__panic>

    assert(alloc_page() == NULL);
c0103483:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010348a:	e8 3e 0b 00 00       	call   c0103fcd <alloc_pages>
c010348f:	85 c0                	test   %eax,%eax
c0103491:	74 24                	je     c01034b7 <basic_check+0x3fc>
c0103493:	c7 44 24 0c 9e 6a 10 	movl   $0xc0106a9e,0xc(%esp)
c010349a:	c0 
c010349b:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01034a2:	c0 
c01034a3:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c01034aa:	00 
c01034ab:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01034b2:	e8 48 d8 ff ff       	call   c0100cff <__panic>

    free_page(p0);
c01034b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01034be:	00 
c01034bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034c2:	89 04 24             	mov    %eax,(%esp)
c01034c5:	e8 3d 0b 00 00       	call   c0104007 <free_pages>
c01034ca:	c7 45 d8 80 ce 11 c0 	movl   $0xc011ce80,-0x28(%ebp)
c01034d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01034d4:	8b 40 04             	mov    0x4(%eax),%eax
c01034d7:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01034da:	0f 94 c0             	sete   %al
c01034dd:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01034e0:	85 c0                	test   %eax,%eax
c01034e2:	74 24                	je     c0103508 <basic_check+0x44d>
c01034e4:	c7 44 24 0c c0 6a 10 	movl   $0xc0106ac0,0xc(%esp)
c01034eb:	c0 
c01034ec:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01034f3:	c0 
c01034f4:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
c01034fb:	00 
c01034fc:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103503:	e8 f7 d7 ff ff       	call   c0100cff <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103508:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010350f:	e8 b9 0a 00 00       	call   c0103fcd <alloc_pages>
c0103514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010351a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010351d:	74 24                	je     c0103543 <basic_check+0x488>
c010351f:	c7 44 24 0c d8 6a 10 	movl   $0xc0106ad8,0xc(%esp)
c0103526:	c0 
c0103527:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010352e:	c0 
c010352f:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c0103536:	00 
c0103537:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010353e:	e8 bc d7 ff ff       	call   c0100cff <__panic>
    assert(alloc_page() == NULL);
c0103543:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010354a:	e8 7e 0a 00 00       	call   c0103fcd <alloc_pages>
c010354f:	85 c0                	test   %eax,%eax
c0103551:	74 24                	je     c0103577 <basic_check+0x4bc>
c0103553:	c7 44 24 0c 9e 6a 10 	movl   $0xc0106a9e,0xc(%esp)
c010355a:	c0 
c010355b:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103562:	c0 
c0103563:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c010356a:	00 
c010356b:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103572:	e8 88 d7 ff ff       	call   c0100cff <__panic>

    assert(nr_free == 0);
c0103577:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c010357c:	85 c0                	test   %eax,%eax
c010357e:	74 24                	je     c01035a4 <basic_check+0x4e9>
c0103580:	c7 44 24 0c f1 6a 10 	movl   $0xc0106af1,0xc(%esp)
c0103587:	c0 
c0103588:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010358f:	c0 
c0103590:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c0103597:	00 
c0103598:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010359f:	e8 5b d7 ff ff       	call   c0100cff <__panic>
    free_list = free_list_store;
c01035a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01035a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035aa:	a3 80 ce 11 c0       	mov    %eax,0xc011ce80
c01035af:	89 15 84 ce 11 c0    	mov    %edx,0xc011ce84
    nr_free = nr_free_store;
c01035b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035b8:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88

    free_page(p);
c01035bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01035c4:	00 
c01035c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035c8:	89 04 24             	mov    %eax,(%esp)
c01035cb:	e8 37 0a 00 00       	call   c0104007 <free_pages>
    free_page(p1);
c01035d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01035d7:	00 
c01035d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035db:	89 04 24             	mov    %eax,(%esp)
c01035de:	e8 24 0a 00 00       	call   c0104007 <free_pages>
    free_page(p2);
c01035e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01035ea:	00 
c01035eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ee:	89 04 24             	mov    %eax,(%esp)
c01035f1:	e8 11 0a 00 00       	call   c0104007 <free_pages>
}
c01035f6:	90                   	nop
c01035f7:	89 ec                	mov    %ebp,%esp
c01035f9:	5d                   	pop    %ebp
c01035fa:	c3                   	ret    

c01035fb <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01035fb:	55                   	push   %ebp
c01035fc:	89 e5                	mov    %esp,%ebp
c01035fe:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103604:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010360b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103612:	c7 45 ec 80 ce 11 c0 	movl   $0xc011ce80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103619:	eb 6a                	jmp    c0103685 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c010361b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010361e:	83 e8 0c             	sub    $0xc,%eax
c0103621:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103624:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103627:	83 c0 04             	add    $0x4,%eax
c010362a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103631:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103634:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103637:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010363a:	0f a3 10             	bt     %edx,(%eax)
c010363d:	19 c0                	sbb    %eax,%eax
c010363f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103642:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103646:	0f 95 c0             	setne  %al
c0103649:	0f b6 c0             	movzbl %al,%eax
c010364c:	85 c0                	test   %eax,%eax
c010364e:	75 24                	jne    c0103674 <default_check+0x79>
c0103650:	c7 44 24 0c fe 6a 10 	movl   $0xc0106afe,0xc(%esp)
c0103657:	c0 
c0103658:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010365f:	c0 
c0103660:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0103667:	00 
c0103668:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010366f:	e8 8b d6 ff ff       	call   c0100cff <__panic>
        count ++, total += p->property;
c0103674:	ff 45 f4             	incl   -0xc(%ebp)
c0103677:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010367a:	8b 50 08             	mov    0x8(%eax),%edx
c010367d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103680:	01 d0                	add    %edx,%eax
c0103682:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103685:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103688:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c010368b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010368e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103691:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103694:	81 7d ec 80 ce 11 c0 	cmpl   $0xc011ce80,-0x14(%ebp)
c010369b:	0f 85 7a ff ff ff    	jne    c010361b <default_check+0x20>
    }
    assert(total == nr_free_pages());
c01036a1:	e8 96 09 00 00       	call   c010403c <nr_free_pages>
c01036a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036a9:	39 d0                	cmp    %edx,%eax
c01036ab:	74 24                	je     c01036d1 <default_check+0xd6>
c01036ad:	c7 44 24 0c 0e 6b 10 	movl   $0xc0106b0e,0xc(%esp)
c01036b4:	c0 
c01036b5:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01036bc:	c0 
c01036bd:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c01036c4:	00 
c01036c5:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01036cc:	e8 2e d6 ff ff       	call   c0100cff <__panic>

    basic_check();
c01036d1:	e8 e5 f9 ff ff       	call   c01030bb <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01036d6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01036dd:	e8 eb 08 00 00       	call   c0103fcd <alloc_pages>
c01036e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c01036e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036e9:	75 24                	jne    c010370f <default_check+0x114>
c01036eb:	c7 44 24 0c 27 6b 10 	movl   $0xc0106b27,0xc(%esp)
c01036f2:	c0 
c01036f3:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01036fa:	c0 
c01036fb:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0103702:	00 
c0103703:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010370a:	e8 f0 d5 ff ff       	call   c0100cff <__panic>
    assert(!PageProperty(p0));
c010370f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103712:	83 c0 04             	add    $0x4,%eax
c0103715:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010371c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010371f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103722:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103725:	0f a3 10             	bt     %edx,(%eax)
c0103728:	19 c0                	sbb    %eax,%eax
c010372a:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010372d:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103731:	0f 95 c0             	setne  %al
c0103734:	0f b6 c0             	movzbl %al,%eax
c0103737:	85 c0                	test   %eax,%eax
c0103739:	74 24                	je     c010375f <default_check+0x164>
c010373b:	c7 44 24 0c 32 6b 10 	movl   $0xc0106b32,0xc(%esp)
c0103742:	c0 
c0103743:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c010374a:	c0 
c010374b:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c0103752:	00 
c0103753:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c010375a:	e8 a0 d5 ff ff       	call   c0100cff <__panic>

    list_entry_t free_list_store = free_list;
c010375f:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103764:	8b 15 84 ce 11 c0    	mov    0xc011ce84,%edx
c010376a:	89 45 80             	mov    %eax,-0x80(%ebp)
c010376d:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103770:	c7 45 b0 80 ce 11 c0 	movl   $0xc011ce80,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0103777:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010377a:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010377d:	89 50 04             	mov    %edx,0x4(%eax)
c0103780:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103783:	8b 50 04             	mov    0x4(%eax),%edx
c0103786:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103789:	89 10                	mov    %edx,(%eax)
}
c010378b:	90                   	nop
c010378c:	c7 45 b4 80 ce 11 c0 	movl   $0xc011ce80,-0x4c(%ebp)
    return list->next == list;
c0103793:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103796:	8b 40 04             	mov    0x4(%eax),%eax
c0103799:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010379c:	0f 94 c0             	sete   %al
c010379f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01037a2:	85 c0                	test   %eax,%eax
c01037a4:	75 24                	jne    c01037ca <default_check+0x1cf>
c01037a6:	c7 44 24 0c 87 6a 10 	movl   $0xc0106a87,0xc(%esp)
c01037ad:	c0 
c01037ae:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01037b5:	c0 
c01037b6:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c01037bd:	00 
c01037be:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01037c5:	e8 35 d5 ff ff       	call   c0100cff <__panic>
    assert(alloc_page() == NULL);
c01037ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037d1:	e8 f7 07 00 00       	call   c0103fcd <alloc_pages>
c01037d6:	85 c0                	test   %eax,%eax
c01037d8:	74 24                	je     c01037fe <default_check+0x203>
c01037da:	c7 44 24 0c 9e 6a 10 	movl   $0xc0106a9e,0xc(%esp)
c01037e1:	c0 
c01037e2:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01037e9:	c0 
c01037ea:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c01037f1:	00 
c01037f2:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01037f9:	e8 01 d5 ff ff       	call   c0100cff <__panic>

    unsigned int nr_free_store = nr_free;
c01037fe:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0103803:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0103806:	c7 05 88 ce 11 c0 00 	movl   $0x0,0xc011ce88
c010380d:	00 00 00 

    free_pages(p0 + 2, 3);
c0103810:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103813:	83 c0 28             	add    $0x28,%eax
c0103816:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010381d:	00 
c010381e:	89 04 24             	mov    %eax,(%esp)
c0103821:	e8 e1 07 00 00       	call   c0104007 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103826:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010382d:	e8 9b 07 00 00       	call   c0103fcd <alloc_pages>
c0103832:	85 c0                	test   %eax,%eax
c0103834:	74 24                	je     c010385a <default_check+0x25f>
c0103836:	c7 44 24 0c 44 6b 10 	movl   $0xc0106b44,0xc(%esp)
c010383d:	c0 
c010383e:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103845:	c0 
c0103846:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c010384d:	00 
c010384e:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103855:	e8 a5 d4 ff ff       	call   c0100cff <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010385a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010385d:	83 c0 28             	add    $0x28,%eax
c0103860:	83 c0 04             	add    $0x4,%eax
c0103863:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010386a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010386d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103870:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103873:	0f a3 10             	bt     %edx,(%eax)
c0103876:	19 c0                	sbb    %eax,%eax
c0103878:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010387b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010387f:	0f 95 c0             	setne  %al
c0103882:	0f b6 c0             	movzbl %al,%eax
c0103885:	85 c0                	test   %eax,%eax
c0103887:	74 0e                	je     c0103897 <default_check+0x29c>
c0103889:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010388c:	83 c0 28             	add    $0x28,%eax
c010388f:	8b 40 08             	mov    0x8(%eax),%eax
c0103892:	83 f8 03             	cmp    $0x3,%eax
c0103895:	74 24                	je     c01038bb <default_check+0x2c0>
c0103897:	c7 44 24 0c 5c 6b 10 	movl   $0xc0106b5c,0xc(%esp)
c010389e:	c0 
c010389f:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01038a6:	c0 
c01038a7:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
c01038ae:	00 
c01038af:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01038b6:	e8 44 d4 ff ff       	call   c0100cff <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01038bb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01038c2:	e8 06 07 00 00       	call   c0103fcd <alloc_pages>
c01038c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01038ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01038ce:	75 24                	jne    c01038f4 <default_check+0x2f9>
c01038d0:	c7 44 24 0c 88 6b 10 	movl   $0xc0106b88,0xc(%esp)
c01038d7:	c0 
c01038d8:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01038df:	c0 
c01038e0:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
c01038e7:	00 
c01038e8:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01038ef:	e8 0b d4 ff ff       	call   c0100cff <__panic>
    assert(alloc_page() == NULL);
c01038f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038fb:	e8 cd 06 00 00       	call   c0103fcd <alloc_pages>
c0103900:	85 c0                	test   %eax,%eax
c0103902:	74 24                	je     c0103928 <default_check+0x32d>
c0103904:	c7 44 24 0c 9e 6a 10 	movl   $0xc0106a9e,0xc(%esp)
c010390b:	c0 
c010390c:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103913:	c0 
c0103914:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c010391b:	00 
c010391c:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103923:	e8 d7 d3 ff ff       	call   c0100cff <__panic>
    assert(p0 + 2 == p1);
c0103928:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010392b:	83 c0 28             	add    $0x28,%eax
c010392e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103931:	74 24                	je     c0103957 <default_check+0x35c>
c0103933:	c7 44 24 0c a6 6b 10 	movl   $0xc0106ba6,0xc(%esp)
c010393a:	c0 
c010393b:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103942:	c0 
c0103943:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
c010394a:	00 
c010394b:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103952:	e8 a8 d3 ff ff       	call   c0100cff <__panic>

    p2 = p0 + 1;
c0103957:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010395a:	83 c0 14             	add    $0x14,%eax
c010395d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0103960:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103967:	00 
c0103968:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010396b:	89 04 24             	mov    %eax,(%esp)
c010396e:	e8 94 06 00 00       	call   c0104007 <free_pages>
    free_pages(p1, 3);
c0103973:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010397a:	00 
c010397b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010397e:	89 04 24             	mov    %eax,(%esp)
c0103981:	e8 81 06 00 00       	call   c0104007 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0103986:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103989:	83 c0 04             	add    $0x4,%eax
c010398c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103993:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103996:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103999:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010399c:	0f a3 10             	bt     %edx,(%eax)
c010399f:	19 c0                	sbb    %eax,%eax
c01039a1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01039a4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01039a8:	0f 95 c0             	setne  %al
c01039ab:	0f b6 c0             	movzbl %al,%eax
c01039ae:	85 c0                	test   %eax,%eax
c01039b0:	74 0b                	je     c01039bd <default_check+0x3c2>
c01039b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039b5:	8b 40 08             	mov    0x8(%eax),%eax
c01039b8:	83 f8 01             	cmp    $0x1,%eax
c01039bb:	74 24                	je     c01039e1 <default_check+0x3e6>
c01039bd:	c7 44 24 0c b4 6b 10 	movl   $0xc0106bb4,0xc(%esp)
c01039c4:	c0 
c01039c5:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c01039cc:	c0 
c01039cd:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c01039d4:	00 
c01039d5:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c01039dc:	e8 1e d3 ff ff       	call   c0100cff <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01039e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039e4:	83 c0 04             	add    $0x4,%eax
c01039e7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01039ee:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039f1:	8b 45 90             	mov    -0x70(%ebp),%eax
c01039f4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01039f7:	0f a3 10             	bt     %edx,(%eax)
c01039fa:	19 c0                	sbb    %eax,%eax
c01039fc:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01039ff:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103a03:	0f 95 c0             	setne  %al
c0103a06:	0f b6 c0             	movzbl %al,%eax
c0103a09:	85 c0                	test   %eax,%eax
c0103a0b:	74 0b                	je     c0103a18 <default_check+0x41d>
c0103a0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a10:	8b 40 08             	mov    0x8(%eax),%eax
c0103a13:	83 f8 03             	cmp    $0x3,%eax
c0103a16:	74 24                	je     c0103a3c <default_check+0x441>
c0103a18:	c7 44 24 0c dc 6b 10 	movl   $0xc0106bdc,0xc(%esp)
c0103a1f:	c0 
c0103a20:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103a27:	c0 
c0103a28:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
c0103a2f:	00 
c0103a30:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103a37:	e8 c3 d2 ff ff       	call   c0100cff <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103a3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a43:	e8 85 05 00 00       	call   c0103fcd <alloc_pages>
c0103a48:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103a4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a4e:	83 e8 14             	sub    $0x14,%eax
c0103a51:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103a54:	74 24                	je     c0103a7a <default_check+0x47f>
c0103a56:	c7 44 24 0c 02 6c 10 	movl   $0xc0106c02,0xc(%esp)
c0103a5d:	c0 
c0103a5e:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103a65:	c0 
c0103a66:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
c0103a6d:	00 
c0103a6e:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103a75:	e8 85 d2 ff ff       	call   c0100cff <__panic>
    free_page(p0);
c0103a7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a81:	00 
c0103a82:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a85:	89 04 24             	mov    %eax,(%esp)
c0103a88:	e8 7a 05 00 00       	call   c0104007 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103a8d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103a94:	e8 34 05 00 00       	call   c0103fcd <alloc_pages>
c0103a99:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a9f:	83 c0 14             	add    $0x14,%eax
c0103aa2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103aa5:	74 24                	je     c0103acb <default_check+0x4d0>
c0103aa7:	c7 44 24 0c 20 6c 10 	movl   $0xc0106c20,0xc(%esp)
c0103aae:	c0 
c0103aaf:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103ab6:	c0 
c0103ab7:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
c0103abe:	00 
c0103abf:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103ac6:	e8 34 d2 ff ff       	call   c0100cff <__panic>

    free_pages(p0, 2);
c0103acb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103ad2:	00 
c0103ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ad6:	89 04 24             	mov    %eax,(%esp)
c0103ad9:	e8 29 05 00 00       	call   c0104007 <free_pages>
    free_page(p2);
c0103ade:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ae5:	00 
c0103ae6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ae9:	89 04 24             	mov    %eax,(%esp)
c0103aec:	e8 16 05 00 00       	call   c0104007 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103af1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103af8:	e8 d0 04 00 00       	call   c0103fcd <alloc_pages>
c0103afd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b00:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103b04:	75 24                	jne    c0103b2a <default_check+0x52f>
c0103b06:	c7 44 24 0c 40 6c 10 	movl   $0xc0106c40,0xc(%esp)
c0103b0d:	c0 
c0103b0e:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103b15:	c0 
c0103b16:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
c0103b1d:	00 
c0103b1e:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103b25:	e8 d5 d1 ff ff       	call   c0100cff <__panic>
    assert(alloc_page() == NULL);
c0103b2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b31:	e8 97 04 00 00       	call   c0103fcd <alloc_pages>
c0103b36:	85 c0                	test   %eax,%eax
c0103b38:	74 24                	je     c0103b5e <default_check+0x563>
c0103b3a:	c7 44 24 0c 9e 6a 10 	movl   $0xc0106a9e,0xc(%esp)
c0103b41:	c0 
c0103b42:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103b49:	c0 
c0103b4a:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c0103b51:	00 
c0103b52:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103b59:	e8 a1 d1 ff ff       	call   c0100cff <__panic>

    assert(nr_free == 0);
c0103b5e:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0103b63:	85 c0                	test   %eax,%eax
c0103b65:	74 24                	je     c0103b8b <default_check+0x590>
c0103b67:	c7 44 24 0c f1 6a 10 	movl   $0xc0106af1,0xc(%esp)
c0103b6e:	c0 
c0103b6f:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103b76:	c0 
c0103b77:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c0103b7e:	00 
c0103b7f:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103b86:	e8 74 d1 ff ff       	call   c0100cff <__panic>
    nr_free = nr_free_store;
c0103b8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b8e:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88

    free_list = free_list_store;
c0103b93:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103b96:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103b99:	a3 80 ce 11 c0       	mov    %eax,0xc011ce80
c0103b9e:	89 15 84 ce 11 c0    	mov    %edx,0xc011ce84
    free_pages(p0, 5);
c0103ba4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103bab:	00 
c0103bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103baf:	89 04 24             	mov    %eax,(%esp)
c0103bb2:	e8 50 04 00 00       	call   c0104007 <free_pages>

    le = &free_list;
c0103bb7:	c7 45 ec 80 ce 11 c0 	movl   $0xc011ce80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103bbe:	eb 5a                	jmp    c0103c1a <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c0103bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bc3:	8b 40 04             	mov    0x4(%eax),%eax
c0103bc6:	8b 00                	mov    (%eax),%eax
c0103bc8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103bcb:	75 0d                	jne    c0103bda <default_check+0x5df>
c0103bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bd0:	8b 00                	mov    (%eax),%eax
c0103bd2:	8b 40 04             	mov    0x4(%eax),%eax
c0103bd5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103bd8:	74 24                	je     c0103bfe <default_check+0x603>
c0103bda:	c7 44 24 0c 60 6c 10 	movl   $0xc0106c60,0xc(%esp)
c0103be1:	c0 
c0103be2:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103be9:	c0 
c0103bea:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
c0103bf1:	00 
c0103bf2:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103bf9:	e8 01 d1 ff ff       	call   c0100cff <__panic>
        struct Page *p = le2page(le, page_link);
c0103bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c01:	83 e8 0c             	sub    $0xc,%eax
c0103c04:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0103c07:	ff 4d f4             	decl   -0xc(%ebp)
c0103c0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103c0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103c10:	8b 48 08             	mov    0x8(%eax),%ecx
c0103c13:	89 d0                	mov    %edx,%eax
c0103c15:	29 c8                	sub    %ecx,%eax
c0103c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c1d:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0103c20:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103c23:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c29:	81 7d ec 80 ce 11 c0 	cmpl   $0xc011ce80,-0x14(%ebp)
c0103c30:	75 8e                	jne    c0103bc0 <default_check+0x5c5>
    }
    assert(count == 0);
c0103c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103c36:	74 24                	je     c0103c5c <default_check+0x661>
c0103c38:	c7 44 24 0c 8d 6c 10 	movl   $0xc0106c8d,0xc(%esp)
c0103c3f:	c0 
c0103c40:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103c47:	c0 
c0103c48:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c0103c4f:	00 
c0103c50:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103c57:	e8 a3 d0 ff ff       	call   c0100cff <__panic>
    assert(total == 0);
c0103c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c60:	74 24                	je     c0103c86 <default_check+0x68b>
c0103c62:	c7 44 24 0c 98 6c 10 	movl   $0xc0106c98,0xc(%esp)
c0103c69:	c0 
c0103c6a:	c7 44 24 08 16 69 10 	movl   $0xc0106916,0x8(%esp)
c0103c71:	c0 
c0103c72:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c0103c79:	00 
c0103c7a:	c7 04 24 2b 69 10 c0 	movl   $0xc010692b,(%esp)
c0103c81:	e8 79 d0 ff ff       	call   c0100cff <__panic>
}
c0103c86:	90                   	nop
c0103c87:	89 ec                	mov    %ebp,%esp
c0103c89:	5d                   	pop    %ebp
c0103c8a:	c3                   	ret    

c0103c8b <page2ppn>:
page2ppn(struct Page *page) {
c0103c8b:	55                   	push   %ebp
c0103c8c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103c8e:	8b 15 a0 ce 11 c0    	mov    0xc011cea0,%edx
c0103c94:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c97:	29 d0                	sub    %edx,%eax
c0103c99:	c1 f8 02             	sar    $0x2,%eax
c0103c9c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103ca2:	5d                   	pop    %ebp
c0103ca3:	c3                   	ret    

c0103ca4 <page2pa>:
page2pa(struct Page *page) {
c0103ca4:	55                   	push   %ebp
c0103ca5:	89 e5                	mov    %esp,%ebp
c0103ca7:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103caa:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cad:	89 04 24             	mov    %eax,(%esp)
c0103cb0:	e8 d6 ff ff ff       	call   c0103c8b <page2ppn>
c0103cb5:	c1 e0 0c             	shl    $0xc,%eax
}
c0103cb8:	89 ec                	mov    %ebp,%esp
c0103cba:	5d                   	pop    %ebp
c0103cbb:	c3                   	ret    

c0103cbc <pa2page>:
pa2page(uintptr_t pa) {
c0103cbc:	55                   	push   %ebp
c0103cbd:	89 e5                	mov    %esp,%ebp
c0103cbf:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103cc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cc5:	c1 e8 0c             	shr    $0xc,%eax
c0103cc8:	89 c2                	mov    %eax,%edx
c0103cca:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c0103ccf:	39 c2                	cmp    %eax,%edx
c0103cd1:	72 1c                	jb     c0103cef <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103cd3:	c7 44 24 08 d4 6c 10 	movl   $0xc0106cd4,0x8(%esp)
c0103cda:	c0 
c0103cdb:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103ce2:	00 
c0103ce3:	c7 04 24 f3 6c 10 c0 	movl   $0xc0106cf3,(%esp)
c0103cea:	e8 10 d0 ff ff       	call   c0100cff <__panic>
    return &pages[PPN(pa)];
c0103cef:	8b 0d a0 ce 11 c0    	mov    0xc011cea0,%ecx
c0103cf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cf8:	c1 e8 0c             	shr    $0xc,%eax
c0103cfb:	89 c2                	mov    %eax,%edx
c0103cfd:	89 d0                	mov    %edx,%eax
c0103cff:	c1 e0 02             	shl    $0x2,%eax
c0103d02:	01 d0                	add    %edx,%eax
c0103d04:	c1 e0 02             	shl    $0x2,%eax
c0103d07:	01 c8                	add    %ecx,%eax
}
c0103d09:	89 ec                	mov    %ebp,%esp
c0103d0b:	5d                   	pop    %ebp
c0103d0c:	c3                   	ret    

c0103d0d <page2kva>:
page2kva(struct Page *page) {
c0103d0d:	55                   	push   %ebp
c0103d0e:	89 e5                	mov    %esp,%ebp
c0103d10:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d16:	89 04 24             	mov    %eax,(%esp)
c0103d19:	e8 86 ff ff ff       	call   c0103ca4 <page2pa>
c0103d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d24:	c1 e8 0c             	shr    $0xc,%eax
c0103d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d2a:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c0103d2f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103d32:	72 23                	jb     c0103d57 <page2kva+0x4a>
c0103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d37:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d3b:	c7 44 24 08 04 6d 10 	movl   $0xc0106d04,0x8(%esp)
c0103d42:	c0 
c0103d43:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103d4a:	00 
c0103d4b:	c7 04 24 f3 6c 10 c0 	movl   $0xc0106cf3,(%esp)
c0103d52:	e8 a8 cf ff ff       	call   c0100cff <__panic>
c0103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d5a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103d5f:	89 ec                	mov    %ebp,%esp
c0103d61:	5d                   	pop    %ebp
c0103d62:	c3                   	ret    

c0103d63 <pte2page>:
pte2page(pte_t pte) {
c0103d63:	55                   	push   %ebp
c0103d64:	89 e5                	mov    %esp,%ebp
c0103d66:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103d69:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d6c:	83 e0 01             	and    $0x1,%eax
c0103d6f:	85 c0                	test   %eax,%eax
c0103d71:	75 1c                	jne    c0103d8f <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103d73:	c7 44 24 08 28 6d 10 	movl   $0xc0106d28,0x8(%esp)
c0103d7a:	c0 
c0103d7b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103d82:	00 
c0103d83:	c7 04 24 f3 6c 10 c0 	movl   $0xc0106cf3,(%esp)
c0103d8a:	e8 70 cf ff ff       	call   c0100cff <__panic>
    return pa2page(PTE_ADDR(pte));
c0103d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d97:	89 04 24             	mov    %eax,(%esp)
c0103d9a:	e8 1d ff ff ff       	call   c0103cbc <pa2page>
}
c0103d9f:	89 ec                	mov    %ebp,%esp
c0103da1:	5d                   	pop    %ebp
c0103da2:	c3                   	ret    

c0103da3 <pde2page>:
pde2page(pde_t pde) {
c0103da3:	55                   	push   %ebp
c0103da4:	89 e5                	mov    %esp,%ebp
c0103da6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103da9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103db1:	89 04 24             	mov    %eax,(%esp)
c0103db4:	e8 03 ff ff ff       	call   c0103cbc <pa2page>
}
c0103db9:	89 ec                	mov    %ebp,%esp
c0103dbb:	5d                   	pop    %ebp
c0103dbc:	c3                   	ret    

c0103dbd <page_ref>:
page_ref(struct Page *page) {
c0103dbd:	55                   	push   %ebp
c0103dbe:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dc3:	8b 00                	mov    (%eax),%eax
}
c0103dc5:	5d                   	pop    %ebp
c0103dc6:	c3                   	ret    

c0103dc7 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0103dc7:	55                   	push   %ebp
c0103dc8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103dd0:	89 10                	mov    %edx,(%eax)
}
c0103dd2:	90                   	nop
c0103dd3:	5d                   	pop    %ebp
c0103dd4:	c3                   	ret    

c0103dd5 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103dd5:	55                   	push   %ebp
c0103dd6:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ddb:	8b 00                	mov    (%eax),%eax
c0103ddd:	8d 50 01             	lea    0x1(%eax),%edx
c0103de0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103de3:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103de5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103de8:	8b 00                	mov    (%eax),%eax
}
c0103dea:	5d                   	pop    %ebp
c0103deb:	c3                   	ret    

c0103dec <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103dec:	55                   	push   %ebp
c0103ded:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103def:	8b 45 08             	mov    0x8(%ebp),%eax
c0103df2:	8b 00                	mov    (%eax),%eax
c0103df4:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103df7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dfa:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103dfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dff:	8b 00                	mov    (%eax),%eax
}
c0103e01:	5d                   	pop    %ebp
c0103e02:	c3                   	ret    

c0103e03 <__intr_save>:
__intr_save(void) {
c0103e03:	55                   	push   %ebp
c0103e04:	89 e5                	mov    %esp,%ebp
c0103e06:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103e09:	9c                   	pushf  
c0103e0a:	58                   	pop    %eax
c0103e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103e11:	25 00 02 00 00       	and    $0x200,%eax
c0103e16:	85 c0                	test   %eax,%eax
c0103e18:	74 0c                	je     c0103e26 <__intr_save+0x23>
        intr_disable();
c0103e1a:	e8 39 d9 ff ff       	call   c0101758 <intr_disable>
        return 1;
c0103e1f:	b8 01 00 00 00       	mov    $0x1,%eax
c0103e24:	eb 05                	jmp    c0103e2b <__intr_save+0x28>
    return 0;
c0103e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103e2b:	89 ec                	mov    %ebp,%esp
c0103e2d:	5d                   	pop    %ebp
c0103e2e:	c3                   	ret    

c0103e2f <__intr_restore>:
__intr_restore(bool flag) {
c0103e2f:	55                   	push   %ebp
c0103e30:	89 e5                	mov    %esp,%ebp
c0103e32:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103e35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103e39:	74 05                	je     c0103e40 <__intr_restore+0x11>
        intr_enable();
c0103e3b:	e8 10 d9 ff ff       	call   c0101750 <intr_enable>
}
c0103e40:	90                   	nop
c0103e41:	89 ec                	mov    %ebp,%esp
c0103e43:	5d                   	pop    %ebp
c0103e44:	c3                   	ret    

c0103e45 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103e45:	55                   	push   %ebp
c0103e46:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103e48:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e4b:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103e4e:	b8 23 00 00 00       	mov    $0x23,%eax
c0103e53:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103e55:	b8 23 00 00 00       	mov    $0x23,%eax
c0103e5a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103e5c:	b8 10 00 00 00       	mov    $0x10,%eax
c0103e61:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103e63:	b8 10 00 00 00       	mov    $0x10,%eax
c0103e68:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103e6a:	b8 10 00 00 00       	mov    $0x10,%eax
c0103e6f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103e71:	ea 78 3e 10 c0 08 00 	ljmp   $0x8,$0xc0103e78
}
c0103e78:	90                   	nop
c0103e79:	5d                   	pop    %ebp
c0103e7a:	c3                   	ret    

c0103e7b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103e7b:	55                   	push   %ebp
c0103e7c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103e7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e81:	a3 c4 ce 11 c0       	mov    %eax,0xc011cec4
}
c0103e86:	90                   	nop
c0103e87:	5d                   	pop    %ebp
c0103e88:	c3                   	ret    

c0103e89 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103e89:	55                   	push   %ebp
c0103e8a:	89 e5                	mov    %esp,%ebp
c0103e8c:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103e8f:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c0103e94:	89 04 24             	mov    %eax,(%esp)
c0103e97:	e8 df ff ff ff       	call   c0103e7b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103e9c:	66 c7 05 c8 ce 11 c0 	movw   $0x10,0xc011cec8
c0103ea3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103ea5:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c0103eac:	68 00 
c0103eae:	b8 c0 ce 11 c0       	mov    $0xc011cec0,%eax
c0103eb3:	0f b7 c0             	movzwl %ax,%eax
c0103eb6:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c0103ebc:	b8 c0 ce 11 c0       	mov    $0xc011cec0,%eax
c0103ec1:	c1 e8 10             	shr    $0x10,%eax
c0103ec4:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c0103ec9:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103ed0:	24 f0                	and    $0xf0,%al
c0103ed2:	0c 09                	or     $0x9,%al
c0103ed4:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103ed9:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103ee0:	24 ef                	and    $0xef,%al
c0103ee2:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103ee7:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103eee:	24 9f                	and    $0x9f,%al
c0103ef0:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103ef5:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103efc:	0c 80                	or     $0x80,%al
c0103efe:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103f03:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f0a:	24 f0                	and    $0xf0,%al
c0103f0c:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f11:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f18:	24 ef                	and    $0xef,%al
c0103f1a:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f1f:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f26:	24 df                	and    $0xdf,%al
c0103f28:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f2d:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f34:	0c 40                	or     $0x40,%al
c0103f36:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f3b:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f42:	24 7f                	and    $0x7f,%al
c0103f44:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f49:	b8 c0 ce 11 c0       	mov    $0xc011cec0,%eax
c0103f4e:	c1 e8 18             	shr    $0x18,%eax
c0103f51:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103f56:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c0103f5d:	e8 e3 fe ff ff       	call   c0103e45 <lgdt>
c0103f62:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103f68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103f6c:	0f 00 d8             	ltr    %ax
}
c0103f6f:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0103f70:	90                   	nop
c0103f71:	89 ec                	mov    %ebp,%esp
c0103f73:	5d                   	pop    %ebp
c0103f74:	c3                   	ret    

c0103f75 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103f75:	55                   	push   %ebp
c0103f76:	89 e5                	mov    %esp,%ebp
c0103f78:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103f7b:	c7 05 ac ce 11 c0 b8 	movl   $0xc0106cb8,0xc011ceac
c0103f82:	6c 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103f85:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c0103f8a:	8b 00                	mov    (%eax),%eax
c0103f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f90:	c7 04 24 54 6d 10 c0 	movl   $0xc0106d54,(%esp)
c0103f97:	e8 ba c3 ff ff       	call   c0100356 <cprintf>
    pmm_manager->init();
c0103f9c:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c0103fa1:	8b 40 04             	mov    0x4(%eax),%eax
c0103fa4:	ff d0                	call   *%eax
}
c0103fa6:	90                   	nop
c0103fa7:	89 ec                	mov    %ebp,%esp
c0103fa9:	5d                   	pop    %ebp
c0103faa:	c3                   	ret    

c0103fab <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103fab:	55                   	push   %ebp
c0103fac:	89 e5                	mov    %esp,%ebp
c0103fae:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103fb1:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c0103fb6:	8b 40 08             	mov    0x8(%eax),%eax
c0103fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103fbc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fc0:	8b 55 08             	mov    0x8(%ebp),%edx
c0103fc3:	89 14 24             	mov    %edx,(%esp)
c0103fc6:	ff d0                	call   *%eax
}
c0103fc8:	90                   	nop
c0103fc9:	89 ec                	mov    %ebp,%esp
c0103fcb:	5d                   	pop    %ebp
c0103fcc:	c3                   	ret    

c0103fcd <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103fcd:	55                   	push   %ebp
c0103fce:	89 e5                	mov    %esp,%ebp
c0103fd0:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103fd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103fda:	e8 24 fe ff ff       	call   c0103e03 <__intr_save>
c0103fdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103fe2:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c0103fe7:	8b 40 0c             	mov    0xc(%eax),%eax
c0103fea:	8b 55 08             	mov    0x8(%ebp),%edx
c0103fed:	89 14 24             	mov    %edx,(%esp)
c0103ff0:	ff d0                	call   *%eax
c0103ff2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ff8:	89 04 24             	mov    %eax,(%esp)
c0103ffb:	e8 2f fe ff ff       	call   c0103e2f <__intr_restore>
    return page;
c0104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104003:	89 ec                	mov    %ebp,%esp
c0104005:	5d                   	pop    %ebp
c0104006:	c3                   	ret    

c0104007 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104007:	55                   	push   %ebp
c0104008:	89 e5                	mov    %esp,%ebp
c010400a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010400d:	e8 f1 fd ff ff       	call   c0103e03 <__intr_save>
c0104012:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104015:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c010401a:	8b 40 10             	mov    0x10(%eax),%eax
c010401d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104020:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104024:	8b 55 08             	mov    0x8(%ebp),%edx
c0104027:	89 14 24             	mov    %edx,(%esp)
c010402a:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010402f:	89 04 24             	mov    %eax,(%esp)
c0104032:	e8 f8 fd ff ff       	call   c0103e2f <__intr_restore>
}
c0104037:	90                   	nop
c0104038:	89 ec                	mov    %ebp,%esp
c010403a:	5d                   	pop    %ebp
c010403b:	c3                   	ret    

c010403c <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010403c:	55                   	push   %ebp
c010403d:	89 e5                	mov    %esp,%ebp
c010403f:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104042:	e8 bc fd ff ff       	call   c0103e03 <__intr_save>
c0104047:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010404a:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c010404f:	8b 40 14             	mov    0x14(%eax),%eax
c0104052:	ff d0                	call   *%eax
c0104054:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010405a:	89 04 24             	mov    %eax,(%esp)
c010405d:	e8 cd fd ff ff       	call   c0103e2f <__intr_restore>
    return ret;
c0104062:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104065:	89 ec                	mov    %ebp,%esp
c0104067:	5d                   	pop    %ebp
c0104068:	c3                   	ret    

c0104069 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104069:	55                   	push   %ebp
c010406a:	89 e5                	mov    %esp,%ebp
c010406c:	57                   	push   %edi
c010406d:	56                   	push   %esi
c010406e:	53                   	push   %ebx
c010406f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104075:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010407c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104083:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010408a:	c7 04 24 6b 6d 10 c0 	movl   $0xc0106d6b,(%esp)
c0104091:	e8 c0 c2 ff ff       	call   c0100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104096:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010409d:	e9 0c 01 00 00       	jmp    c01041ae <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01040a2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040a8:	89 d0                	mov    %edx,%eax
c01040aa:	c1 e0 02             	shl    $0x2,%eax
c01040ad:	01 d0                	add    %edx,%eax
c01040af:	c1 e0 02             	shl    $0x2,%eax
c01040b2:	01 c8                	add    %ecx,%eax
c01040b4:	8b 50 08             	mov    0x8(%eax),%edx
c01040b7:	8b 40 04             	mov    0x4(%eax),%eax
c01040ba:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01040bd:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01040c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040c6:	89 d0                	mov    %edx,%eax
c01040c8:	c1 e0 02             	shl    $0x2,%eax
c01040cb:	01 d0                	add    %edx,%eax
c01040cd:	c1 e0 02             	shl    $0x2,%eax
c01040d0:	01 c8                	add    %ecx,%eax
c01040d2:	8b 48 0c             	mov    0xc(%eax),%ecx
c01040d5:	8b 58 10             	mov    0x10(%eax),%ebx
c01040d8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040db:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01040de:	01 c8                	add    %ecx,%eax
c01040e0:	11 da                	adc    %ebx,%edx
c01040e2:	89 45 98             	mov    %eax,-0x68(%ebp)
c01040e5:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01040e8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040ee:	89 d0                	mov    %edx,%eax
c01040f0:	c1 e0 02             	shl    $0x2,%eax
c01040f3:	01 d0                	add    %edx,%eax
c01040f5:	c1 e0 02             	shl    $0x2,%eax
c01040f8:	01 c8                	add    %ecx,%eax
c01040fa:	83 c0 14             	add    $0x14,%eax
c01040fd:	8b 00                	mov    (%eax),%eax
c01040ff:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104105:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104108:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010410b:	83 c0 ff             	add    $0xffffffff,%eax
c010410e:	83 d2 ff             	adc    $0xffffffff,%edx
c0104111:	89 c6                	mov    %eax,%esi
c0104113:	89 d7                	mov    %edx,%edi
c0104115:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104118:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010411b:	89 d0                	mov    %edx,%eax
c010411d:	c1 e0 02             	shl    $0x2,%eax
c0104120:	01 d0                	add    %edx,%eax
c0104122:	c1 e0 02             	shl    $0x2,%eax
c0104125:	01 c8                	add    %ecx,%eax
c0104127:	8b 48 0c             	mov    0xc(%eax),%ecx
c010412a:	8b 58 10             	mov    0x10(%eax),%ebx
c010412d:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104133:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104137:	89 74 24 14          	mov    %esi,0x14(%esp)
c010413b:	89 7c 24 18          	mov    %edi,0x18(%esp)
c010413f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104142:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104145:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104149:	89 54 24 10          	mov    %edx,0x10(%esp)
c010414d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104151:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104155:	c7 04 24 78 6d 10 c0 	movl   $0xc0106d78,(%esp)
c010415c:	e8 f5 c1 ff ff       	call   c0100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104161:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104164:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104167:	89 d0                	mov    %edx,%eax
c0104169:	c1 e0 02             	shl    $0x2,%eax
c010416c:	01 d0                	add    %edx,%eax
c010416e:	c1 e0 02             	shl    $0x2,%eax
c0104171:	01 c8                	add    %ecx,%eax
c0104173:	83 c0 14             	add    $0x14,%eax
c0104176:	8b 00                	mov    (%eax),%eax
c0104178:	83 f8 01             	cmp    $0x1,%eax
c010417b:	75 2e                	jne    c01041ab <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c010417d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104180:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104183:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104186:	89 d0                	mov    %edx,%eax
c0104188:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c010418b:	73 1e                	jae    c01041ab <page_init+0x142>
c010418d:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104192:	b8 00 00 00 00       	mov    $0x0,%eax
c0104197:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c010419a:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010419d:	72 0c                	jb     c01041ab <page_init+0x142>
                maxpa = end;
c010419f:	8b 45 98             	mov    -0x68(%ebp),%eax
c01041a2:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01041a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01041a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c01041ab:	ff 45 dc             	incl   -0x24(%ebp)
c01041ae:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01041b1:	8b 00                	mov    (%eax),%eax
c01041b3:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01041b6:	0f 8c e6 fe ff ff    	jl     c01040a2 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01041bc:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01041c1:	b8 00 00 00 00       	mov    $0x0,%eax
c01041c6:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c01041c9:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c01041cc:	73 0e                	jae    c01041dc <page_init+0x173>
        maxpa = KMEMSIZE;
c01041ce:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01041d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01041dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01041df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01041e2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01041e6:	c1 ea 0c             	shr    $0xc,%edx
c01041e9:	a3 a4 ce 11 c0       	mov    %eax,0xc011cea4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01041ee:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01041f5:	b8 2c cf 11 c0       	mov    $0xc011cf2c,%eax
c01041fa:	8d 50 ff             	lea    -0x1(%eax),%edx
c01041fd:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104200:	01 d0                	add    %edx,%eax
c0104202:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104205:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104208:	ba 00 00 00 00       	mov    $0x0,%edx
c010420d:	f7 75 c0             	divl   -0x40(%ebp)
c0104210:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104213:	29 d0                	sub    %edx,%eax
c0104215:	a3 a0 ce 11 c0       	mov    %eax,0xc011cea0

    for (i = 0; i < npage; i ++) {
c010421a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104221:	eb 2f                	jmp    c0104252 <page_init+0x1e9>
        SetPageReserved(pages + i);
c0104223:	8b 0d a0 ce 11 c0    	mov    0xc011cea0,%ecx
c0104229:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010422c:	89 d0                	mov    %edx,%eax
c010422e:	c1 e0 02             	shl    $0x2,%eax
c0104231:	01 d0                	add    %edx,%eax
c0104233:	c1 e0 02             	shl    $0x2,%eax
c0104236:	01 c8                	add    %ecx,%eax
c0104238:	83 c0 04             	add    $0x4,%eax
c010423b:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0104242:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104245:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104248:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010424b:	0f ab 10             	bts    %edx,(%eax)
}
c010424e:	90                   	nop
    for (i = 0; i < npage; i ++) {
c010424f:	ff 45 dc             	incl   -0x24(%ebp)
c0104252:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104255:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c010425a:	39 c2                	cmp    %eax,%edx
c010425c:	72 c5                	jb     c0104223 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010425e:	8b 15 a4 ce 11 c0    	mov    0xc011cea4,%edx
c0104264:	89 d0                	mov    %edx,%eax
c0104266:	c1 e0 02             	shl    $0x2,%eax
c0104269:	01 d0                	add    %edx,%eax
c010426b:	c1 e0 02             	shl    $0x2,%eax
c010426e:	89 c2                	mov    %eax,%edx
c0104270:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0104275:	01 d0                	add    %edx,%eax
c0104277:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010427a:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104281:	77 23                	ja     c01042a6 <page_init+0x23d>
c0104283:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104286:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010428a:	c7 44 24 08 a8 6d 10 	movl   $0xc0106da8,0x8(%esp)
c0104291:	c0 
c0104292:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0104299:	00 
c010429a:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01042a1:	e8 59 ca ff ff       	call   c0100cff <__panic>
c01042a6:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01042a9:	05 00 00 00 40       	add    $0x40000000,%eax
c01042ae:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01042b1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01042b8:	e9 53 01 00 00       	jmp    c0104410 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01042bd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01042c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01042c3:	89 d0                	mov    %edx,%eax
c01042c5:	c1 e0 02             	shl    $0x2,%eax
c01042c8:	01 d0                	add    %edx,%eax
c01042ca:	c1 e0 02             	shl    $0x2,%eax
c01042cd:	01 c8                	add    %ecx,%eax
c01042cf:	8b 50 08             	mov    0x8(%eax),%edx
c01042d2:	8b 40 04             	mov    0x4(%eax),%eax
c01042d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01042d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01042db:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01042de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01042e1:	89 d0                	mov    %edx,%eax
c01042e3:	c1 e0 02             	shl    $0x2,%eax
c01042e6:	01 d0                	add    %edx,%eax
c01042e8:	c1 e0 02             	shl    $0x2,%eax
c01042eb:	01 c8                	add    %ecx,%eax
c01042ed:	8b 48 0c             	mov    0xc(%eax),%ecx
c01042f0:	8b 58 10             	mov    0x10(%eax),%ebx
c01042f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01042f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01042f9:	01 c8                	add    %ecx,%eax
c01042fb:	11 da                	adc    %ebx,%edx
c01042fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104300:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104303:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104306:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104309:	89 d0                	mov    %edx,%eax
c010430b:	c1 e0 02             	shl    $0x2,%eax
c010430e:	01 d0                	add    %edx,%eax
c0104310:	c1 e0 02             	shl    $0x2,%eax
c0104313:	01 c8                	add    %ecx,%eax
c0104315:	83 c0 14             	add    $0x14,%eax
c0104318:	8b 00                	mov    (%eax),%eax
c010431a:	83 f8 01             	cmp    $0x1,%eax
c010431d:	0f 85 ea 00 00 00    	jne    c010440d <page_init+0x3a4>
            if (begin < freemem) {
c0104323:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104326:	ba 00 00 00 00       	mov    $0x0,%edx
c010432b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010432e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104331:	19 d1                	sbb    %edx,%ecx
c0104333:	73 0d                	jae    c0104342 <page_init+0x2d9>
                begin = freemem;
c0104335:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104338:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010433b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104342:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104347:	b8 00 00 00 00       	mov    $0x0,%eax
c010434c:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c010434f:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104352:	73 0e                	jae    c0104362 <page_init+0x2f9>
                end = KMEMSIZE;
c0104354:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010435b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104362:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104365:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104368:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010436b:	89 d0                	mov    %edx,%eax
c010436d:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104370:	0f 83 97 00 00 00    	jae    c010440d <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
c0104376:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c010437d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104380:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104383:	01 d0                	add    %edx,%eax
c0104385:	48                   	dec    %eax
c0104386:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104389:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010438c:	ba 00 00 00 00       	mov    $0x0,%edx
c0104391:	f7 75 b0             	divl   -0x50(%ebp)
c0104394:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104397:	29 d0                	sub    %edx,%eax
c0104399:	ba 00 00 00 00       	mov    $0x0,%edx
c010439e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01043a1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01043a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043a7:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01043aa:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01043ad:	ba 00 00 00 00       	mov    $0x0,%edx
c01043b2:	89 c7                	mov    %eax,%edi
c01043b4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01043ba:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01043bd:	89 d0                	mov    %edx,%eax
c01043bf:	83 e0 00             	and    $0x0,%eax
c01043c2:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01043c5:	8b 45 80             	mov    -0x80(%ebp),%eax
c01043c8:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01043cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01043ce:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01043d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043d7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01043da:	89 d0                	mov    %edx,%eax
c01043dc:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01043df:	73 2c                	jae    c010440d <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01043e1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043e4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01043e7:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01043ea:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01043ed:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01043f1:	c1 ea 0c             	shr    $0xc,%edx
c01043f4:	89 c3                	mov    %eax,%ebx
c01043f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043f9:	89 04 24             	mov    %eax,(%esp)
c01043fc:	e8 bb f8 ff ff       	call   c0103cbc <pa2page>
c0104401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104405:	89 04 24             	mov    %eax,(%esp)
c0104408:	e8 9e fb ff ff       	call   c0103fab <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010440d:	ff 45 dc             	incl   -0x24(%ebp)
c0104410:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104413:	8b 00                	mov    (%eax),%eax
c0104415:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104418:	0f 8c 9f fe ff ff    	jl     c01042bd <page_init+0x254>
                }
            }
        }
    }
}
c010441e:	90                   	nop
c010441f:	90                   	nop
c0104420:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104426:	5b                   	pop    %ebx
c0104427:	5e                   	pop    %esi
c0104428:	5f                   	pop    %edi
c0104429:	5d                   	pop    %ebp
c010442a:	c3                   	ret    

c010442b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010442b:	55                   	push   %ebp
c010442c:	89 e5                	mov    %esp,%ebp
c010442e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104431:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104434:	33 45 14             	xor    0x14(%ebp),%eax
c0104437:	25 ff 0f 00 00       	and    $0xfff,%eax
c010443c:	85 c0                	test   %eax,%eax
c010443e:	74 24                	je     c0104464 <boot_map_segment+0x39>
c0104440:	c7 44 24 0c da 6d 10 	movl   $0xc0106dda,0xc(%esp)
c0104447:	c0 
c0104448:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010444f:	c0 
c0104450:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104457:	00 
c0104458:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010445f:	e8 9b c8 ff ff       	call   c0100cff <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104464:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010446b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010446e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104473:	89 c2                	mov    %eax,%edx
c0104475:	8b 45 10             	mov    0x10(%ebp),%eax
c0104478:	01 c2                	add    %eax,%edx
c010447a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010447d:	01 d0                	add    %edx,%eax
c010447f:	48                   	dec    %eax
c0104480:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104483:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104486:	ba 00 00 00 00       	mov    $0x0,%edx
c010448b:	f7 75 f0             	divl   -0x10(%ebp)
c010448e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104491:	29 d0                	sub    %edx,%eax
c0104493:	c1 e8 0c             	shr    $0xc,%eax
c0104496:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104499:	8b 45 0c             	mov    0xc(%ebp),%eax
c010449c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010449f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01044a7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01044aa:	8b 45 14             	mov    0x14(%ebp),%eax
c01044ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01044b8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01044bb:	eb 68                	jmp    c0104525 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01044bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01044c4:	00 
c01044c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01044cf:	89 04 24             	mov    %eax,(%esp)
c01044d2:	e8 88 01 00 00       	call   c010465f <get_pte>
c01044d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01044da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01044de:	75 24                	jne    c0104504 <boot_map_segment+0xd9>
c01044e0:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c01044e7:	c0 
c01044e8:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c01044ef:	c0 
c01044f0:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01044f7:	00 
c01044f8:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01044ff:	e8 fb c7 ff ff       	call   c0100cff <__panic>
        *ptep = pa | PTE_P | perm;
c0104504:	8b 45 14             	mov    0x14(%ebp),%eax
c0104507:	0b 45 18             	or     0x18(%ebp),%eax
c010450a:	83 c8 01             	or     $0x1,%eax
c010450d:	89 c2                	mov    %eax,%edx
c010450f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104512:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104514:	ff 4d f4             	decl   -0xc(%ebp)
c0104517:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010451e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104525:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104529:	75 92                	jne    c01044bd <boot_map_segment+0x92>
    }
}
c010452b:	90                   	nop
c010452c:	90                   	nop
c010452d:	89 ec                	mov    %ebp,%esp
c010452f:	5d                   	pop    %ebp
c0104530:	c3                   	ret    

c0104531 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104531:	55                   	push   %ebp
c0104532:	89 e5                	mov    %esp,%ebp
c0104534:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104537:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010453e:	e8 8a fa ff ff       	call   c0103fcd <alloc_pages>
c0104543:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010454a:	75 1c                	jne    c0104568 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010454c:	c7 44 24 08 13 6e 10 	movl   $0xc0106e13,0x8(%esp)
c0104553:	c0 
c0104554:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010455b:	00 
c010455c:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104563:	e8 97 c7 ff ff       	call   c0100cff <__panic>
    }
    return page2kva(p);
c0104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010456b:	89 04 24             	mov    %eax,(%esp)
c010456e:	e8 9a f7 ff ff       	call   c0103d0d <page2kva>
}
c0104573:	89 ec                	mov    %ebp,%esp
c0104575:	5d                   	pop    %ebp
c0104576:	c3                   	ret    

c0104577 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104577:	55                   	push   %ebp
c0104578:	89 e5                	mov    %esp,%ebp
c010457a:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010457d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104582:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104585:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010458c:	77 23                	ja     c01045b1 <pmm_init+0x3a>
c010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104591:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104595:	c7 44 24 08 a8 6d 10 	movl   $0xc0106da8,0x8(%esp)
c010459c:	c0 
c010459d:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01045a4:	00 
c01045a5:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01045ac:	e8 4e c7 ff ff       	call   c0100cff <__panic>
c01045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b4:	05 00 00 00 40       	add    $0x40000000,%eax
c01045b9:	a3 a8 ce 11 c0       	mov    %eax,0xc011cea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01045be:	e8 b2 f9 ff ff       	call   c0103f75 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01045c3:	e8 a1 fa ff ff       	call   c0104069 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01045c8:	e8 51 04 00 00       	call   c0104a1e <check_alloc_page>

    check_pgdir();
c01045cd:	e8 6d 04 00 00       	call   c0104a3f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01045d2:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01045d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045da:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01045e1:	77 23                	ja     c0104606 <pmm_init+0x8f>
c01045e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045ea:	c7 44 24 08 a8 6d 10 	movl   $0xc0106da8,0x8(%esp)
c01045f1:	c0 
c01045f2:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01045f9:	00 
c01045fa:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104601:	e8 f9 c6 ff ff       	call   c0100cff <__panic>
c0104606:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104609:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010460f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104614:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104619:	83 ca 03             	or     $0x3,%edx
c010461c:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010461e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104623:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010462a:	00 
c010462b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104632:	00 
c0104633:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010463a:	38 
c010463b:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104642:	c0 
c0104643:	89 04 24             	mov    %eax,(%esp)
c0104646:	e8 e0 fd ff ff       	call   c010442b <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010464b:	e8 39 f8 ff ff       	call   c0103e89 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104650:	e8 88 0a 00 00       	call   c01050dd <check_boot_pgdir>

    print_pgdir();
c0104655:	e8 05 0f 00 00       	call   c010555f <print_pgdir>

}
c010465a:	90                   	nop
c010465b:	89 ec                	mov    %ebp,%esp
c010465d:	5d                   	pop    %ebp
c010465e:	c3                   	ret    

c010465f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010465f:	55                   	push   %ebp
c0104660:	89 e5                	mov    %esp,%ebp
c0104662:	83 ec 38             	sub    $0x38,%esp
    }
    return NULL;          // (8) return page table entry
#endif

    
    pde_t *pdep=pgdir+PDX(la);
c0104665:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104668:	c1 e8 16             	shr    $0x16,%eax
c010466b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104672:	8b 45 08             	mov    0x8(%ebp),%eax
c0104675:	01 d0                	add    %edx,%eax
c0104677:	89 45 f4             	mov    %eax,-0xc(%ebp)

    pte_t *ptep=((pte_t*)KADDR(*pdep& ~0xfff))+PTX(la);
c010467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010467d:	8b 00                	mov    (%eax),%eax
c010467f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104684:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104687:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010468a:	c1 e8 0c             	shr    $0xc,%eax
c010468d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104690:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c0104695:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104698:	72 23                	jb     c01046bd <get_pte+0x5e>
c010469a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010469d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046a1:	c7 44 24 08 04 6d 10 	movl   $0xc0106d04,0x8(%esp)
c01046a8:	c0 
c01046a9:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
c01046b0:	00 
c01046b1:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01046b8:	e8 42 c6 ff ff       	call   c0100cff <__panic>
c01046bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01046c5:	89 c2                	mov    %eax,%edx
c01046c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046ca:	c1 e8 0c             	shr    $0xc,%eax
c01046cd:	25 ff 03 00 00       	and    $0x3ff,%eax
c01046d2:	c1 e0 02             	shl    $0x2,%eax
c01046d5:	01 d0                	add    %edx,%eax
c01046d7:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(*pdep & PTE_P) return ptep;
c01046da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046dd:	8b 00                	mov    (%eax),%eax
c01046df:	83 e0 01             	and    $0x1,%eax
c01046e2:	85 c0                	test   %eax,%eax
c01046e4:	74 08                	je     c01046ee <get_pte+0x8f>
c01046e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046e9:	e9 dd 00 00 00       	jmp    c01047cb <get_pte+0x16c>
    
    if (!create) return NULL;
c01046ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01046f2:	75 0a                	jne    c01046fe <get_pte+0x9f>
c01046f4:	b8 00 00 00 00       	mov    $0x0,%eax
c01046f9:	e9 cd 00 00 00       	jmp    c01047cb <get_pte+0x16c>

   struct Page *p=alloc_page();
c01046fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104705:	e8 c3 f8 ff ff       	call   c0103fcd <alloc_pages>
c010470a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   if(p==NULL) return NULL;
c010470d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104711:	75 0a                	jne    c010471d <get_pte+0xbe>
c0104713:	b8 00 00 00 00       	mov    $0x0,%eax
c0104718:	e9 ae 00 00 00       	jmp    c01047cb <get_pte+0x16c>

   set_page_ref(p,1);
c010471d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104724:	00 
c0104725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104728:	89 04 24             	mov    %eax,(%esp)
c010472b:	e8 97 f6 ff ff       	call   c0103dc7 <set_page_ref>

   ptep= KADDR(page2pa(p));
c0104730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104733:	89 04 24             	mov    %eax,(%esp)
c0104736:	e8 69 f5 ff ff       	call   c0103ca4 <page2pa>
c010473b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010473e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104741:	c1 e8 0c             	shr    $0xc,%eax
c0104744:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104747:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c010474c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010474f:	72 23                	jb     c0104774 <get_pte+0x115>
c0104751:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104754:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104758:	c7 44 24 08 04 6d 10 	movl   $0xc0106d04,0x8(%esp)
c010475f:	c0 
c0104760:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
c0104767:	00 
c0104768:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010476f:	e8 8b c5 ff ff       	call   c0100cff <__panic>
c0104774:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104777:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010477c:	89 45 e8             	mov    %eax,-0x18(%ebp)

   memset(ptep,0,PGSIZE);
c010477f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104786:	00 
c0104787:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010478e:	00 
c010478f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104792:	89 04 24             	mov    %eax,(%esp)
c0104795:	e8 ca 18 00 00       	call   c0106064 <memset>

   //更改原来的页目录项
   *pdep=(page2pa(p)&~0xfff)|PTE_U|PTE_P|PTE_W;
c010479a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010479d:	89 04 24             	mov    %eax,(%esp)
c01047a0:	e8 ff f4 ff ff       	call   c0103ca4 <page2pa>
c01047a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047aa:	83 c8 07             	or     $0x7,%eax
c01047ad:	89 c2                	mov    %eax,%edx
c01047af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047b2:	89 10                	mov    %edx,(%eax)

   return ptep+PTX(la);
c01047b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047b7:	c1 e8 0c             	shr    $0xc,%eax
c01047ba:	25 ff 03 00 00       	and    $0x3ff,%eax
c01047bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01047c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047c9:	01 d0                	add    %edx,%eax
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];*/


}
c01047cb:	89 ec                	mov    %ebp,%esp
c01047cd:	5d                   	pop    %ebp
c01047ce:	c3                   	ret    

c01047cf <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01047cf:	55                   	push   %ebp
c01047d0:	89 e5                	mov    %esp,%ebp
c01047d2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01047d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01047dc:	00 
c01047dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01047e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e7:	89 04 24             	mov    %eax,(%esp)
c01047ea:	e8 70 fe ff ff       	call   c010465f <get_pte>
c01047ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01047f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01047f6:	74 08                	je     c0104800 <get_page+0x31>
        *ptep_store = ptep;
c01047f8:	8b 45 10             	mov    0x10(%ebp),%eax
c01047fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01047fe:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104800:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104804:	74 1b                	je     c0104821 <get_page+0x52>
c0104806:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104809:	8b 00                	mov    (%eax),%eax
c010480b:	83 e0 01             	and    $0x1,%eax
c010480e:	85 c0                	test   %eax,%eax
c0104810:	74 0f                	je     c0104821 <get_page+0x52>
        return pte2page(*ptep);
c0104812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104815:	8b 00                	mov    (%eax),%eax
c0104817:	89 04 24             	mov    %eax,(%esp)
c010481a:	e8 44 f5 ff ff       	call   c0103d63 <pte2page>
c010481f:	eb 05                	jmp    c0104826 <get_page+0x57>
    }
    return NULL;
c0104821:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104826:	89 ec                	mov    %ebp,%esp
c0104828:	5d                   	pop    %ebp
c0104829:	c3                   	ret    

c010482a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010482a:	55                   	push   %ebp
c010482b:	89 e5                	mov    %esp,%ebp
c010482d:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    assert(*ptep & PTE_P);
c0104830:	8b 45 10             	mov    0x10(%ebp),%eax
c0104833:	8b 00                	mov    (%eax),%eax
c0104835:	83 e0 01             	and    $0x1,%eax
c0104838:	85 c0                	test   %eax,%eax
c010483a:	75 24                	jne    c0104860 <page_remove_pte+0x36>
c010483c:	c7 44 24 0c 2c 6e 10 	movl   $0xc0106e2c,0xc(%esp)
c0104843:	c0 
c0104844:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010484b:	c0 
c010484c:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
c0104853:	00 
c0104854:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010485b:	e8 9f c4 ff ff       	call   c0100cff <__panic>
    struct Page *p=pte2page(*ptep);
c0104860:	8b 45 10             	mov    0x10(%ebp),%eax
c0104863:	8b 00                	mov    (%eax),%eax
c0104865:	89 04 24             	mov    %eax,(%esp)
c0104868:	e8 f6 f4 ff ff       	call   c0103d63 <pte2page>
c010486d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    page_ref_dec(p);
c0104870:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104873:	89 04 24             	mov    %eax,(%esp)
c0104876:	e8 71 f5 ff ff       	call   c0103dec <page_ref_dec>
    if(p->ref==0)
c010487b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010487e:	8b 00                	mov    (%eax),%eax
c0104880:	85 c0                	test   %eax,%eax
c0104882:	75 13                	jne    c0104897 <page_remove_pte+0x6d>
    {
        free_page(p);
c0104884:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010488b:	00 
c010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010488f:	89 04 24             	mov    %eax,(%esp)
c0104892:	e8 70 f7 ff ff       	call   c0104007 <free_pages>
    }
    *ptep&=~(PTE_P);
c0104897:	8b 45 10             	mov    0x10(%ebp),%eax
c010489a:	8b 00                	mov    (%eax),%eax
c010489c:	83 e0 fe             	and    $0xfffffffe,%eax
c010489f:	89 c2                	mov    %eax,%edx
c01048a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01048a4:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir,la);
c01048a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01048b0:	89 04 24             	mov    %eax,(%esp)
c01048b3:	e8 07 01 00 00       	call   c01049bf <tlb_invalidate>
        *ptep = 0;
        tlb_invalidate(pgdir, la);
    }*/


}
c01048b8:	90                   	nop
c01048b9:	89 ec                	mov    %ebp,%esp
c01048bb:	5d                   	pop    %ebp
c01048bc:	c3                   	ret    

c01048bd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01048bd:	55                   	push   %ebp
c01048be:	89 e5                	mov    %esp,%ebp
c01048c0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01048c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048ca:	00 
c01048cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01048d5:	89 04 24             	mov    %eax,(%esp)
c01048d8:	e8 82 fd ff ff       	call   c010465f <get_pte>
c01048dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01048e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048e4:	74 19                	je     c01048ff <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01048ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01048f7:	89 04 24             	mov    %eax,(%esp)
c01048fa:	e8 2b ff ff ff       	call   c010482a <page_remove_pte>
    }
}
c01048ff:	90                   	nop
c0104900:	89 ec                	mov    %ebp,%esp
c0104902:	5d                   	pop    %ebp
c0104903:	c3                   	ret    

c0104904 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104904:	55                   	push   %ebp
c0104905:	89 e5                	mov    %esp,%ebp
c0104907:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010490a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104911:	00 
c0104912:	8b 45 10             	mov    0x10(%ebp),%eax
c0104915:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104919:	8b 45 08             	mov    0x8(%ebp),%eax
c010491c:	89 04 24             	mov    %eax,(%esp)
c010491f:	e8 3b fd ff ff       	call   c010465f <get_pte>
c0104924:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104927:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010492b:	75 0a                	jne    c0104937 <page_insert+0x33>
        return -E_NO_MEM;
c010492d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0104932:	e9 84 00 00 00       	jmp    c01049bb <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104937:	8b 45 0c             	mov    0xc(%ebp),%eax
c010493a:	89 04 24             	mov    %eax,(%esp)
c010493d:	e8 93 f4 ff ff       	call   c0103dd5 <page_ref_inc>
    if (*ptep & PTE_P) {
c0104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104945:	8b 00                	mov    (%eax),%eax
c0104947:	83 e0 01             	and    $0x1,%eax
c010494a:	85 c0                	test   %eax,%eax
c010494c:	74 3e                	je     c010498c <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010494e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104951:	8b 00                	mov    (%eax),%eax
c0104953:	89 04 24             	mov    %eax,(%esp)
c0104956:	e8 08 f4 ff ff       	call   c0103d63 <pte2page>
c010495b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010495e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104961:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104964:	75 0d                	jne    c0104973 <page_insert+0x6f>
            page_ref_dec(page);
c0104966:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104969:	89 04 24             	mov    %eax,(%esp)
c010496c:	e8 7b f4 ff ff       	call   c0103dec <page_ref_dec>
c0104971:	eb 19                	jmp    c010498c <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104976:	89 44 24 08          	mov    %eax,0x8(%esp)
c010497a:	8b 45 10             	mov    0x10(%ebp),%eax
c010497d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104981:	8b 45 08             	mov    0x8(%ebp),%eax
c0104984:	89 04 24             	mov    %eax,(%esp)
c0104987:	e8 9e fe ff ff       	call   c010482a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010498c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010498f:	89 04 24             	mov    %eax,(%esp)
c0104992:	e8 0d f3 ff ff       	call   c0103ca4 <page2pa>
c0104997:	0b 45 14             	or     0x14(%ebp),%eax
c010499a:	83 c8 01             	or     $0x1,%eax
c010499d:	89 c2                	mov    %eax,%edx
c010499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01049a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01049a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01049ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01049ae:	89 04 24             	mov    %eax,(%esp)
c01049b1:	e8 09 00 00 00       	call   c01049bf <tlb_invalidate>
    return 0;
c01049b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01049bb:	89 ec                	mov    %ebp,%esp
c01049bd:	5d                   	pop    %ebp
c01049be:	c3                   	ret    

c01049bf <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01049bf:	55                   	push   %ebp
c01049c0:	89 e5                	mov    %esp,%ebp
c01049c2:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01049c5:	0f 20 d8             	mov    %cr3,%eax
c01049c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01049cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01049ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01049d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049d4:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01049db:	77 23                	ja     c0104a00 <tlb_invalidate+0x41>
c01049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049e4:	c7 44 24 08 a8 6d 10 	movl   $0xc0106da8,0x8(%esp)
c01049eb:	c0 
c01049ec:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c01049f3:	00 
c01049f4:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01049fb:	e8 ff c2 ff ff       	call   c0100cff <__panic>
c0104a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a03:	05 00 00 00 40       	add    $0x40000000,%eax
c0104a08:	39 d0                	cmp    %edx,%eax
c0104a0a:	75 0d                	jne    c0104a19 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0104a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104a12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a15:	0f 01 38             	invlpg (%eax)
}
c0104a18:	90                   	nop
    }
}
c0104a19:	90                   	nop
c0104a1a:	89 ec                	mov    %ebp,%esp
c0104a1c:	5d                   	pop    %ebp
c0104a1d:	c3                   	ret    

c0104a1e <check_alloc_page>:

static void
check_alloc_page(void) {
c0104a1e:	55                   	push   %ebp
c0104a1f:	89 e5                	mov    %esp,%ebp
c0104a21:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104a24:	a1 ac ce 11 c0       	mov    0xc011ceac,%eax
c0104a29:	8b 40 18             	mov    0x18(%eax),%eax
c0104a2c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104a2e:	c7 04 24 3c 6e 10 c0 	movl   $0xc0106e3c,(%esp)
c0104a35:	e8 1c b9 ff ff       	call   c0100356 <cprintf>
}
c0104a3a:	90                   	nop
c0104a3b:	89 ec                	mov    %ebp,%esp
c0104a3d:	5d                   	pop    %ebp
c0104a3e:	c3                   	ret    

c0104a3f <check_pgdir>:

static void
check_pgdir(void) {
c0104a3f:	55                   	push   %ebp
c0104a40:	89 e5                	mov    %esp,%ebp
c0104a42:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104a45:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c0104a4a:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104a4f:	76 24                	jbe    c0104a75 <check_pgdir+0x36>
c0104a51:	c7 44 24 0c 5b 6e 10 	movl   $0xc0106e5b,0xc(%esp)
c0104a58:	c0 
c0104a59:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104a60:	c0 
c0104a61:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104a68:	00 
c0104a69:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104a70:	e8 8a c2 ff ff       	call   c0100cff <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104a75:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104a7a:	85 c0                	test   %eax,%eax
c0104a7c:	74 0e                	je     c0104a8c <check_pgdir+0x4d>
c0104a7e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104a83:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104a88:	85 c0                	test   %eax,%eax
c0104a8a:	74 24                	je     c0104ab0 <check_pgdir+0x71>
c0104a8c:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c0104a93:	c0 
c0104a94:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104a9b:	c0 
c0104a9c:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0104aa3:	00 
c0104aa4:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104aab:	e8 4f c2 ff ff       	call   c0100cff <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104ab0:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ab5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104abc:	00 
c0104abd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ac4:	00 
c0104ac5:	89 04 24             	mov    %eax,(%esp)
c0104ac8:	e8 02 fd ff ff       	call   c01047cf <get_page>
c0104acd:	85 c0                	test   %eax,%eax
c0104acf:	74 24                	je     c0104af5 <check_pgdir+0xb6>
c0104ad1:	c7 44 24 0c b0 6e 10 	movl   $0xc0106eb0,0xc(%esp)
c0104ad8:	c0 
c0104ad9:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104ae0:	c0 
c0104ae1:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104ae8:	00 
c0104ae9:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104af0:	e8 0a c2 ff ff       	call   c0100cff <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104af5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104afc:	e8 cc f4 ff ff       	call   c0103fcd <alloc_pages>
c0104b01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104b04:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104b09:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104b10:	00 
c0104b11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b18:	00 
c0104b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b1c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b20:	89 04 24             	mov    %eax,(%esp)
c0104b23:	e8 dc fd ff ff       	call   c0104904 <page_insert>
c0104b28:	85 c0                	test   %eax,%eax
c0104b2a:	74 24                	je     c0104b50 <check_pgdir+0x111>
c0104b2c:	c7 44 24 0c d8 6e 10 	movl   $0xc0106ed8,0xc(%esp)
c0104b33:	c0 
c0104b34:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104b3b:	c0 
c0104b3c:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104b43:	00 
c0104b44:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104b4b:	e8 af c1 ff ff       	call   c0100cff <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104b50:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104b55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b5c:	00 
c0104b5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b64:	00 
c0104b65:	89 04 24             	mov    %eax,(%esp)
c0104b68:	e8 f2 fa ff ff       	call   c010465f <get_pte>
c0104b6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b74:	75 24                	jne    c0104b9a <check_pgdir+0x15b>
c0104b76:	c7 44 24 0c 04 6f 10 	movl   $0xc0106f04,0xc(%esp)
c0104b7d:	c0 
c0104b7e:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104b85:	c0 
c0104b86:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104b8d:	00 
c0104b8e:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104b95:	e8 65 c1 ff ff       	call   c0100cff <__panic>
    assert(pte2page(*ptep) == p1);
c0104b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b9d:	8b 00                	mov    (%eax),%eax
c0104b9f:	89 04 24             	mov    %eax,(%esp)
c0104ba2:	e8 bc f1 ff ff       	call   c0103d63 <pte2page>
c0104ba7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104baa:	74 24                	je     c0104bd0 <check_pgdir+0x191>
c0104bac:	c7 44 24 0c 31 6f 10 	movl   $0xc0106f31,0xc(%esp)
c0104bb3:	c0 
c0104bb4:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104bbb:	c0 
c0104bbc:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104bc3:	00 
c0104bc4:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104bcb:	e8 2f c1 ff ff       	call   c0100cff <__panic>
    assert(page_ref(p1) == 1);
c0104bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd3:	89 04 24             	mov    %eax,(%esp)
c0104bd6:	e8 e2 f1 ff ff       	call   c0103dbd <page_ref>
c0104bdb:	83 f8 01             	cmp    $0x1,%eax
c0104bde:	74 24                	je     c0104c04 <check_pgdir+0x1c5>
c0104be0:	c7 44 24 0c 47 6f 10 	movl   $0xc0106f47,0xc(%esp)
c0104be7:	c0 
c0104be8:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104bef:	c0 
c0104bf0:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104bf7:	00 
c0104bf8:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104bff:	e8 fb c0 ff ff       	call   c0100cff <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104c04:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104c09:	8b 00                	mov    (%eax),%eax
c0104c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104c10:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c16:	c1 e8 0c             	shr    $0xc,%eax
c0104c19:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104c1c:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c0104c21:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104c24:	72 23                	jb     c0104c49 <check_pgdir+0x20a>
c0104c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104c2d:	c7 44 24 08 04 6d 10 	movl   $0xc0106d04,0x8(%esp)
c0104c34:	c0 
c0104c35:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104c3c:	00 
c0104c3d:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104c44:	e8 b6 c0 ff ff       	call   c0100cff <__panic>
c0104c49:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c4c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104c51:	83 c0 04             	add    $0x4,%eax
c0104c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104c57:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104c5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c63:	00 
c0104c64:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c6b:	00 
c0104c6c:	89 04 24             	mov    %eax,(%esp)
c0104c6f:	e8 eb f9 ff ff       	call   c010465f <get_pte>
c0104c74:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104c77:	74 24                	je     c0104c9d <check_pgdir+0x25e>
c0104c79:	c7 44 24 0c 5c 6f 10 	movl   $0xc0106f5c,0xc(%esp)
c0104c80:	c0 
c0104c81:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104c88:	c0 
c0104c89:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104c90:	00 
c0104c91:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104c98:	e8 62 c0 ff ff       	call   c0100cff <__panic>

    p2 = alloc_page();
c0104c9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ca4:	e8 24 f3 ff ff       	call   c0103fcd <alloc_pages>
c0104ca9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104cac:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104cb1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104cb8:	00 
c0104cb9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104cc0:	00 
c0104cc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104cc4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104cc8:	89 04 24             	mov    %eax,(%esp)
c0104ccb:	e8 34 fc ff ff       	call   c0104904 <page_insert>
c0104cd0:	85 c0                	test   %eax,%eax
c0104cd2:	74 24                	je     c0104cf8 <check_pgdir+0x2b9>
c0104cd4:	c7 44 24 0c 84 6f 10 	movl   $0xc0106f84,0xc(%esp)
c0104cdb:	c0 
c0104cdc:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104ce3:	c0 
c0104ce4:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104ceb:	00 
c0104cec:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104cf3:	e8 07 c0 ff ff       	call   c0100cff <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104cf8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104cfd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d04:	00 
c0104d05:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d0c:	00 
c0104d0d:	89 04 24             	mov    %eax,(%esp)
c0104d10:	e8 4a f9 ff ff       	call   c010465f <get_pte>
c0104d15:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d1c:	75 24                	jne    c0104d42 <check_pgdir+0x303>
c0104d1e:	c7 44 24 0c bc 6f 10 	movl   $0xc0106fbc,0xc(%esp)
c0104d25:	c0 
c0104d26:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104d2d:	c0 
c0104d2e:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104d35:	00 
c0104d36:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104d3d:	e8 bd bf ff ff       	call   c0100cff <__panic>
    assert(*ptep & PTE_U);
c0104d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d45:	8b 00                	mov    (%eax),%eax
c0104d47:	83 e0 04             	and    $0x4,%eax
c0104d4a:	85 c0                	test   %eax,%eax
c0104d4c:	75 24                	jne    c0104d72 <check_pgdir+0x333>
c0104d4e:	c7 44 24 0c ec 6f 10 	movl   $0xc0106fec,0xc(%esp)
c0104d55:	c0 
c0104d56:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104d5d:	c0 
c0104d5e:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0104d65:	00 
c0104d66:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104d6d:	e8 8d bf ff ff       	call   c0100cff <__panic>
    assert(*ptep & PTE_W);
c0104d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d75:	8b 00                	mov    (%eax),%eax
c0104d77:	83 e0 02             	and    $0x2,%eax
c0104d7a:	85 c0                	test   %eax,%eax
c0104d7c:	75 24                	jne    c0104da2 <check_pgdir+0x363>
c0104d7e:	c7 44 24 0c fa 6f 10 	movl   $0xc0106ffa,0xc(%esp)
c0104d85:	c0 
c0104d86:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104d8d:	c0 
c0104d8e:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104d95:	00 
c0104d96:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104d9d:	e8 5d bf ff ff       	call   c0100cff <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104da2:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104da7:	8b 00                	mov    (%eax),%eax
c0104da9:	83 e0 04             	and    $0x4,%eax
c0104dac:	85 c0                	test   %eax,%eax
c0104dae:	75 24                	jne    c0104dd4 <check_pgdir+0x395>
c0104db0:	c7 44 24 0c 08 70 10 	movl   $0xc0107008,0xc(%esp)
c0104db7:	c0 
c0104db8:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104dbf:	c0 
c0104dc0:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104dc7:	00 
c0104dc8:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104dcf:	e8 2b bf ff ff       	call   c0100cff <__panic>
    assert(page_ref(p2) == 1);
c0104dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dd7:	89 04 24             	mov    %eax,(%esp)
c0104dda:	e8 de ef ff ff       	call   c0103dbd <page_ref>
c0104ddf:	83 f8 01             	cmp    $0x1,%eax
c0104de2:	74 24                	je     c0104e08 <check_pgdir+0x3c9>
c0104de4:	c7 44 24 0c 1e 70 10 	movl   $0xc010701e,0xc(%esp)
c0104deb:	c0 
c0104dec:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104df3:	c0 
c0104df4:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0104dfb:	00 
c0104dfc:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104e03:	e8 f7 be ff ff       	call   c0100cff <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104e08:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104e0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104e14:	00 
c0104e15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104e1c:	00 
c0104e1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e20:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e24:	89 04 24             	mov    %eax,(%esp)
c0104e27:	e8 d8 fa ff ff       	call   c0104904 <page_insert>
c0104e2c:	85 c0                	test   %eax,%eax
c0104e2e:	74 24                	je     c0104e54 <check_pgdir+0x415>
c0104e30:	c7 44 24 0c 30 70 10 	movl   $0xc0107030,0xc(%esp)
c0104e37:	c0 
c0104e38:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104e3f:	c0 
c0104e40:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0104e47:	00 
c0104e48:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104e4f:	e8 ab be ff ff       	call   c0100cff <__panic>
    assert(page_ref(p1) == 2);
c0104e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e57:	89 04 24             	mov    %eax,(%esp)
c0104e5a:	e8 5e ef ff ff       	call   c0103dbd <page_ref>
c0104e5f:	83 f8 02             	cmp    $0x2,%eax
c0104e62:	74 24                	je     c0104e88 <check_pgdir+0x449>
c0104e64:	c7 44 24 0c 5c 70 10 	movl   $0xc010705c,0xc(%esp)
c0104e6b:	c0 
c0104e6c:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104e73:	c0 
c0104e74:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0104e7b:	00 
c0104e7c:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104e83:	e8 77 be ff ff       	call   c0100cff <__panic>
    assert(page_ref(p2) == 0);
c0104e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e8b:	89 04 24             	mov    %eax,(%esp)
c0104e8e:	e8 2a ef ff ff       	call   c0103dbd <page_ref>
c0104e93:	85 c0                	test   %eax,%eax
c0104e95:	74 24                	je     c0104ebb <check_pgdir+0x47c>
c0104e97:	c7 44 24 0c 6e 70 10 	movl   $0xc010706e,0xc(%esp)
c0104e9e:	c0 
c0104e9f:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104ea6:	c0 
c0104ea7:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0104eae:	00 
c0104eaf:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104eb6:	e8 44 be ff ff       	call   c0100cff <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104ebb:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ec0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ec7:	00 
c0104ec8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ecf:	00 
c0104ed0:	89 04 24             	mov    %eax,(%esp)
c0104ed3:	e8 87 f7 ff ff       	call   c010465f <get_pte>
c0104ed8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104edb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104edf:	75 24                	jne    c0104f05 <check_pgdir+0x4c6>
c0104ee1:	c7 44 24 0c bc 6f 10 	movl   $0xc0106fbc,0xc(%esp)
c0104ee8:	c0 
c0104ee9:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0104ef8:	00 
c0104ef9:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104f00:	e8 fa bd ff ff       	call   c0100cff <__panic>
    assert(pte2page(*ptep) == p1);
c0104f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f08:	8b 00                	mov    (%eax),%eax
c0104f0a:	89 04 24             	mov    %eax,(%esp)
c0104f0d:	e8 51 ee ff ff       	call   c0103d63 <pte2page>
c0104f12:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104f15:	74 24                	je     c0104f3b <check_pgdir+0x4fc>
c0104f17:	c7 44 24 0c 31 6f 10 	movl   $0xc0106f31,0xc(%esp)
c0104f1e:	c0 
c0104f1f:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104f26:	c0 
c0104f27:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0104f2e:	00 
c0104f2f:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104f36:	e8 c4 bd ff ff       	call   c0100cff <__panic>
    assert((*ptep & PTE_U) == 0);
c0104f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f3e:	8b 00                	mov    (%eax),%eax
c0104f40:	83 e0 04             	and    $0x4,%eax
c0104f43:	85 c0                	test   %eax,%eax
c0104f45:	74 24                	je     c0104f6b <check_pgdir+0x52c>
c0104f47:	c7 44 24 0c 80 70 10 	movl   $0xc0107080,0xc(%esp)
c0104f4e:	c0 
c0104f4f:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104f56:	c0 
c0104f57:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0104f5e:	00 
c0104f5f:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104f66:	e8 94 bd ff ff       	call   c0100cff <__panic>

    page_remove(boot_pgdir, 0x0);
c0104f6b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104f70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104f77:	00 
c0104f78:	89 04 24             	mov    %eax,(%esp)
c0104f7b:	e8 3d f9 ff ff       	call   c01048bd <page_remove>
    assert(page_ref(p1) == 1);
c0104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f83:	89 04 24             	mov    %eax,(%esp)
c0104f86:	e8 32 ee ff ff       	call   c0103dbd <page_ref>
c0104f8b:	83 f8 01             	cmp    $0x1,%eax
c0104f8e:	74 24                	je     c0104fb4 <check_pgdir+0x575>
c0104f90:	c7 44 24 0c 47 6f 10 	movl   $0xc0106f47,0xc(%esp)
c0104f97:	c0 
c0104f98:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104f9f:	c0 
c0104fa0:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0104fa7:	00 
c0104fa8:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104faf:	e8 4b bd ff ff       	call   c0100cff <__panic>
    assert(page_ref(p2) == 0);
c0104fb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fb7:	89 04 24             	mov    %eax,(%esp)
c0104fba:	e8 fe ed ff ff       	call   c0103dbd <page_ref>
c0104fbf:	85 c0                	test   %eax,%eax
c0104fc1:	74 24                	je     c0104fe7 <check_pgdir+0x5a8>
c0104fc3:	c7 44 24 0c 6e 70 10 	movl   $0xc010706e,0xc(%esp)
c0104fca:	c0 
c0104fcb:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0104fd2:	c0 
c0104fd3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0104fda:	00 
c0104fdb:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0104fe2:	e8 18 bd ff ff       	call   c0100cff <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104fe7:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104fec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ff3:	00 
c0104ff4:	89 04 24             	mov    %eax,(%esp)
c0104ff7:	e8 c1 f8 ff ff       	call   c01048bd <page_remove>
    assert(page_ref(p1) == 0);
c0104ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fff:	89 04 24             	mov    %eax,(%esp)
c0105002:	e8 b6 ed ff ff       	call   c0103dbd <page_ref>
c0105007:	85 c0                	test   %eax,%eax
c0105009:	74 24                	je     c010502f <check_pgdir+0x5f0>
c010500b:	c7 44 24 0c 95 70 10 	movl   $0xc0107095,0xc(%esp)
c0105012:	c0 
c0105013:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010501a:	c0 
c010501b:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0105022:	00 
c0105023:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010502a:	e8 d0 bc ff ff       	call   c0100cff <__panic>
    assert(page_ref(p2) == 0);
c010502f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105032:	89 04 24             	mov    %eax,(%esp)
c0105035:	e8 83 ed ff ff       	call   c0103dbd <page_ref>
c010503a:	85 c0                	test   %eax,%eax
c010503c:	74 24                	je     c0105062 <check_pgdir+0x623>
c010503e:	c7 44 24 0c 6e 70 10 	movl   $0xc010706e,0xc(%esp)
c0105045:	c0 
c0105046:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010504d:	c0 
c010504e:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0105055:	00 
c0105056:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010505d:	e8 9d bc ff ff       	call   c0100cff <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105062:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105067:	8b 00                	mov    (%eax),%eax
c0105069:	89 04 24             	mov    %eax,(%esp)
c010506c:	e8 32 ed ff ff       	call   c0103da3 <pde2page>
c0105071:	89 04 24             	mov    %eax,(%esp)
c0105074:	e8 44 ed ff ff       	call   c0103dbd <page_ref>
c0105079:	83 f8 01             	cmp    $0x1,%eax
c010507c:	74 24                	je     c01050a2 <check_pgdir+0x663>
c010507e:	c7 44 24 0c a8 70 10 	movl   $0xc01070a8,0xc(%esp)
c0105085:	c0 
c0105086:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010508d:	c0 
c010508e:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0105095:	00 
c0105096:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010509d:	e8 5d bc ff ff       	call   c0100cff <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01050a2:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050a7:	8b 00                	mov    (%eax),%eax
c01050a9:	89 04 24             	mov    %eax,(%esp)
c01050ac:	e8 f2 ec ff ff       	call   c0103da3 <pde2page>
c01050b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050b8:	00 
c01050b9:	89 04 24             	mov    %eax,(%esp)
c01050bc:	e8 46 ef ff ff       	call   c0104007 <free_pages>
    boot_pgdir[0] = 0;
c01050c1:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01050cc:	c7 04 24 cf 70 10 c0 	movl   $0xc01070cf,(%esp)
c01050d3:	e8 7e b2 ff ff       	call   c0100356 <cprintf>
}
c01050d8:	90                   	nop
c01050d9:	89 ec                	mov    %ebp,%esp
c01050db:	5d                   	pop    %ebp
c01050dc:	c3                   	ret    

c01050dd <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01050dd:	55                   	push   %ebp
c01050de:	89 e5                	mov    %esp,%ebp
c01050e0:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01050e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01050ea:	e9 ca 00 00 00       	jmp    c01051b9 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01050ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01050f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050f8:	c1 e8 0c             	shr    $0xc,%eax
c01050fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01050fe:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c0105103:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105106:	72 23                	jb     c010512b <check_boot_pgdir+0x4e>
c0105108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010510b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010510f:	c7 44 24 08 04 6d 10 	movl   $0xc0106d04,0x8(%esp)
c0105116:	c0 
c0105117:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c010511e:	00 
c010511f:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0105126:	e8 d4 bb ff ff       	call   c0100cff <__panic>
c010512b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010512e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105133:	89 c2                	mov    %eax,%edx
c0105135:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010513a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105141:	00 
c0105142:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105146:	89 04 24             	mov    %eax,(%esp)
c0105149:	e8 11 f5 ff ff       	call   c010465f <get_pte>
c010514e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105151:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105155:	75 24                	jne    c010517b <check_boot_pgdir+0x9e>
c0105157:	c7 44 24 0c ec 70 10 	movl   $0xc01070ec,0xc(%esp)
c010515e:	c0 
c010515f:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0105166:	c0 
c0105167:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c010516e:	00 
c010516f:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0105176:	e8 84 bb ff ff       	call   c0100cff <__panic>
        assert(PTE_ADDR(*ptep) == i);
c010517b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010517e:	8b 00                	mov    (%eax),%eax
c0105180:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105185:	89 c2                	mov    %eax,%edx
c0105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010518a:	39 c2                	cmp    %eax,%edx
c010518c:	74 24                	je     c01051b2 <check_boot_pgdir+0xd5>
c010518e:	c7 44 24 0c 29 71 10 	movl   $0xc0107129,0xc(%esp)
c0105195:	c0 
c0105196:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010519d:	c0 
c010519e:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c01051a5:	00 
c01051a6:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01051ad:	e8 4d bb ff ff       	call   c0100cff <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01051b2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01051b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01051bc:	a1 a4 ce 11 c0       	mov    0xc011cea4,%eax
c01051c1:	39 c2                	cmp    %eax,%edx
c01051c3:	0f 82 26 ff ff ff    	jb     c01050ef <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01051c9:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01051ce:	05 ac 0f 00 00       	add    $0xfac,%eax
c01051d3:	8b 00                	mov    (%eax),%eax
c01051d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01051da:	89 c2                	mov    %eax,%edx
c01051dc:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01051e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01051e4:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01051eb:	77 23                	ja     c0105210 <check_boot_pgdir+0x133>
c01051ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01051f4:	c7 44 24 08 a8 6d 10 	movl   $0xc0106da8,0x8(%esp)
c01051fb:	c0 
c01051fc:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0105203:	00 
c0105204:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010520b:	e8 ef ba ff ff       	call   c0100cff <__panic>
c0105210:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105213:	05 00 00 00 40       	add    $0x40000000,%eax
c0105218:	39 d0                	cmp    %edx,%eax
c010521a:	74 24                	je     c0105240 <check_boot_pgdir+0x163>
c010521c:	c7 44 24 0c 40 71 10 	movl   $0xc0107140,0xc(%esp)
c0105223:	c0 
c0105224:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010522b:	c0 
c010522c:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0105233:	00 
c0105234:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010523b:	e8 bf ba ff ff       	call   c0100cff <__panic>

    assert(boot_pgdir[0] == 0);
c0105240:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105245:	8b 00                	mov    (%eax),%eax
c0105247:	85 c0                	test   %eax,%eax
c0105249:	74 24                	je     c010526f <check_boot_pgdir+0x192>
c010524b:	c7 44 24 0c 74 71 10 	movl   $0xc0107174,0xc(%esp)
c0105252:	c0 
c0105253:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c010525a:	c0 
c010525b:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0105262:	00 
c0105263:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c010526a:	e8 90 ba ff ff       	call   c0100cff <__panic>

    struct Page *p;
    p = alloc_page();
c010526f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105276:	e8 52 ed ff ff       	call   c0103fcd <alloc_pages>
c010527b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010527e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105283:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010528a:	00 
c010528b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105292:	00 
c0105293:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105296:	89 54 24 04          	mov    %edx,0x4(%esp)
c010529a:	89 04 24             	mov    %eax,(%esp)
c010529d:	e8 62 f6 ff ff       	call   c0104904 <page_insert>
c01052a2:	85 c0                	test   %eax,%eax
c01052a4:	74 24                	je     c01052ca <check_boot_pgdir+0x1ed>
c01052a6:	c7 44 24 0c 88 71 10 	movl   $0xc0107188,0xc(%esp)
c01052ad:	c0 
c01052ae:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c01052b5:	c0 
c01052b6:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c01052bd:	00 
c01052be:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01052c5:	e8 35 ba ff ff       	call   c0100cff <__panic>
    assert(page_ref(p) == 1);
c01052ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052cd:	89 04 24             	mov    %eax,(%esp)
c01052d0:	e8 e8 ea ff ff       	call   c0103dbd <page_ref>
c01052d5:	83 f8 01             	cmp    $0x1,%eax
c01052d8:	74 24                	je     c01052fe <check_boot_pgdir+0x221>
c01052da:	c7 44 24 0c b6 71 10 	movl   $0xc01071b6,0xc(%esp)
c01052e1:	c0 
c01052e2:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c01052e9:	c0 
c01052ea:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c01052f1:	00 
c01052f2:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01052f9:	e8 01 ba ff ff       	call   c0100cff <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01052fe:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105303:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010530a:	00 
c010530b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105312:	00 
c0105313:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105316:	89 54 24 04          	mov    %edx,0x4(%esp)
c010531a:	89 04 24             	mov    %eax,(%esp)
c010531d:	e8 e2 f5 ff ff       	call   c0104904 <page_insert>
c0105322:	85 c0                	test   %eax,%eax
c0105324:	74 24                	je     c010534a <check_boot_pgdir+0x26d>
c0105326:	c7 44 24 0c c8 71 10 	movl   $0xc01071c8,0xc(%esp)
c010532d:	c0 
c010532e:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0105335:	c0 
c0105336:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c010533d:	00 
c010533e:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0105345:	e8 b5 b9 ff ff       	call   c0100cff <__panic>
    assert(page_ref(p) == 2);
c010534a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010534d:	89 04 24             	mov    %eax,(%esp)
c0105350:	e8 68 ea ff ff       	call   c0103dbd <page_ref>
c0105355:	83 f8 02             	cmp    $0x2,%eax
c0105358:	74 24                	je     c010537e <check_boot_pgdir+0x2a1>
c010535a:	c7 44 24 0c ff 71 10 	movl   $0xc01071ff,0xc(%esp)
c0105361:	c0 
c0105362:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0105369:	c0 
c010536a:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c0105371:	00 
c0105372:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0105379:	e8 81 b9 ff ff       	call   c0100cff <__panic>

    const char *str = "ucore: Hello world!!";
c010537e:	c7 45 e8 10 72 10 c0 	movl   $0xc0107210,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105385:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105388:	89 44 24 04          	mov    %eax,0x4(%esp)
c010538c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105393:	e8 fc 09 00 00       	call   c0105d94 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105398:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010539f:	00 
c01053a0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01053a7:	e8 60 0a 00 00       	call   c0105e0c <strcmp>
c01053ac:	85 c0                	test   %eax,%eax
c01053ae:	74 24                	je     c01053d4 <check_boot_pgdir+0x2f7>
c01053b0:	c7 44 24 0c 28 72 10 	movl   $0xc0107228,0xc(%esp)
c01053b7:	c0 
c01053b8:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c01053bf:	c0 
c01053c0:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c01053c7:	00 
c01053c8:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c01053cf:	e8 2b b9 ff ff       	call   c0100cff <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01053d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053d7:	89 04 24             	mov    %eax,(%esp)
c01053da:	e8 2e e9 ff ff       	call   c0103d0d <page2kva>
c01053df:	05 00 01 00 00       	add    $0x100,%eax
c01053e4:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01053e7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01053ee:	e8 47 09 00 00       	call   c0105d3a <strlen>
c01053f3:	85 c0                	test   %eax,%eax
c01053f5:	74 24                	je     c010541b <check_boot_pgdir+0x33e>
c01053f7:	c7 44 24 0c 60 72 10 	movl   $0xc0107260,0xc(%esp)
c01053fe:	c0 
c01053ff:	c7 44 24 08 f1 6d 10 	movl   $0xc0106df1,0x8(%esp)
c0105406:	c0 
c0105407:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c010540e:	00 
c010540f:	c7 04 24 cc 6d 10 c0 	movl   $0xc0106dcc,(%esp)
c0105416:	e8 e4 b8 ff ff       	call   c0100cff <__panic>

    free_page(p);
c010541b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105422:	00 
c0105423:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105426:	89 04 24             	mov    %eax,(%esp)
c0105429:	e8 d9 eb ff ff       	call   c0104007 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010542e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105433:	8b 00                	mov    (%eax),%eax
c0105435:	89 04 24             	mov    %eax,(%esp)
c0105438:	e8 66 e9 ff ff       	call   c0103da3 <pde2page>
c010543d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105444:	00 
c0105445:	89 04 24             	mov    %eax,(%esp)
c0105448:	e8 ba eb ff ff       	call   c0104007 <free_pages>
    boot_pgdir[0] = 0;
c010544d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105452:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105458:	c7 04 24 84 72 10 c0 	movl   $0xc0107284,(%esp)
c010545f:	e8 f2 ae ff ff       	call   c0100356 <cprintf>
}
c0105464:	90                   	nop
c0105465:	89 ec                	mov    %ebp,%esp
c0105467:	5d                   	pop    %ebp
c0105468:	c3                   	ret    

c0105469 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105469:	55                   	push   %ebp
c010546a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010546c:	8b 45 08             	mov    0x8(%ebp),%eax
c010546f:	83 e0 04             	and    $0x4,%eax
c0105472:	85 c0                	test   %eax,%eax
c0105474:	74 04                	je     c010547a <perm2str+0x11>
c0105476:	b0 75                	mov    $0x75,%al
c0105478:	eb 02                	jmp    c010547c <perm2str+0x13>
c010547a:	b0 2d                	mov    $0x2d,%al
c010547c:	a2 28 cf 11 c0       	mov    %al,0xc011cf28
    str[1] = 'r';
c0105481:	c6 05 29 cf 11 c0 72 	movb   $0x72,0xc011cf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105488:	8b 45 08             	mov    0x8(%ebp),%eax
c010548b:	83 e0 02             	and    $0x2,%eax
c010548e:	85 c0                	test   %eax,%eax
c0105490:	74 04                	je     c0105496 <perm2str+0x2d>
c0105492:	b0 77                	mov    $0x77,%al
c0105494:	eb 02                	jmp    c0105498 <perm2str+0x2f>
c0105496:	b0 2d                	mov    $0x2d,%al
c0105498:	a2 2a cf 11 c0       	mov    %al,0xc011cf2a
    str[3] = '\0';
c010549d:	c6 05 2b cf 11 c0 00 	movb   $0x0,0xc011cf2b
    return str;
c01054a4:	b8 28 cf 11 c0       	mov    $0xc011cf28,%eax
}
c01054a9:	5d                   	pop    %ebp
c01054aa:	c3                   	ret    

c01054ab <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01054ab:	55                   	push   %ebp
c01054ac:	89 e5                	mov    %esp,%ebp
c01054ae:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01054b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01054b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01054b7:	72 0d                	jb     c01054c6 <get_pgtable_items+0x1b>
        return 0;
c01054b9:	b8 00 00 00 00       	mov    $0x0,%eax
c01054be:	e9 98 00 00 00       	jmp    c010555b <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01054c3:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01054c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01054c9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01054cc:	73 18                	jae    c01054e6 <get_pgtable_items+0x3b>
c01054ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01054d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01054d8:	8b 45 14             	mov    0x14(%ebp),%eax
c01054db:	01 d0                	add    %edx,%eax
c01054dd:	8b 00                	mov    (%eax),%eax
c01054df:	83 e0 01             	and    $0x1,%eax
c01054e2:	85 c0                	test   %eax,%eax
c01054e4:	74 dd                	je     c01054c3 <get_pgtable_items+0x18>
    }
    if (start < right) {
c01054e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01054e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01054ec:	73 68                	jae    c0105556 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01054ee:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01054f2:	74 08                	je     c01054fc <get_pgtable_items+0x51>
            *left_store = start;
c01054f4:	8b 45 18             	mov    0x18(%ebp),%eax
c01054f7:	8b 55 10             	mov    0x10(%ebp),%edx
c01054fa:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01054fc:	8b 45 10             	mov    0x10(%ebp),%eax
c01054ff:	8d 50 01             	lea    0x1(%eax),%edx
c0105502:	89 55 10             	mov    %edx,0x10(%ebp)
c0105505:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010550c:	8b 45 14             	mov    0x14(%ebp),%eax
c010550f:	01 d0                	add    %edx,%eax
c0105511:	8b 00                	mov    (%eax),%eax
c0105513:	83 e0 07             	and    $0x7,%eax
c0105516:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105519:	eb 03                	jmp    c010551e <get_pgtable_items+0x73>
            start ++;
c010551b:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010551e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105521:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105524:	73 1d                	jae    c0105543 <get_pgtable_items+0x98>
c0105526:	8b 45 10             	mov    0x10(%ebp),%eax
c0105529:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105530:	8b 45 14             	mov    0x14(%ebp),%eax
c0105533:	01 d0                	add    %edx,%eax
c0105535:	8b 00                	mov    (%eax),%eax
c0105537:	83 e0 07             	and    $0x7,%eax
c010553a:	89 c2                	mov    %eax,%edx
c010553c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010553f:	39 c2                	cmp    %eax,%edx
c0105541:	74 d8                	je     c010551b <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0105543:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105547:	74 08                	je     c0105551 <get_pgtable_items+0xa6>
            *right_store = start;
c0105549:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010554c:	8b 55 10             	mov    0x10(%ebp),%edx
c010554f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105551:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105554:	eb 05                	jmp    c010555b <get_pgtable_items+0xb0>
    }
    return 0;
c0105556:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010555b:	89 ec                	mov    %ebp,%esp
c010555d:	5d                   	pop    %ebp
c010555e:	c3                   	ret    

c010555f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010555f:	55                   	push   %ebp
c0105560:	89 e5                	mov    %esp,%ebp
c0105562:	57                   	push   %edi
c0105563:	56                   	push   %esi
c0105564:	53                   	push   %ebx
c0105565:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105568:	c7 04 24 a4 72 10 c0 	movl   $0xc01072a4,(%esp)
c010556f:	e8 e2 ad ff ff       	call   c0100356 <cprintf>
    size_t left, right = 0, perm;
c0105574:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010557b:	e9 f2 00 00 00       	jmp    c0105672 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105583:	89 04 24             	mov    %eax,(%esp)
c0105586:	e8 de fe ff ff       	call   c0105469 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010558b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010558e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105591:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105593:	89 d6                	mov    %edx,%esi
c0105595:	c1 e6 16             	shl    $0x16,%esi
c0105598:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010559b:	89 d3                	mov    %edx,%ebx
c010559d:	c1 e3 16             	shl    $0x16,%ebx
c01055a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01055a3:	89 d1                	mov    %edx,%ecx
c01055a5:	c1 e1 16             	shl    $0x16,%ecx
c01055a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
c01055ae:	29 fa                	sub    %edi,%edx
c01055b0:	89 44 24 14          	mov    %eax,0x14(%esp)
c01055b4:	89 74 24 10          	mov    %esi,0x10(%esp)
c01055b8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01055bc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01055c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055c4:	c7 04 24 d5 72 10 c0 	movl   $0xc01072d5,(%esp)
c01055cb:	e8 86 ad ff ff       	call   c0100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01055d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055d3:	c1 e0 0a             	shl    $0xa,%eax
c01055d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01055d9:	eb 50                	jmp    c010562b <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01055db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055de:	89 04 24             	mov    %eax,(%esp)
c01055e1:	e8 83 fe ff ff       	call   c0105469 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01055e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01055e9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01055ec:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01055ee:	89 d6                	mov    %edx,%esi
c01055f0:	c1 e6 0c             	shl    $0xc,%esi
c01055f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01055f6:	89 d3                	mov    %edx,%ebx
c01055f8:	c1 e3 0c             	shl    $0xc,%ebx
c01055fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01055fe:	89 d1                	mov    %edx,%ecx
c0105600:	c1 e1 0c             	shl    $0xc,%ecx
c0105603:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105606:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0105609:	29 fa                	sub    %edi,%edx
c010560b:	89 44 24 14          	mov    %eax,0x14(%esp)
c010560f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105613:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105617:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010561b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010561f:	c7 04 24 f4 72 10 c0 	movl   $0xc01072f4,(%esp)
c0105626:	e8 2b ad ff ff       	call   c0100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010562b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0105630:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105633:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105636:	89 d3                	mov    %edx,%ebx
c0105638:	c1 e3 0a             	shl    $0xa,%ebx
c010563b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010563e:	89 d1                	mov    %edx,%ecx
c0105640:	c1 e1 0a             	shl    $0xa,%ecx
c0105643:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0105646:	89 54 24 14          	mov    %edx,0x14(%esp)
c010564a:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010564d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105651:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105655:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105659:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010565d:	89 0c 24             	mov    %ecx,(%esp)
c0105660:	e8 46 fe ff ff       	call   c01054ab <get_pgtable_items>
c0105665:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105668:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010566c:	0f 85 69 ff ff ff    	jne    c01055db <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105672:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0105677:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010567a:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010567d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105681:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0105684:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105688:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010568c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105690:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105697:	00 
c0105698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010569f:	e8 07 fe ff ff       	call   c01054ab <get_pgtable_items>
c01056a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01056ab:	0f 85 cf fe ff ff    	jne    c0105580 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01056b1:	c7 04 24 18 73 10 c0 	movl   $0xc0107318,(%esp)
c01056b8:	e8 99 ac ff ff       	call   c0100356 <cprintf>
}
c01056bd:	90                   	nop
c01056be:	83 c4 4c             	add    $0x4c,%esp
c01056c1:	5b                   	pop    %ebx
c01056c2:	5e                   	pop    %esi
c01056c3:	5f                   	pop    %edi
c01056c4:	5d                   	pop    %ebp
c01056c5:	c3                   	ret    

c01056c6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01056c6:	55                   	push   %ebp
c01056c7:	89 e5                	mov    %esp,%ebp
c01056c9:	83 ec 58             	sub    $0x58,%esp
c01056cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01056cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01056d2:	8b 45 14             	mov    0x14(%ebp),%eax
c01056d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01056d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01056de:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01056e4:	8b 45 18             	mov    0x18(%ebp),%eax
c01056e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01056f3:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01056f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105700:	74 1c                	je     c010571e <printnum+0x58>
c0105702:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105705:	ba 00 00 00 00       	mov    $0x0,%edx
c010570a:	f7 75 e4             	divl   -0x1c(%ebp)
c010570d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105713:	ba 00 00 00 00       	mov    $0x0,%edx
c0105718:	f7 75 e4             	divl   -0x1c(%ebp)
c010571b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010571e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105721:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105724:	f7 75 e4             	divl   -0x1c(%ebp)
c0105727:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010572a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010572d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105730:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105733:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105736:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105739:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010573c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010573f:	8b 45 18             	mov    0x18(%ebp),%eax
c0105742:	ba 00 00 00 00       	mov    $0x0,%edx
c0105747:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010574a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010574d:	19 d1                	sbb    %edx,%ecx
c010574f:	72 4c                	jb     c010579d <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105751:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105754:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105757:	8b 45 20             	mov    0x20(%ebp),%eax
c010575a:	89 44 24 18          	mov    %eax,0x18(%esp)
c010575e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105762:	8b 45 18             	mov    0x18(%ebp),%eax
c0105765:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105769:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010576c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010576f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105773:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105777:	8b 45 0c             	mov    0xc(%ebp),%eax
c010577a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010577e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105781:	89 04 24             	mov    %eax,(%esp)
c0105784:	e8 3d ff ff ff       	call   c01056c6 <printnum>
c0105789:	eb 1b                	jmp    c01057a6 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010578b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010578e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105792:	8b 45 20             	mov    0x20(%ebp),%eax
c0105795:	89 04 24             	mov    %eax,(%esp)
c0105798:	8b 45 08             	mov    0x8(%ebp),%eax
c010579b:	ff d0                	call   *%eax
        while (-- width > 0)
c010579d:	ff 4d 1c             	decl   0x1c(%ebp)
c01057a0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01057a4:	7f e5                	jg     c010578b <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01057a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01057a9:	05 cc 73 10 c0       	add    $0xc01073cc,%eax
c01057ae:	0f b6 00             	movzbl (%eax),%eax
c01057b1:	0f be c0             	movsbl %al,%eax
c01057b4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057b7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057bb:	89 04 24             	mov    %eax,(%esp)
c01057be:	8b 45 08             	mov    0x8(%ebp),%eax
c01057c1:	ff d0                	call   *%eax
}
c01057c3:	90                   	nop
c01057c4:	89 ec                	mov    %ebp,%esp
c01057c6:	5d                   	pop    %ebp
c01057c7:	c3                   	ret    

c01057c8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01057c8:	55                   	push   %ebp
c01057c9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01057cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01057cf:	7e 14                	jle    c01057e5 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01057d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d4:	8b 00                	mov    (%eax),%eax
c01057d6:	8d 48 08             	lea    0x8(%eax),%ecx
c01057d9:	8b 55 08             	mov    0x8(%ebp),%edx
c01057dc:	89 0a                	mov    %ecx,(%edx)
c01057de:	8b 50 04             	mov    0x4(%eax),%edx
c01057e1:	8b 00                	mov    (%eax),%eax
c01057e3:	eb 30                	jmp    c0105815 <getuint+0x4d>
    }
    else if (lflag) {
c01057e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01057e9:	74 16                	je     c0105801 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01057eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ee:	8b 00                	mov    (%eax),%eax
c01057f0:	8d 48 04             	lea    0x4(%eax),%ecx
c01057f3:	8b 55 08             	mov    0x8(%ebp),%edx
c01057f6:	89 0a                	mov    %ecx,(%edx)
c01057f8:	8b 00                	mov    (%eax),%eax
c01057fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01057ff:	eb 14                	jmp    c0105815 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105801:	8b 45 08             	mov    0x8(%ebp),%eax
c0105804:	8b 00                	mov    (%eax),%eax
c0105806:	8d 48 04             	lea    0x4(%eax),%ecx
c0105809:	8b 55 08             	mov    0x8(%ebp),%edx
c010580c:	89 0a                	mov    %ecx,(%edx)
c010580e:	8b 00                	mov    (%eax),%eax
c0105810:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105815:	5d                   	pop    %ebp
c0105816:	c3                   	ret    

c0105817 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105817:	55                   	push   %ebp
c0105818:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010581a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010581e:	7e 14                	jle    c0105834 <getint+0x1d>
        return va_arg(*ap, long long);
c0105820:	8b 45 08             	mov    0x8(%ebp),%eax
c0105823:	8b 00                	mov    (%eax),%eax
c0105825:	8d 48 08             	lea    0x8(%eax),%ecx
c0105828:	8b 55 08             	mov    0x8(%ebp),%edx
c010582b:	89 0a                	mov    %ecx,(%edx)
c010582d:	8b 50 04             	mov    0x4(%eax),%edx
c0105830:	8b 00                	mov    (%eax),%eax
c0105832:	eb 28                	jmp    c010585c <getint+0x45>
    }
    else if (lflag) {
c0105834:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105838:	74 12                	je     c010584c <getint+0x35>
        return va_arg(*ap, long);
c010583a:	8b 45 08             	mov    0x8(%ebp),%eax
c010583d:	8b 00                	mov    (%eax),%eax
c010583f:	8d 48 04             	lea    0x4(%eax),%ecx
c0105842:	8b 55 08             	mov    0x8(%ebp),%edx
c0105845:	89 0a                	mov    %ecx,(%edx)
c0105847:	8b 00                	mov    (%eax),%eax
c0105849:	99                   	cltd   
c010584a:	eb 10                	jmp    c010585c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010584c:	8b 45 08             	mov    0x8(%ebp),%eax
c010584f:	8b 00                	mov    (%eax),%eax
c0105851:	8d 48 04             	lea    0x4(%eax),%ecx
c0105854:	8b 55 08             	mov    0x8(%ebp),%edx
c0105857:	89 0a                	mov    %ecx,(%edx)
c0105859:	8b 00                	mov    (%eax),%eax
c010585b:	99                   	cltd   
    }
}
c010585c:	5d                   	pop    %ebp
c010585d:	c3                   	ret    

c010585e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010585e:	55                   	push   %ebp
c010585f:	89 e5                	mov    %esp,%ebp
c0105861:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105864:	8d 45 14             	lea    0x14(%ebp),%eax
c0105867:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010586a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010586d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105871:	8b 45 10             	mov    0x10(%ebp),%eax
c0105874:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105878:	8b 45 0c             	mov    0xc(%ebp),%eax
c010587b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010587f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105882:	89 04 24             	mov    %eax,(%esp)
c0105885:	e8 05 00 00 00       	call   c010588f <vprintfmt>
    va_end(ap);
}
c010588a:	90                   	nop
c010588b:	89 ec                	mov    %ebp,%esp
c010588d:	5d                   	pop    %ebp
c010588e:	c3                   	ret    

c010588f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010588f:	55                   	push   %ebp
c0105890:	89 e5                	mov    %esp,%ebp
c0105892:	56                   	push   %esi
c0105893:	53                   	push   %ebx
c0105894:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105897:	eb 17                	jmp    c01058b0 <vprintfmt+0x21>
            if (ch == '\0') {
c0105899:	85 db                	test   %ebx,%ebx
c010589b:	0f 84 bf 03 00 00    	je     c0105c60 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01058a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058a8:	89 1c 24             	mov    %ebx,(%esp)
c01058ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ae:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01058b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01058b3:	8d 50 01             	lea    0x1(%eax),%edx
c01058b6:	89 55 10             	mov    %edx,0x10(%ebp)
c01058b9:	0f b6 00             	movzbl (%eax),%eax
c01058bc:	0f b6 d8             	movzbl %al,%ebx
c01058bf:	83 fb 25             	cmp    $0x25,%ebx
c01058c2:	75 d5                	jne    c0105899 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01058c4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01058c8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01058cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01058d5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01058dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058df:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01058e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01058e5:	8d 50 01             	lea    0x1(%eax),%edx
c01058e8:	89 55 10             	mov    %edx,0x10(%ebp)
c01058eb:	0f b6 00             	movzbl (%eax),%eax
c01058ee:	0f b6 d8             	movzbl %al,%ebx
c01058f1:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01058f4:	83 f8 55             	cmp    $0x55,%eax
c01058f7:	0f 87 37 03 00 00    	ja     c0105c34 <vprintfmt+0x3a5>
c01058fd:	8b 04 85 f0 73 10 c0 	mov    -0x3fef8c10(,%eax,4),%eax
c0105904:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105906:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010590a:	eb d6                	jmp    c01058e2 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010590c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105910:	eb d0                	jmp    c01058e2 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105912:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105919:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010591c:	89 d0                	mov    %edx,%eax
c010591e:	c1 e0 02             	shl    $0x2,%eax
c0105921:	01 d0                	add    %edx,%eax
c0105923:	01 c0                	add    %eax,%eax
c0105925:	01 d8                	add    %ebx,%eax
c0105927:	83 e8 30             	sub    $0x30,%eax
c010592a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010592d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105930:	0f b6 00             	movzbl (%eax),%eax
c0105933:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105936:	83 fb 2f             	cmp    $0x2f,%ebx
c0105939:	7e 38                	jle    c0105973 <vprintfmt+0xe4>
c010593b:	83 fb 39             	cmp    $0x39,%ebx
c010593e:	7f 33                	jg     c0105973 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105940:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105943:	eb d4                	jmp    c0105919 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105945:	8b 45 14             	mov    0x14(%ebp),%eax
c0105948:	8d 50 04             	lea    0x4(%eax),%edx
c010594b:	89 55 14             	mov    %edx,0x14(%ebp)
c010594e:	8b 00                	mov    (%eax),%eax
c0105950:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105953:	eb 1f                	jmp    c0105974 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105955:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105959:	79 87                	jns    c01058e2 <vprintfmt+0x53>
                width = 0;
c010595b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105962:	e9 7b ff ff ff       	jmp    c01058e2 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105967:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010596e:	e9 6f ff ff ff       	jmp    c01058e2 <vprintfmt+0x53>
            goto process_precision;
c0105973:	90                   	nop

        process_precision:
            if (width < 0)
c0105974:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105978:	0f 89 64 ff ff ff    	jns    c01058e2 <vprintfmt+0x53>
                width = precision, precision = -1;
c010597e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105981:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105984:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010598b:	e9 52 ff ff ff       	jmp    c01058e2 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105990:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105993:	e9 4a ff ff ff       	jmp    c01058e2 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105998:	8b 45 14             	mov    0x14(%ebp),%eax
c010599b:	8d 50 04             	lea    0x4(%eax),%edx
c010599e:	89 55 14             	mov    %edx,0x14(%ebp)
c01059a1:	8b 00                	mov    (%eax),%eax
c01059a3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01059a6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01059aa:	89 04 24             	mov    %eax,(%esp)
c01059ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b0:	ff d0                	call   *%eax
            break;
c01059b2:	e9 a4 02 00 00       	jmp    c0105c5b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01059b7:	8b 45 14             	mov    0x14(%ebp),%eax
c01059ba:	8d 50 04             	lea    0x4(%eax),%edx
c01059bd:	89 55 14             	mov    %edx,0x14(%ebp)
c01059c0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01059c2:	85 db                	test   %ebx,%ebx
c01059c4:	79 02                	jns    c01059c8 <vprintfmt+0x139>
                err = -err;
c01059c6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01059c8:	83 fb 06             	cmp    $0x6,%ebx
c01059cb:	7f 0b                	jg     c01059d8 <vprintfmt+0x149>
c01059cd:	8b 34 9d b0 73 10 c0 	mov    -0x3fef8c50(,%ebx,4),%esi
c01059d4:	85 f6                	test   %esi,%esi
c01059d6:	75 23                	jne    c01059fb <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01059d8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01059dc:	c7 44 24 08 dd 73 10 	movl   $0xc01073dd,0x8(%esp)
c01059e3:	c0 
c01059e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ee:	89 04 24             	mov    %eax,(%esp)
c01059f1:	e8 68 fe ff ff       	call   c010585e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01059f6:	e9 60 02 00 00       	jmp    c0105c5b <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01059fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01059ff:	c7 44 24 08 e6 73 10 	movl   $0xc01073e6,0x8(%esp)
c0105a06:	c0 
c0105a07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a11:	89 04 24             	mov    %eax,(%esp)
c0105a14:	e8 45 fe ff ff       	call   c010585e <printfmt>
            break;
c0105a19:	e9 3d 02 00 00       	jmp    c0105c5b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105a1e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a21:	8d 50 04             	lea    0x4(%eax),%edx
c0105a24:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a27:	8b 30                	mov    (%eax),%esi
c0105a29:	85 f6                	test   %esi,%esi
c0105a2b:	75 05                	jne    c0105a32 <vprintfmt+0x1a3>
                p = "(null)";
c0105a2d:	be e9 73 10 c0       	mov    $0xc01073e9,%esi
            }
            if (width > 0 && padc != '-') {
c0105a32:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a36:	7e 76                	jle    c0105aae <vprintfmt+0x21f>
c0105a38:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105a3c:	74 70                	je     c0105aae <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105a3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a45:	89 34 24             	mov    %esi,(%esp)
c0105a48:	e8 16 03 00 00       	call   c0105d63 <strnlen>
c0105a4d:	89 c2                	mov    %eax,%edx
c0105a4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a52:	29 d0                	sub    %edx,%eax
c0105a54:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a57:	eb 16                	jmp    c0105a6f <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105a59:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a60:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a64:	89 04 24             	mov    %eax,(%esp)
c0105a67:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a6a:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105a6c:	ff 4d e8             	decl   -0x18(%ebp)
c0105a6f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a73:	7f e4                	jg     c0105a59 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105a75:	eb 37                	jmp    c0105aae <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105a77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105a7b:	74 1f                	je     c0105a9c <vprintfmt+0x20d>
c0105a7d:	83 fb 1f             	cmp    $0x1f,%ebx
c0105a80:	7e 05                	jle    c0105a87 <vprintfmt+0x1f8>
c0105a82:	83 fb 7e             	cmp    $0x7e,%ebx
c0105a85:	7e 15                	jle    c0105a9c <vprintfmt+0x20d>
                    putch('?', putdat);
c0105a87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a8e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105a95:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a98:	ff d0                	call   *%eax
c0105a9a:	eb 0f                	jmp    c0105aab <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aa3:	89 1c 24             	mov    %ebx,(%esp)
c0105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105aab:	ff 4d e8             	decl   -0x18(%ebp)
c0105aae:	89 f0                	mov    %esi,%eax
c0105ab0:	8d 70 01             	lea    0x1(%eax),%esi
c0105ab3:	0f b6 00             	movzbl (%eax),%eax
c0105ab6:	0f be d8             	movsbl %al,%ebx
c0105ab9:	85 db                	test   %ebx,%ebx
c0105abb:	74 27                	je     c0105ae4 <vprintfmt+0x255>
c0105abd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ac1:	78 b4                	js     c0105a77 <vprintfmt+0x1e8>
c0105ac3:	ff 4d e4             	decl   -0x1c(%ebp)
c0105ac6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105aca:	79 ab                	jns    c0105a77 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105acc:	eb 16                	jmp    c0105ae4 <vprintfmt+0x255>
                putch(' ', putdat);
c0105ace:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ad5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105adc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105adf:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105ae1:	ff 4d e8             	decl   -0x18(%ebp)
c0105ae4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ae8:	7f e4                	jg     c0105ace <vprintfmt+0x23f>
            }
            break;
c0105aea:	e9 6c 01 00 00       	jmp    c0105c5b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105aef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105af2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105af6:	8d 45 14             	lea    0x14(%ebp),%eax
c0105af9:	89 04 24             	mov    %eax,(%esp)
c0105afc:	e8 16 fd ff ff       	call   c0105817 <getint>
c0105b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b04:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b0d:	85 d2                	test   %edx,%edx
c0105b0f:	79 26                	jns    c0105b37 <vprintfmt+0x2a8>
                putch('-', putdat);
c0105b11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b18:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105b1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b22:	ff d0                	call   *%eax
                num = -(long long)num;
c0105b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b27:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b2a:	f7 d8                	neg    %eax
c0105b2c:	83 d2 00             	adc    $0x0,%edx
c0105b2f:	f7 da                	neg    %edx
c0105b31:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b34:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105b37:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105b3e:	e9 a8 00 00 00       	jmp    c0105beb <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105b43:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b4a:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b4d:	89 04 24             	mov    %eax,(%esp)
c0105b50:	e8 73 fc ff ff       	call   c01057c8 <getuint>
c0105b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b58:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105b5b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105b62:	e9 84 00 00 00       	jmp    c0105beb <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b6e:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b71:	89 04 24             	mov    %eax,(%esp)
c0105b74:	e8 4f fc ff ff       	call   c01057c8 <getuint>
c0105b79:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105b7f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105b86:	eb 63                	jmp    c0105beb <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105b88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b8f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105b96:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b99:	ff d0                	call   *%eax
            putch('x', putdat);
c0105b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ba2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bac:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105bae:	8b 45 14             	mov    0x14(%ebp),%eax
c0105bb1:	8d 50 04             	lea    0x4(%eax),%edx
c0105bb4:	89 55 14             	mov    %edx,0x14(%ebp)
c0105bb7:	8b 00                	mov    (%eax),%eax
c0105bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105bc3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105bca:	eb 1f                	jmp    c0105beb <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105bcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bd3:	8d 45 14             	lea    0x14(%ebp),%eax
c0105bd6:	89 04 24             	mov    %eax,(%esp)
c0105bd9:	e8 ea fb ff ff       	call   c01057c8 <getuint>
c0105bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105be1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105be4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105beb:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bf2:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105bf6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105bf9:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105bfd:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c07:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c19:	89 04 24             	mov    %eax,(%esp)
c0105c1c:	e8 a5 fa ff ff       	call   c01056c6 <printnum>
            break;
c0105c21:	eb 38                	jmp    c0105c5b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105c23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c2a:	89 1c 24             	mov    %ebx,(%esp)
c0105c2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c30:	ff d0                	call   *%eax
            break;
c0105c32:	eb 27                	jmp    c0105c5b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105c34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c3b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105c42:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c45:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105c47:	ff 4d 10             	decl   0x10(%ebp)
c0105c4a:	eb 03                	jmp    c0105c4f <vprintfmt+0x3c0>
c0105c4c:	ff 4d 10             	decl   0x10(%ebp)
c0105c4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c52:	48                   	dec    %eax
c0105c53:	0f b6 00             	movzbl (%eax),%eax
c0105c56:	3c 25                	cmp    $0x25,%al
c0105c58:	75 f2                	jne    c0105c4c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105c5a:	90                   	nop
    while (1) {
c0105c5b:	e9 37 fc ff ff       	jmp    c0105897 <vprintfmt+0x8>
                return;
c0105c60:	90                   	nop
        }
    }
}
c0105c61:	83 c4 40             	add    $0x40,%esp
c0105c64:	5b                   	pop    %ebx
c0105c65:	5e                   	pop    %esi
c0105c66:	5d                   	pop    %ebp
c0105c67:	c3                   	ret    

c0105c68 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105c68:	55                   	push   %ebp
c0105c69:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c6e:	8b 40 08             	mov    0x8(%eax),%eax
c0105c71:	8d 50 01             	lea    0x1(%eax),%edx
c0105c74:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c77:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7d:	8b 10                	mov    (%eax),%edx
c0105c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c82:	8b 40 04             	mov    0x4(%eax),%eax
c0105c85:	39 c2                	cmp    %eax,%edx
c0105c87:	73 12                	jae    c0105c9b <sprintputch+0x33>
        *b->buf ++ = ch;
c0105c89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8c:	8b 00                	mov    (%eax),%eax
c0105c8e:	8d 48 01             	lea    0x1(%eax),%ecx
c0105c91:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c94:	89 0a                	mov    %ecx,(%edx)
c0105c96:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c99:	88 10                	mov    %dl,(%eax)
    }
}
c0105c9b:	90                   	nop
c0105c9c:	5d                   	pop    %ebp
c0105c9d:	c3                   	ret    

c0105c9e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105c9e:	55                   	push   %ebp
c0105c9f:	89 e5                	mov    %esp,%ebp
c0105ca1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105ca4:	8d 45 14             	lea    0x14(%ebp),%eax
c0105ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105cb1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc2:	89 04 24             	mov    %eax,(%esp)
c0105cc5:	e8 0a 00 00 00       	call   c0105cd4 <vsnprintf>
c0105cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105cd0:	89 ec                	mov    %ebp,%esp
c0105cd2:	5d                   	pop    %ebp
c0105cd3:	c3                   	ret    

c0105cd4 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105cd4:	55                   	push   %ebp
c0105cd5:	89 e5                	mov    %esp,%ebp
c0105cd7:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ce3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce9:	01 d0                	add    %edx,%eax
c0105ceb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105cf5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105cf9:	74 0a                	je     c0105d05 <vsnprintf+0x31>
c0105cfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d01:	39 c2                	cmp    %eax,%edx
c0105d03:	76 07                	jbe    c0105d0c <vsnprintf+0x38>
        return -E_INVAL;
c0105d05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105d0a:	eb 2a                	jmp    c0105d36 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105d0c:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d13:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d16:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d21:	c7 04 24 68 5c 10 c0 	movl   $0xc0105c68,(%esp)
c0105d28:	e8 62 fb ff ff       	call   c010588f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d30:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105d36:	89 ec                	mov    %ebp,%esp
c0105d38:	5d                   	pop    %ebp
c0105d39:	c3                   	ret    

c0105d3a <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105d3a:	55                   	push   %ebp
c0105d3b:	89 e5                	mov    %esp,%ebp
c0105d3d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105d40:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105d47:	eb 03                	jmp    c0105d4c <strlen+0x12>
        cnt ++;
c0105d49:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4f:	8d 50 01             	lea    0x1(%eax),%edx
c0105d52:	89 55 08             	mov    %edx,0x8(%ebp)
c0105d55:	0f b6 00             	movzbl (%eax),%eax
c0105d58:	84 c0                	test   %al,%al
c0105d5a:	75 ed                	jne    c0105d49 <strlen+0xf>
    }
    return cnt;
c0105d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105d5f:	89 ec                	mov    %ebp,%esp
c0105d61:	5d                   	pop    %ebp
c0105d62:	c3                   	ret    

c0105d63 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105d63:	55                   	push   %ebp
c0105d64:	89 e5                	mov    %esp,%ebp
c0105d66:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105d69:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105d70:	eb 03                	jmp    c0105d75 <strnlen+0x12>
        cnt ++;
c0105d72:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105d75:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d78:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105d7b:	73 10                	jae    c0105d8d <strnlen+0x2a>
c0105d7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d80:	8d 50 01             	lea    0x1(%eax),%edx
c0105d83:	89 55 08             	mov    %edx,0x8(%ebp)
c0105d86:	0f b6 00             	movzbl (%eax),%eax
c0105d89:	84 c0                	test   %al,%al
c0105d8b:	75 e5                	jne    c0105d72 <strnlen+0xf>
    }
    return cnt;
c0105d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105d90:	89 ec                	mov    %ebp,%esp
c0105d92:	5d                   	pop    %ebp
c0105d93:	c3                   	ret    

c0105d94 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105d94:	55                   	push   %ebp
c0105d95:	89 e5                	mov    %esp,%ebp
c0105d97:	57                   	push   %edi
c0105d98:	56                   	push   %esi
c0105d99:	83 ec 20             	sub    $0x20,%esp
c0105d9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105da2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105da8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dae:	89 d1                	mov    %edx,%ecx
c0105db0:	89 c2                	mov    %eax,%edx
c0105db2:	89 ce                	mov    %ecx,%esi
c0105db4:	89 d7                	mov    %edx,%edi
c0105db6:	ac                   	lods   %ds:(%esi),%al
c0105db7:	aa                   	stos   %al,%es:(%edi)
c0105db8:	84 c0                	test   %al,%al
c0105dba:	75 fa                	jne    c0105db6 <strcpy+0x22>
c0105dbc:	89 fa                	mov    %edi,%edx
c0105dbe:	89 f1                	mov    %esi,%ecx
c0105dc0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105dc3:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105dc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105dcc:	83 c4 20             	add    $0x20,%esp
c0105dcf:	5e                   	pop    %esi
c0105dd0:	5f                   	pop    %edi
c0105dd1:	5d                   	pop    %ebp
c0105dd2:	c3                   	ret    

c0105dd3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105dd3:	55                   	push   %ebp
c0105dd4:	89 e5                	mov    %esp,%ebp
c0105dd6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105dd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ddc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105ddf:	eb 1e                	jmp    c0105dff <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105de1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de4:	0f b6 10             	movzbl (%eax),%edx
c0105de7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105dea:	88 10                	mov    %dl,(%eax)
c0105dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105def:	0f b6 00             	movzbl (%eax),%eax
c0105df2:	84 c0                	test   %al,%al
c0105df4:	74 03                	je     c0105df9 <strncpy+0x26>
            src ++;
c0105df6:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105df9:	ff 45 fc             	incl   -0x4(%ebp)
c0105dfc:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0105dff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e03:	75 dc                	jne    c0105de1 <strncpy+0xe>
    }
    return dst;
c0105e05:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105e08:	89 ec                	mov    %ebp,%esp
c0105e0a:	5d                   	pop    %ebp
c0105e0b:	c3                   	ret    

c0105e0c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105e0c:	55                   	push   %ebp
c0105e0d:	89 e5                	mov    %esp,%ebp
c0105e0f:	57                   	push   %edi
c0105e10:	56                   	push   %esi
c0105e11:	83 ec 20             	sub    $0x20,%esp
c0105e14:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0105e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e26:	89 d1                	mov    %edx,%ecx
c0105e28:	89 c2                	mov    %eax,%edx
c0105e2a:	89 ce                	mov    %ecx,%esi
c0105e2c:	89 d7                	mov    %edx,%edi
c0105e2e:	ac                   	lods   %ds:(%esi),%al
c0105e2f:	ae                   	scas   %es:(%edi),%al
c0105e30:	75 08                	jne    c0105e3a <strcmp+0x2e>
c0105e32:	84 c0                	test   %al,%al
c0105e34:	75 f8                	jne    c0105e2e <strcmp+0x22>
c0105e36:	31 c0                	xor    %eax,%eax
c0105e38:	eb 04                	jmp    c0105e3e <strcmp+0x32>
c0105e3a:	19 c0                	sbb    %eax,%eax
c0105e3c:	0c 01                	or     $0x1,%al
c0105e3e:	89 fa                	mov    %edi,%edx
c0105e40:	89 f1                	mov    %esi,%ecx
c0105e42:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e45:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105e48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105e4e:	83 c4 20             	add    $0x20,%esp
c0105e51:	5e                   	pop    %esi
c0105e52:	5f                   	pop    %edi
c0105e53:	5d                   	pop    %ebp
c0105e54:	c3                   	ret    

c0105e55 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105e55:	55                   	push   %ebp
c0105e56:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105e58:	eb 09                	jmp    c0105e63 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105e5a:	ff 4d 10             	decl   0x10(%ebp)
c0105e5d:	ff 45 08             	incl   0x8(%ebp)
c0105e60:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105e63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e67:	74 1a                	je     c0105e83 <strncmp+0x2e>
c0105e69:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6c:	0f b6 00             	movzbl (%eax),%eax
c0105e6f:	84 c0                	test   %al,%al
c0105e71:	74 10                	je     c0105e83 <strncmp+0x2e>
c0105e73:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e76:	0f b6 10             	movzbl (%eax),%edx
c0105e79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e7c:	0f b6 00             	movzbl (%eax),%eax
c0105e7f:	38 c2                	cmp    %al,%dl
c0105e81:	74 d7                	je     c0105e5a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e87:	74 18                	je     c0105ea1 <strncmp+0x4c>
c0105e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e8c:	0f b6 00             	movzbl (%eax),%eax
c0105e8f:	0f b6 d0             	movzbl %al,%edx
c0105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e95:	0f b6 00             	movzbl (%eax),%eax
c0105e98:	0f b6 c8             	movzbl %al,%ecx
c0105e9b:	89 d0                	mov    %edx,%eax
c0105e9d:	29 c8                	sub    %ecx,%eax
c0105e9f:	eb 05                	jmp    c0105ea6 <strncmp+0x51>
c0105ea1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ea6:	5d                   	pop    %ebp
c0105ea7:	c3                   	ret    

c0105ea8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105ea8:	55                   	push   %ebp
c0105ea9:	89 e5                	mov    %esp,%ebp
c0105eab:	83 ec 04             	sub    $0x4,%esp
c0105eae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eb1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105eb4:	eb 13                	jmp    c0105ec9 <strchr+0x21>
        if (*s == c) {
c0105eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb9:	0f b6 00             	movzbl (%eax),%eax
c0105ebc:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105ebf:	75 05                	jne    c0105ec6 <strchr+0x1e>
            return (char *)s;
c0105ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec4:	eb 12                	jmp    c0105ed8 <strchr+0x30>
        }
        s ++;
c0105ec6:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ecc:	0f b6 00             	movzbl (%eax),%eax
c0105ecf:	84 c0                	test   %al,%al
c0105ed1:	75 e3                	jne    c0105eb6 <strchr+0xe>
    }
    return NULL;
c0105ed3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ed8:	89 ec                	mov    %ebp,%esp
c0105eda:	5d                   	pop    %ebp
c0105edb:	c3                   	ret    

c0105edc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105edc:	55                   	push   %ebp
c0105edd:	89 e5                	mov    %esp,%ebp
c0105edf:	83 ec 04             	sub    $0x4,%esp
c0105ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ee5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ee8:	eb 0e                	jmp    c0105ef8 <strfind+0x1c>
        if (*s == c) {
c0105eea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eed:	0f b6 00             	movzbl (%eax),%eax
c0105ef0:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105ef3:	74 0f                	je     c0105f04 <strfind+0x28>
            break;
        }
        s ++;
c0105ef5:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105efb:	0f b6 00             	movzbl (%eax),%eax
c0105efe:	84 c0                	test   %al,%al
c0105f00:	75 e8                	jne    c0105eea <strfind+0xe>
c0105f02:	eb 01                	jmp    c0105f05 <strfind+0x29>
            break;
c0105f04:	90                   	nop
    }
    return (char *)s;
c0105f05:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105f08:	89 ec                	mov    %ebp,%esp
c0105f0a:	5d                   	pop    %ebp
c0105f0b:	c3                   	ret    

c0105f0c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105f0c:	55                   	push   %ebp
c0105f0d:	89 e5                	mov    %esp,%ebp
c0105f0f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105f12:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105f19:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105f20:	eb 03                	jmp    c0105f25 <strtol+0x19>
        s ++;
c0105f22:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0105f25:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f28:	0f b6 00             	movzbl (%eax),%eax
c0105f2b:	3c 20                	cmp    $0x20,%al
c0105f2d:	74 f3                	je     c0105f22 <strtol+0x16>
c0105f2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f32:	0f b6 00             	movzbl (%eax),%eax
c0105f35:	3c 09                	cmp    $0x9,%al
c0105f37:	74 e9                	je     c0105f22 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0105f39:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3c:	0f b6 00             	movzbl (%eax),%eax
c0105f3f:	3c 2b                	cmp    $0x2b,%al
c0105f41:	75 05                	jne    c0105f48 <strtol+0x3c>
        s ++;
c0105f43:	ff 45 08             	incl   0x8(%ebp)
c0105f46:	eb 14                	jmp    c0105f5c <strtol+0x50>
    }
    else if (*s == '-') {
c0105f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4b:	0f b6 00             	movzbl (%eax),%eax
c0105f4e:	3c 2d                	cmp    $0x2d,%al
c0105f50:	75 0a                	jne    c0105f5c <strtol+0x50>
        s ++, neg = 1;
c0105f52:	ff 45 08             	incl   0x8(%ebp)
c0105f55:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105f5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105f60:	74 06                	je     c0105f68 <strtol+0x5c>
c0105f62:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105f66:	75 22                	jne    c0105f8a <strtol+0x7e>
c0105f68:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f6b:	0f b6 00             	movzbl (%eax),%eax
c0105f6e:	3c 30                	cmp    $0x30,%al
c0105f70:	75 18                	jne    c0105f8a <strtol+0x7e>
c0105f72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f75:	40                   	inc    %eax
c0105f76:	0f b6 00             	movzbl (%eax),%eax
c0105f79:	3c 78                	cmp    $0x78,%al
c0105f7b:	75 0d                	jne    c0105f8a <strtol+0x7e>
        s += 2, base = 16;
c0105f7d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105f81:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105f88:	eb 29                	jmp    c0105fb3 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105f8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105f8e:	75 16                	jne    c0105fa6 <strtol+0x9a>
c0105f90:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f93:	0f b6 00             	movzbl (%eax),%eax
c0105f96:	3c 30                	cmp    $0x30,%al
c0105f98:	75 0c                	jne    c0105fa6 <strtol+0x9a>
        s ++, base = 8;
c0105f9a:	ff 45 08             	incl   0x8(%ebp)
c0105f9d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105fa4:	eb 0d                	jmp    c0105fb3 <strtol+0xa7>
    }
    else if (base == 0) {
c0105fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105faa:	75 07                	jne    c0105fb3 <strtol+0xa7>
        base = 10;
c0105fac:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105fb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fb6:	0f b6 00             	movzbl (%eax),%eax
c0105fb9:	3c 2f                	cmp    $0x2f,%al
c0105fbb:	7e 1b                	jle    c0105fd8 <strtol+0xcc>
c0105fbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc0:	0f b6 00             	movzbl (%eax),%eax
c0105fc3:	3c 39                	cmp    $0x39,%al
c0105fc5:	7f 11                	jg     c0105fd8 <strtol+0xcc>
            dig = *s - '0';
c0105fc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fca:	0f b6 00             	movzbl (%eax),%eax
c0105fcd:	0f be c0             	movsbl %al,%eax
c0105fd0:	83 e8 30             	sub    $0x30,%eax
c0105fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fd6:	eb 48                	jmp    c0106020 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105fd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fdb:	0f b6 00             	movzbl (%eax),%eax
c0105fde:	3c 60                	cmp    $0x60,%al
c0105fe0:	7e 1b                	jle    c0105ffd <strtol+0xf1>
c0105fe2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fe5:	0f b6 00             	movzbl (%eax),%eax
c0105fe8:	3c 7a                	cmp    $0x7a,%al
c0105fea:	7f 11                	jg     c0105ffd <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105fec:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fef:	0f b6 00             	movzbl (%eax),%eax
c0105ff2:	0f be c0             	movsbl %al,%eax
c0105ff5:	83 e8 57             	sub    $0x57,%eax
c0105ff8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ffb:	eb 23                	jmp    c0106020 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105ffd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106000:	0f b6 00             	movzbl (%eax),%eax
c0106003:	3c 40                	cmp    $0x40,%al
c0106005:	7e 3b                	jle    c0106042 <strtol+0x136>
c0106007:	8b 45 08             	mov    0x8(%ebp),%eax
c010600a:	0f b6 00             	movzbl (%eax),%eax
c010600d:	3c 5a                	cmp    $0x5a,%al
c010600f:	7f 31                	jg     c0106042 <strtol+0x136>
            dig = *s - 'A' + 10;
c0106011:	8b 45 08             	mov    0x8(%ebp),%eax
c0106014:	0f b6 00             	movzbl (%eax),%eax
c0106017:	0f be c0             	movsbl %al,%eax
c010601a:	83 e8 37             	sub    $0x37,%eax
c010601d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106020:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106023:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106026:	7d 19                	jge    c0106041 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106028:	ff 45 08             	incl   0x8(%ebp)
c010602b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010602e:	0f af 45 10          	imul   0x10(%ebp),%eax
c0106032:	89 c2                	mov    %eax,%edx
c0106034:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106037:	01 d0                	add    %edx,%eax
c0106039:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010603c:	e9 72 ff ff ff       	jmp    c0105fb3 <strtol+0xa7>
            break;
c0106041:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0106042:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106046:	74 08                	je     c0106050 <strtol+0x144>
        *endptr = (char *) s;
c0106048:	8b 45 0c             	mov    0xc(%ebp),%eax
c010604b:	8b 55 08             	mov    0x8(%ebp),%edx
c010604e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106050:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106054:	74 07                	je     c010605d <strtol+0x151>
c0106056:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106059:	f7 d8                	neg    %eax
c010605b:	eb 03                	jmp    c0106060 <strtol+0x154>
c010605d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106060:	89 ec                	mov    %ebp,%esp
c0106062:	5d                   	pop    %ebp
c0106063:	c3                   	ret    

c0106064 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106064:	55                   	push   %ebp
c0106065:	89 e5                	mov    %esp,%ebp
c0106067:	83 ec 28             	sub    $0x28,%esp
c010606a:	89 7d fc             	mov    %edi,-0x4(%ebp)
c010606d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106070:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106073:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0106077:	8b 45 08             	mov    0x8(%ebp),%eax
c010607a:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010607d:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0106080:	8b 45 10             	mov    0x10(%ebp),%eax
c0106083:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106086:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106089:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010608d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106090:	89 d7                	mov    %edx,%edi
c0106092:	f3 aa                	rep stos %al,%es:(%edi)
c0106094:	89 fa                	mov    %edi,%edx
c0106096:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106099:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010609c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010609f:	8b 7d fc             	mov    -0x4(%ebp),%edi
c01060a2:	89 ec                	mov    %ebp,%esp
c01060a4:	5d                   	pop    %ebp
c01060a5:	c3                   	ret    

c01060a6 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01060a6:	55                   	push   %ebp
c01060a7:	89 e5                	mov    %esp,%ebp
c01060a9:	57                   	push   %edi
c01060aa:	56                   	push   %esi
c01060ab:	53                   	push   %ebx
c01060ac:	83 ec 30             	sub    $0x30,%esp
c01060af:	8b 45 08             	mov    0x8(%ebp),%eax
c01060b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01060bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01060be:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01060c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060c4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01060c7:	73 42                	jae    c010610b <memmove+0x65>
c01060c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01060d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01060db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060de:	c1 e8 02             	shr    $0x2,%eax
c01060e1:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01060e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01060e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01060e9:	89 d7                	mov    %edx,%edi
c01060eb:	89 c6                	mov    %eax,%esi
c01060ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01060ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01060f2:	83 e1 03             	and    $0x3,%ecx
c01060f5:	74 02                	je     c01060f9 <memmove+0x53>
c01060f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01060f9:	89 f0                	mov    %esi,%eax
c01060fb:	89 fa                	mov    %edi,%edx
c01060fd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106100:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106103:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0106106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0106109:	eb 36                	jmp    c0106141 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010610b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010610e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106111:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106114:	01 c2                	add    %eax,%edx
c0106116:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106119:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010611c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010611f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0106122:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106125:	89 c1                	mov    %eax,%ecx
c0106127:	89 d8                	mov    %ebx,%eax
c0106129:	89 d6                	mov    %edx,%esi
c010612b:	89 c7                	mov    %eax,%edi
c010612d:	fd                   	std    
c010612e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106130:	fc                   	cld    
c0106131:	89 f8                	mov    %edi,%eax
c0106133:	89 f2                	mov    %esi,%edx
c0106135:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106138:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010613b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010613e:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106141:	83 c4 30             	add    $0x30,%esp
c0106144:	5b                   	pop    %ebx
c0106145:	5e                   	pop    %esi
c0106146:	5f                   	pop    %edi
c0106147:	5d                   	pop    %ebp
c0106148:	c3                   	ret    

c0106149 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106149:	55                   	push   %ebp
c010614a:	89 e5                	mov    %esp,%ebp
c010614c:	57                   	push   %edi
c010614d:	56                   	push   %esi
c010614e:	83 ec 20             	sub    $0x20,%esp
c0106151:	8b 45 08             	mov    0x8(%ebp),%eax
c0106154:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106157:	8b 45 0c             	mov    0xc(%ebp),%eax
c010615a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010615d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106160:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106163:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106166:	c1 e8 02             	shr    $0x2,%eax
c0106169:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010616b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106171:	89 d7                	mov    %edx,%edi
c0106173:	89 c6                	mov    %eax,%esi
c0106175:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106177:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010617a:	83 e1 03             	and    $0x3,%ecx
c010617d:	74 02                	je     c0106181 <memcpy+0x38>
c010617f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106181:	89 f0                	mov    %esi,%eax
c0106183:	89 fa                	mov    %edi,%edx
c0106185:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106188:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010618b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010618e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106191:	83 c4 20             	add    $0x20,%esp
c0106194:	5e                   	pop    %esi
c0106195:	5f                   	pop    %edi
c0106196:	5d                   	pop    %ebp
c0106197:	c3                   	ret    

c0106198 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0106198:	55                   	push   %ebp
c0106199:	89 e5                	mov    %esp,%ebp
c010619b:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010619e:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01061a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01061aa:	eb 2e                	jmp    c01061da <memcmp+0x42>
        if (*s1 != *s2) {
c01061ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061af:	0f b6 10             	movzbl (%eax),%edx
c01061b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01061b5:	0f b6 00             	movzbl (%eax),%eax
c01061b8:	38 c2                	cmp    %al,%dl
c01061ba:	74 18                	je     c01061d4 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01061bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061bf:	0f b6 00             	movzbl (%eax),%eax
c01061c2:	0f b6 d0             	movzbl %al,%edx
c01061c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01061c8:	0f b6 00             	movzbl (%eax),%eax
c01061cb:	0f b6 c8             	movzbl %al,%ecx
c01061ce:	89 d0                	mov    %edx,%eax
c01061d0:	29 c8                	sub    %ecx,%eax
c01061d2:	eb 18                	jmp    c01061ec <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01061d4:	ff 45 fc             	incl   -0x4(%ebp)
c01061d7:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c01061da:	8b 45 10             	mov    0x10(%ebp),%eax
c01061dd:	8d 50 ff             	lea    -0x1(%eax),%edx
c01061e0:	89 55 10             	mov    %edx,0x10(%ebp)
c01061e3:	85 c0                	test   %eax,%eax
c01061e5:	75 c5                	jne    c01061ac <memcmp+0x14>
    }
    return 0;
c01061e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01061ec:	89 ec                	mov    %ebp,%esp
c01061ee:	5d                   	pop    %ebp
c01061ef:	c3                   	ret    
