
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	b8 2c cf 11 00       	mov    $0x11cf2c,%eax
  100041:	2d 36 9a 11 00       	sub    $0x119a36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  100059:	e8 06 60 00 00       	call   106064 <memset>

    cons_init();                // init the console
  10005e:	e8 0e 16 00 00       	call   101671 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f4 00 62 10 00 	movl   $0x106200,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 1c 62 10 00 	movl   $0x10621c,(%esp)
  100078:	e8 d9 02 00 00       	call   100356 <cprintf>

    print_kerninfo();
  10007d:	e8 f7 07 00 00       	call   100879 <print_kerninfo>

    grade_backtrace();
  100082:	e8 90 00 00 00       	call   100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100087:	e8 eb 44 00 00       	call   104577 <pmm_init>

    pic_init();                 // init interrupt controller
  10008c:	e8 61 17 00 00       	call   1017f2 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100091:	e8 e8 18 00 00       	call   10197e <idt_init>

    clock_init();               // init clock interrupt
  100096:	e8 35 0d 00 00       	call   100dd0 <clock_init>
    intr_enable();              // enable irq interrupt
  10009b:	e8 b0 16 00 00       	call   101750 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a0:	eb fe                	jmp    1000a0 <kern_init+0x6a>

001000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a2:	55                   	push   %ebp
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000af:	00 
  1000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000b7:	00 
  1000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000bf:	e8 27 0c 00 00       	call   100ceb <mon_backtrace>
}
  1000c4:	90                   	nop
  1000c5:	89 ec                	mov    %ebp,%esp
  1000c7:	5d                   	pop    %ebp
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 18             	sub    $0x18,%esp
  1000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b0 ff ff ff       	call   1000a2 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000f6:	89 ec                	mov    %ebp,%esp
  1000f8:	5d                   	pop    %ebp
  1000f9:	c3                   	ret    

001000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fa:	55                   	push   %ebp
  1000fb:	89 e5                	mov    %esp,%ebp
  1000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100100:	8b 45 10             	mov    0x10(%ebp),%eax
  100103:	89 44 24 04          	mov    %eax,0x4(%esp)
  100107:	8b 45 08             	mov    0x8(%ebp),%eax
  10010a:	89 04 24             	mov    %eax,(%esp)
  10010d:	e8 b7 ff ff ff       	call   1000c9 <grade_backtrace1>
}
  100112:	90                   	nop
  100113:	89 ec                	mov    %ebp,%esp
  100115:	5d                   	pop    %ebp
  100116:	c3                   	ret    

00100117 <grade_backtrace>:

void
grade_backtrace(void) {
  100117:	55                   	push   %ebp
  100118:	89 e5                	mov    %esp,%ebp
  10011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011d:	b8 36 00 10 00       	mov    $0x100036,%eax
  100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100129:	ff 
  10012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100135:	e8 c0 ff ff ff       	call   1000fa <grade_backtrace0>
}
  10013a:	90                   	nop
  10013b:	89 ec                	mov    %ebp,%esp
  10013d:	5d                   	pop    %ebp
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 21 62 10 00 	movl   $0x106221,(%esp)
  10016e:	e8 e3 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 2f 62 10 00 	movl   $0x10622f,(%esp)
  10018d:	e8 c4 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 3d 62 10 00 	movl   $0x10623d,(%esp)
  1001ac:	e8 a5 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 4b 62 10 00 	movl   $0x10624b,(%esp)
  1001cb:	e8 86 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 59 62 10 00 	movl   $0x106259,(%esp)
  1001ea:	e8 67 01 00 00       	call   100356 <cprintf>
    round ++;
  1001ef:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  1001fa:	90                   	nop
  1001fb:	89 ec                	mov    %ebp,%esp
  1001fd:	5d                   	pop    %ebp
  1001fe:	c3                   	ret    

001001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001ff:	55                   	push   %ebp
  100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  100202:	90                   	nop
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100208:	90                   	nop
  100209:	5d                   	pop    %ebp
  10020a:	c3                   	ret    

0010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10020b:	55                   	push   %ebp
  10020c:	89 e5                	mov    %esp,%ebp
  10020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100211:	e8 29 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100216:	c7 04 24 68 62 10 00 	movl   $0x106268,(%esp)
  10021d:	e8 34 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_user();
  100222:	e8 d8 ff ff ff       	call   1001ff <lab1_switch_to_user>
    lab1_print_cur_status();
  100227:	e8 13 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022c:	c7 04 24 88 62 10 00 	movl   $0x106288,(%esp)
  100233:	e8 1e 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_kernel();
  100238:	e8 c8 ff ff ff       	call   100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10023d:	e8 fd fe ff ff       	call   10013f <lab1_print_cur_status>
}
  100242:	90                   	nop
  100243:	89 ec                	mov    %ebp,%esp
  100245:	5d                   	pop    %ebp
  100246:	c3                   	ret    

00100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100247:	55                   	push   %ebp
  100248:	89 e5                	mov    %esp,%ebp
  10024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100251:	74 13                	je     100266 <readline+0x1f>
        cprintf("%s", prompt);
  100253:	8b 45 08             	mov    0x8(%ebp),%eax
  100256:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025a:	c7 04 24 a7 62 10 00 	movl   $0x1062a7,(%esp)
  100261:	e8 f0 00 00 00       	call   100356 <cprintf>
    }
    int i = 0, c;
  100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10026d:	e8 73 01 00 00       	call   1003e5 <getchar>
  100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100279:	79 07                	jns    100282 <readline+0x3b>
            return NULL;
  10027b:	b8 00 00 00 00       	mov    $0x0,%eax
  100280:	eb 78                	jmp    1002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100286:	7e 28                	jle    1002b0 <readline+0x69>
  100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10028f:	7f 1f                	jg     1002b0 <readline+0x69>
            cputchar(c);
  100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100294:	89 04 24             	mov    %eax,(%esp)
  100297:	e8 e2 00 00 00       	call   10037e <cputchar>
            buf[i ++] = c;
  10029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10029f:	8d 50 01             	lea    0x1(%eax),%edx
  1002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a8:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
  1002ae:	eb 45                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b4:	75 16                	jne    1002cc <readline+0x85>
  1002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ba:	7e 10                	jle    1002cc <readline+0x85>
            cputchar(c);
  1002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002bf:	89 04 24             	mov    %eax,(%esp)
  1002c2:	e8 b7 00 00 00       	call   10037e <cputchar>
            i --;
  1002c7:	ff 4d f4             	decl   -0xc(%ebp)
  1002ca:	eb 29                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d0:	74 06                	je     1002d8 <readline+0x91>
  1002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002d6:	75 95                	jne    10026d <readline+0x26>
            cputchar(c);
  1002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002db:	89 04 24             	mov    %eax,(%esp)
  1002de:	e8 9b 00 00 00       	call   10037e <cputchar>
            buf[i] = '\0';
  1002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e6:	05 20 c0 11 00       	add    $0x11c020,%eax
  1002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ee:	b8 20 c0 11 00       	mov    $0x11c020,%eax
  1002f3:	eb 05                	jmp    1002fa <readline+0xb3>
        c = getchar();
  1002f5:	e9 73 ff ff ff       	jmp    10026d <readline+0x26>
        }
    }
}
  1002fa:	89 ec                	mov    %ebp,%esp
  1002fc:	5d                   	pop    %ebp
  1002fd:	c3                   	ret    

001002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002fe:	55                   	push   %ebp
  1002ff:	89 e5                	mov    %esp,%ebp
  100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100304:	8b 45 08             	mov    0x8(%ebp),%eax
  100307:	89 04 24             	mov    %eax,(%esp)
  10030a:	e8 91 13 00 00       	call   1016a0 <cons_putc>
    (*cnt) ++;
  10030f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100312:	8b 00                	mov    (%eax),%eax
  100314:	8d 50 01             	lea    0x1(%eax),%edx
  100317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031a:	89 10                	mov    %edx,(%eax)
}
  10031c:	90                   	nop
  10031d:	89 ec                	mov    %ebp,%esp
  10031f:	5d                   	pop    %ebp
  100320:	c3                   	ret    

00100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100321:	55                   	push   %ebp
  100322:	89 e5                	mov    %esp,%ebp
  100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100343:	c7 04 24 fe 02 10 00 	movl   $0x1002fe,(%esp)
  10034a:	e8 40 55 00 00       	call   10588f <vprintfmt>
    return cnt;
  10034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100352:	89 ec                	mov    %ebp,%esp
  100354:	5d                   	pop    %ebp
  100355:	c3                   	ret    

00100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100356:	55                   	push   %ebp
  100357:	89 e5                	mov    %esp,%ebp
  100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10035c:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100365:	89 44 24 04          	mov    %eax,0x4(%esp)
  100369:	8b 45 08             	mov    0x8(%ebp),%eax
  10036c:	89 04 24             	mov    %eax,(%esp)
  10036f:	e8 ad ff ff ff       	call   100321 <vcprintf>
  100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037a:	89 ec                	mov    %ebp,%esp
  10037c:	5d                   	pop    %ebp
  10037d:	c3                   	ret    

0010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037e:	55                   	push   %ebp
  10037f:	89 e5                	mov    %esp,%ebp
  100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100384:	8b 45 08             	mov    0x8(%ebp),%eax
  100387:	89 04 24             	mov    %eax,(%esp)
  10038a:	e8 11 13 00 00       	call   1016a0 <cons_putc>
}
  10038f:	90                   	nop
  100390:	89 ec                	mov    %ebp,%esp
  100392:	5d                   	pop    %ebp
  100393:	c3                   	ret    

00100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100394:	55                   	push   %ebp
  100395:	89 e5                	mov    %esp,%ebp
  100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003a1:	eb 13                	jmp    1003b6 <cputs+0x22>
        cputch(c, &cnt);
  1003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003ae:	89 04 24             	mov    %eax,(%esp)
  1003b1:	e8 48 ff ff ff       	call   1002fe <cputch>
    while ((c = *str ++) != '\0') {
  1003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b9:	8d 50 01             	lea    0x1(%eax),%edx
  1003bc:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bf:	0f b6 00             	movzbl (%eax),%eax
  1003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c9:	75 d8                	jne    1003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d9:	e8 20 ff ff ff       	call   1002fe <cputch>
    return cnt;
  1003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003e1:	89 ec                	mov    %ebp,%esp
  1003e3:	5d                   	pop    %ebp
  1003e4:	c3                   	ret    

001003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e5:	55                   	push   %ebp
  1003e6:	89 e5                	mov    %esp,%ebp
  1003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003eb:	90                   	nop
  1003ec:	e8 ee 12 00 00       	call   1016df <cons_getc>
  1003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f8:	74 f2                	je     1003ec <getchar+0x7>
        /* do nothing */;
    return c;
  1003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003fd:	89 ec                	mov    %ebp,%esp
  1003ff:	5d                   	pop    %ebp
  100400:	c3                   	ret    

00100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100401:	55                   	push   %ebp
  100402:	89 e5                	mov    %esp,%ebp
  100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100407:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040a:	8b 00                	mov    (%eax),%eax
  10040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10040f:	8b 45 10             	mov    0x10(%ebp),%eax
  100412:	8b 00                	mov    (%eax),%eax
  100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10041e:	e9 ca 00 00 00       	jmp    1004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100429:	01 d0                	add    %edx,%eax
  10042b:	89 c2                	mov    %eax,%edx
  10042d:	c1 ea 1f             	shr    $0x1f,%edx
  100430:	01 d0                	add    %edx,%eax
  100432:	d1 f8                	sar    %eax
  100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10043d:	eb 03                	jmp    100442 <stab_binsearch+0x41>
            m --;
  10043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100448:	7c 1f                	jl     100469 <stab_binsearch+0x68>
  10044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10044d:	89 d0                	mov    %edx,%eax
  10044f:	01 c0                	add    %eax,%eax
  100451:	01 d0                	add    %edx,%eax
  100453:	c1 e0 02             	shl    $0x2,%eax
  100456:	89 c2                	mov    %eax,%edx
  100458:	8b 45 08             	mov    0x8(%ebp),%eax
  10045b:	01 d0                	add    %edx,%eax
  10045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100461:	0f b6 c0             	movzbl %al,%eax
  100464:	39 45 14             	cmp    %eax,0x14(%ebp)
  100467:	75 d6                	jne    10043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10046f:	7d 09                	jge    10047a <stab_binsearch+0x79>
            l = true_m + 1;
  100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100474:	40                   	inc    %eax
  100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100478:	eb 73                	jmp    1004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100484:	89 d0                	mov    %edx,%eax
  100486:	01 c0                	add    %eax,%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	c1 e0 02             	shl    $0x2,%eax
  10048d:	89 c2                	mov    %eax,%edx
  10048f:	8b 45 08             	mov    0x8(%ebp),%eax
  100492:	01 d0                	add    %edx,%eax
  100494:	8b 40 08             	mov    0x8(%eax),%eax
  100497:	39 45 18             	cmp    %eax,0x18(%ebp)
  10049a:	76 11                	jbe    1004ad <stab_binsearch+0xac>
            *region_left = m;
  10049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a7:	40                   	inc    %eax
  1004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ab:	eb 40                	jmp    1004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004b0:	89 d0                	mov    %edx,%eax
  1004b2:	01 c0                	add    %eax,%eax
  1004b4:	01 d0                	add    %edx,%eax
  1004b6:	c1 e0 02             	shl    $0x2,%eax
  1004b9:	89 c2                	mov    %eax,%edx
  1004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1004be:	01 d0                	add    %edx,%eax
  1004c0:	8b 40 08             	mov    0x8(%eax),%eax
  1004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004c6:	73 14                	jae    1004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
  1004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	48                   	dec    %eax
  1004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004da:	eb 11                	jmp    1004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e2:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004f3:	0f 8e 2a ff ff ff    	jle    100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004fd:	75 0f                	jne    10050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 00                	mov    (%eax),%eax
  100504:	8d 50 ff             	lea    -0x1(%eax),%edx
  100507:	8b 45 10             	mov    0x10(%ebp),%eax
  10050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10050c:	eb 3e                	jmp    10054c <stab_binsearch+0x14b>
        l = *region_right;
  10050e:	8b 45 10             	mov    0x10(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100516:	eb 03                	jmp    10051b <stab_binsearch+0x11a>
  100518:	ff 4d fc             	decl   -0x4(%ebp)
  10051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051e:	8b 00                	mov    (%eax),%eax
  100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100523:	7e 1f                	jle    100544 <stab_binsearch+0x143>
  100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100528:	89 d0                	mov    %edx,%eax
  10052a:	01 c0                	add    %eax,%eax
  10052c:	01 d0                	add    %edx,%eax
  10052e:	c1 e0 02             	shl    $0x2,%eax
  100531:	89 c2                	mov    %eax,%edx
  100533:	8b 45 08             	mov    0x8(%ebp),%eax
  100536:	01 d0                	add    %edx,%eax
  100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053c:	0f b6 c0             	movzbl %al,%eax
  10053f:	39 45 14             	cmp    %eax,0x14(%ebp)
  100542:	75 d4                	jne    100518 <stab_binsearch+0x117>
        *region_left = l;
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10054a:	89 10                	mov    %edx,(%eax)
}
  10054c:	90                   	nop
  10054d:	89 ec                	mov    %ebp,%esp
  10054f:	5d                   	pop    %ebp
  100550:	c3                   	ret    

00100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100551:	55                   	push   %ebp
  100552:	89 e5                	mov    %esp,%ebp
  100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055a:	c7 00 ac 62 10 00    	movl   $0x1062ac,(%eax)
    info->eip_line = 0;
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056d:	c7 40 08 ac 62 10 00 	movl   $0x1062ac,0x8(%eax)
    info->eip_fn_namelen = 9;
  100574:	8b 45 0c             	mov    0xc(%ebp),%eax
  100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100581:	8b 55 08             	mov    0x8(%ebp),%edx
  100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100587:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100591:	c7 45 f4 48 75 10 00 	movl   $0x107548,-0xc(%ebp)
    stab_end = __STAB_END__;
  100598:	c7 45 f0 6c 2f 11 00 	movl   $0x112f6c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059f:	c7 45 ec 6d 2f 11 00 	movl   $0x112f6d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a6:	c7 45 e8 47 65 11 00 	movl   $0x116547,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005b3:	76 0b                	jbe    1005c0 <debuginfo_eip+0x6f>
  1005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b8:	48                   	dec    %eax
  1005b9:	0f b6 00             	movzbl (%eax),%eax
  1005bc:	84 c0                	test   %al,%al
  1005be:	74 0a                	je     1005ca <debuginfo_eip+0x79>
        return -1;
  1005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c5:	e9 ab 02 00 00       	jmp    100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005d7:	c1 f8 02             	sar    $0x2,%eax
  1005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005e0:	48                   	dec    %eax
  1005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f2:	00 
  1005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100604:	89 04 24             	mov    %eax,(%esp)
  100607:	e8 f5 fd ff ff       	call   100401 <stab_binsearch>
    if (lfile == 0)
  10060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10060f:	85 c0                	test   %eax,%eax
  100611:	75 0a                	jne    10061d <debuginfo_eip+0xcc>
        return -1;
  100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100618:	e9 58 02 00 00       	jmp    100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100629:	8b 45 08             	mov    0x8(%ebp),%eax
  10062c:	89 44 24 10          	mov    %eax,0x10(%esp)
  100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100637:	00 
  100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100642:	89 44 24 04          	mov    %eax,0x4(%esp)
  100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100649:	89 04 24             	mov    %eax,(%esp)
  10064c:	e8 b0 fd ff ff       	call   100401 <stab_binsearch>

    if (lfun <= rfun) {
  100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100657:	39 c2                	cmp    %eax,%edx
  100659:	7f 78                	jg     1006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	89 d0                	mov    %edx,%eax
  100662:	01 c0                	add    %eax,%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	c1 e0 02             	shl    $0x2,%eax
  100669:	89 c2                	mov    %eax,%edx
  10066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066e:	01 d0                	add    %edx,%eax
  100670:	8b 10                	mov    (%eax),%edx
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100678:	39 c2                	cmp    %eax,%edx
  10067a:	73 22                	jae    10069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10067f:	89 c2                	mov    %eax,%edx
  100681:	89 d0                	mov    %edx,%eax
  100683:	01 c0                	add    %eax,%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	c1 e0 02             	shl    $0x2,%eax
  10068a:	89 c2                	mov    %eax,%edx
  10068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068f:	01 d0                	add    %edx,%eax
  100691:	8b 10                	mov    (%eax),%edx
  100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100696:	01 c2                	add    %eax,%edx
  100698:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a1:	89 c2                	mov    %eax,%edx
  1006a3:	89 d0                	mov    %edx,%eax
  1006a5:	01 c0                	add    %eax,%eax
  1006a7:	01 d0                	add    %edx,%eax
  1006a9:	c1 e0 02             	shl    $0x2,%eax
  1006ac:	89 c2                	mov    %eax,%edx
  1006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b1:	01 d0                	add    %edx,%eax
  1006b3:	8b 50 08             	mov    0x8(%eax),%edx
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 10             	mov    0x10(%eax),%eax
  1006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d1:	eb 15                	jmp    1006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006eb:	8b 40 08             	mov    0x8(%eax),%eax
  1006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006f5:	00 
  1006f6:	89 04 24             	mov    %eax,(%esp)
  1006f9:	e8 de 57 00 00       	call   105edc <strfind>
  1006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  100701:	8b 4a 08             	mov    0x8(%edx),%ecx
  100704:	29 c8                	sub    %ecx,%eax
  100706:	89 c2                	mov    %eax,%edx
  100708:	8b 45 0c             	mov    0xc(%ebp),%eax
  10070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10070e:	8b 45 08             	mov    0x8(%ebp),%eax
  100711:	89 44 24 10          	mov    %eax,0x10(%esp)
  100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  10071c:	00 
  10071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100720:	89 44 24 08          	mov    %eax,0x8(%esp)
  100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100727:	89 44 24 04          	mov    %eax,0x4(%esp)
  10072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072e:	89 04 24             	mov    %eax,(%esp)
  100731:	e8 cb fc ff ff       	call   100401 <stab_binsearch>
    if (lline <= rline) {
  100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073c:	39 c2                	cmp    %eax,%edx
  10073e:	7f 23                	jg     100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	89 d0                	mov    %edx,%eax
  100747:	01 c0                	add    %eax,%eax
  100749:	01 d0                	add    %edx,%eax
  10074b:	c1 e0 02             	shl    $0x2,%eax
  10074e:	89 c2                	mov    %eax,%edx
  100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100753:	01 d0                	add    %edx,%eax
  100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100759:	89 c2                	mov    %eax,%edx
  10075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100761:	eb 11                	jmp    100774 <debuginfo_eip+0x223>
        return -1;
  100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100768:	e9 08 01 00 00       	jmp    100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100770:	48                   	dec    %eax
  100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10077a:	39 c2                	cmp    %eax,%edx
  10077c:	7c 56                	jl     1007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  10077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100781:	89 c2                	mov    %eax,%edx
  100783:	89 d0                	mov    %edx,%eax
  100785:	01 c0                	add    %eax,%eax
  100787:	01 d0                	add    %edx,%eax
  100789:	c1 e0 02             	shl    $0x2,%eax
  10078c:	89 c2                	mov    %eax,%edx
  10078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100791:	01 d0                	add    %edx,%eax
  100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100797:	3c 84                	cmp    $0x84,%al
  100799:	74 39                	je     1007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079e:	89 c2                	mov    %eax,%edx
  1007a0:	89 d0                	mov    %edx,%eax
  1007a2:	01 c0                	add    %eax,%eax
  1007a4:	01 d0                	add    %edx,%eax
  1007a6:	c1 e0 02             	shl    $0x2,%eax
  1007a9:	89 c2                	mov    %eax,%edx
  1007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ae:	01 d0                	add    %edx,%eax
  1007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b4:	3c 64                	cmp    $0x64,%al
  1007b6:	75 b5                	jne    10076d <debuginfo_eip+0x21c>
  1007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	89 d0                	mov    %edx,%eax
  1007bf:	01 c0                	add    %eax,%eax
  1007c1:	01 d0                	add    %edx,%eax
  1007c3:	c1 e0 02             	shl    $0x2,%eax
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007cb:	01 d0                	add    %edx,%eax
  1007cd:	8b 40 08             	mov    0x8(%eax),%eax
  1007d0:	85 c0                	test   %eax,%eax
  1007d2:	74 99                	je     10076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007da:	39 c2                	cmp    %eax,%edx
  1007dc:	7c 42                	jl     100820 <debuginfo_eip+0x2cf>
  1007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e1:	89 c2                	mov    %eax,%edx
  1007e3:	89 d0                	mov    %edx,%eax
  1007e5:	01 c0                	add    %eax,%eax
  1007e7:	01 d0                	add    %edx,%eax
  1007e9:	c1 e0 02             	shl    $0x2,%eax
  1007ec:	89 c2                	mov    %eax,%edx
  1007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f1:	01 d0                	add    %edx,%eax
  1007f3:	8b 10                	mov    (%eax),%edx
  1007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007fb:	39 c2                	cmp    %eax,%edx
  1007fd:	73 21                	jae    100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	89 c2                	mov    %eax,%edx
  100804:	89 d0                	mov    %edx,%eax
  100806:	01 c0                	add    %eax,%eax
  100808:	01 d0                	add    %edx,%eax
  10080a:	c1 e0 02             	shl    $0x2,%eax
  10080d:	89 c2                	mov    %eax,%edx
  10080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100812:	01 d0                	add    %edx,%eax
  100814:	8b 10                	mov    (%eax),%edx
  100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100819:	01 c2                	add    %eax,%edx
  10081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100826:	39 c2                	cmp    %eax,%edx
  100828:	7d 46                	jge    100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  10082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082d:	40                   	inc    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100831:	eb 16                	jmp    100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100833:	8b 45 0c             	mov    0xc(%ebp),%eax
  100836:	8b 40 14             	mov    0x14(%eax),%eax
  100839:	8d 50 01             	lea    0x1(%eax),%edx
  10083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100845:	40                   	inc    %eax
  100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10084f:	39 c2                	cmp    %eax,%edx
  100851:	7d 1d                	jge    100870 <debuginfo_eip+0x31f>
  100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	89 d0                	mov    %edx,%eax
  10085a:	01 c0                	add    %eax,%eax
  10085c:	01 d0                	add    %edx,%eax
  10085e:	c1 e0 02             	shl    $0x2,%eax
  100861:	89 c2                	mov    %eax,%edx
  100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10086c:	3c a0                	cmp    $0xa0,%al
  10086e:	74 c3                	je     100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100875:	89 ec                	mov    %ebp,%esp
  100877:	5d                   	pop    %ebp
  100878:	c3                   	ret    

00100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100879:	55                   	push   %ebp
  10087a:	89 e5                	mov    %esp,%ebp
  10087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10087f:	c7 04 24 b6 62 10 00 	movl   $0x1062b6,(%esp)
  100886:	e8 cb fa ff ff       	call   100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100892:	00 
  100893:	c7 04 24 cf 62 10 00 	movl   $0x1062cf,(%esp)
  10089a:	e8 b7 fa ff ff       	call   100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089f:	c7 44 24 04 f0 61 10 	movl   $0x1061f0,0x4(%esp)
  1008a6:	00 
  1008a7:	c7 04 24 e7 62 10 00 	movl   $0x1062e7,(%esp)
  1008ae:	e8 a3 fa ff ff       	call   100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b3:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1008ba:	00 
  1008bb:	c7 04 24 ff 62 10 00 	movl   $0x1062ff,(%esp)
  1008c2:	e8 8f fa ff ff       	call   100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c7:	c7 44 24 04 2c cf 11 	movl   $0x11cf2c,0x4(%esp)
  1008ce:	00 
  1008cf:	c7 04 24 17 63 10 00 	movl   $0x106317,(%esp)
  1008d6:	e8 7b fa ff ff       	call   100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008db:	b8 2c cf 11 00       	mov    $0x11cf2c,%eax
  1008e0:	2d 36 00 10 00       	sub    $0x100036,%eax
  1008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f0:	85 c0                	test   %eax,%eax
  1008f2:	0f 48 c2             	cmovs  %edx,%eax
  1008f5:	c1 f8 0a             	sar    $0xa,%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	c7 04 24 30 63 10 00 	movl   $0x106330,(%esp)
  100903:	e8 4e fa ff ff       	call   100356 <cprintf>
}
  100908:	90                   	nop
  100909:	89 ec                	mov    %ebp,%esp
  10090b:	5d                   	pop    %ebp
  10090c:	c3                   	ret    

0010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10090d:	55                   	push   %ebp
  10090e:	89 e5                	mov    %esp,%ebp
  100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100919:	89 44 24 04          	mov    %eax,0x4(%esp)
  10091d:	8b 45 08             	mov    0x8(%ebp),%eax
  100920:	89 04 24             	mov    %eax,(%esp)
  100923:	e8 29 fc ff ff       	call   100551 <debuginfo_eip>
  100928:	85 c0                	test   %eax,%eax
  10092a:	74 15                	je     100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10092c:	8b 45 08             	mov    0x8(%ebp),%eax
  10092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100933:	c7 04 24 5a 63 10 00 	movl   $0x10635a,(%esp)
  10093a:	e8 17 fa ff ff       	call   100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10093f:	eb 6c                	jmp    1009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100948:	eb 1b                	jmp    100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  10094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100950:	01 d0                	add    %edx,%eax
  100952:	0f b6 10             	movzbl (%eax),%edx
  100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095e:	01 c8                	add    %ecx,%eax
  100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100962:	ff 45 f4             	incl   -0xc(%ebp)
  100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10096b:	7c dd                	jl     10094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
  10096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100976:	01 d0                	add    %edx,%eax
  100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  10097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10097e:	8b 45 08             	mov    0x8(%ebp),%eax
  100981:	29 d0                	sub    %edx,%eax
  100983:	89 c1                	mov    %eax,%ecx
  100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100999:	89 54 24 08          	mov    %edx,0x8(%esp)
  10099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a1:	c7 04 24 76 63 10 00 	movl   $0x106376,(%esp)
  1009a8:	e8 a9 f9 ff ff       	call   100356 <cprintf>
}
  1009ad:	90                   	nop
  1009ae:	89 ec                	mov    %ebp,%esp
  1009b0:	5d                   	pop    %ebp
  1009b1:	c3                   	ret    

001009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b2:	55                   	push   %ebp
  1009b3:	89 e5                	mov    %esp,%ebp
  1009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009b8:	8b 45 04             	mov    0x4(%ebp),%eax
  1009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c1:	89 ec                	mov    %ebp,%esp
  1009c3:	5d                   	pop    %ebp
  1009c4:	c3                   	ret    

001009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cb:	89 e8                	mov    %ebp,%eax
  1009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
  1009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
  1009d6:	e8 d7 ff ff ff       	call   1009b2 <read_eip>
  1009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i,j;
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
  1009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e5:	e9 a8 00 00 00       	jmp    100a92 <print_stackframe+0xcd>
      {
        cprintf("%08x",ebp);
  1009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f1:	c7 04 24 88 63 10 00 	movl   $0x106388,(%esp)
  1009f8:	e8 59 f9 ff ff       	call   100356 <cprintf>
        cprintf(" ");
  1009fd:	c7 04 24 8d 63 10 00 	movl   $0x10638d,(%esp)
  100a04:	e8 4d f9 ff ff       	call   100356 <cprintf>
        cprintf("%08x",eip);
  100a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a10:	c7 04 24 88 63 10 00 	movl   $0x106388,(%esp)
  100a17:	e8 3a f9 ff ff       	call   100356 <cprintf>
        uint32_t* a=(uint32_t*)ebp+2;
  100a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a1f:	83 c0 08             	add    $0x8,%eax
  100a22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j=0;j<4;j++)
  100a25:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a2c:	eb 30                	jmp    100a5e <print_stackframe+0x99>
        {
            cprintf(" ");
  100a2e:	c7 04 24 8d 63 10 00 	movl   $0x10638d,(%esp)
  100a35:	e8 1c f9 ff ff       	call   100356 <cprintf>
            cprintf("%08x",a[j]);
  100a3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a47:	01 d0                	add    %edx,%eax
  100a49:	8b 00                	mov    (%eax),%eax
  100a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a4f:	c7 04 24 88 63 10 00 	movl   $0x106388,(%esp)
  100a56:	e8 fb f8 ff ff       	call   100356 <cprintf>
        for(j=0;j<4;j++)
  100a5b:	ff 45 e8             	incl   -0x18(%ebp)
  100a5e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a62:	7e ca                	jle    100a2e <print_stackframe+0x69>
        }
        cprintf("\n");
  100a64:	c7 04 24 8f 63 10 00 	movl   $0x10638f,(%esp)
  100a6b:	e8 e6 f8 ff ff       	call   100356 <cprintf>

        print_debuginfo(eip-1);
  100a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a73:	48                   	dec    %eax
  100a74:	89 04 24             	mov    %eax,(%esp)
  100a77:	e8 91 fe ff ff       	call   10090d <print_debuginfo>

        eip=((uint32_t*)ebp)[1];
  100a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a7f:	83 c0 04             	add    $0x4,%eax
  100a82:	8b 00                	mov    (%eax),%eax
  100a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp=((uint32_t*)ebp)[0];
  100a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a8a:	8b 00                	mov    (%eax),%eax
  100a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
  100a8f:	ff 45 ec             	incl   -0x14(%ebp)
  100a92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a96:	74 0a                	je     100aa2 <print_stackframe+0xdd>
  100a98:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a9c:	0f 8e 48 ff ff ff    	jle    1009ea <print_stackframe+0x25>


      }
}
  100aa2:	90                   	nop
  100aa3:	89 ec                	mov    %ebp,%esp
  100aa5:	5d                   	pop    %ebp
  100aa6:	c3                   	ret    

00100aa7 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100aa7:	55                   	push   %ebp
  100aa8:	89 e5                	mov    %esp,%ebp
  100aaa:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100aad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100ab4:	eb 0c                	jmp    100ac2 <parse+0x1b>
            *buf ++ = '\0';
  100ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab9:	8d 50 01             	lea    0x1(%eax),%edx
  100abc:	89 55 08             	mov    %edx,0x8(%ebp)
  100abf:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac5:	0f b6 00             	movzbl (%eax),%eax
  100ac8:	84 c0                	test   %al,%al
  100aca:	74 1d                	je     100ae9 <parse+0x42>
  100acc:	8b 45 08             	mov    0x8(%ebp),%eax
  100acf:	0f b6 00             	movzbl (%eax),%eax
  100ad2:	0f be c0             	movsbl %al,%eax
  100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ad9:	c7 04 24 14 64 10 00 	movl   $0x106414,(%esp)
  100ae0:	e8 c3 53 00 00       	call   105ea8 <strchr>
  100ae5:	85 c0                	test   %eax,%eax
  100ae7:	75 cd                	jne    100ab6 <parse+0xf>
        }
        if (*buf == '\0') {
  100ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  100aec:	0f b6 00             	movzbl (%eax),%eax
  100aef:	84 c0                	test   %al,%al
  100af1:	74 65                	je     100b58 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100af3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100af7:	75 14                	jne    100b0d <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100af9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b00:	00 
  100b01:	c7 04 24 19 64 10 00 	movl   $0x106419,(%esp)
  100b08:	e8 49 f8 ff ff       	call   100356 <cprintf>
        }
        argv[argc ++] = buf;
  100b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b10:	8d 50 01             	lea    0x1(%eax),%edx
  100b13:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b20:	01 c2                	add    %eax,%edx
  100b22:	8b 45 08             	mov    0x8(%ebp),%eax
  100b25:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b27:	eb 03                	jmp    100b2c <parse+0x85>
            buf ++;
  100b29:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b2f:	0f b6 00             	movzbl (%eax),%eax
  100b32:	84 c0                	test   %al,%al
  100b34:	74 8c                	je     100ac2 <parse+0x1b>
  100b36:	8b 45 08             	mov    0x8(%ebp),%eax
  100b39:	0f b6 00             	movzbl (%eax),%eax
  100b3c:	0f be c0             	movsbl %al,%eax
  100b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b43:	c7 04 24 14 64 10 00 	movl   $0x106414,(%esp)
  100b4a:	e8 59 53 00 00       	call   105ea8 <strchr>
  100b4f:	85 c0                	test   %eax,%eax
  100b51:	74 d6                	je     100b29 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b53:	e9 6a ff ff ff       	jmp    100ac2 <parse+0x1b>
            break;
  100b58:	90                   	nop
        }
    }
    return argc;
  100b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b5c:	89 ec                	mov    %ebp,%esp
  100b5e:	5d                   	pop    %ebp
  100b5f:	c3                   	ret    

00100b60 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b60:	55                   	push   %ebp
  100b61:	89 e5                	mov    %esp,%ebp
  100b63:	83 ec 68             	sub    $0x68,%esp
  100b66:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b69:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b70:	8b 45 08             	mov    0x8(%ebp),%eax
  100b73:	89 04 24             	mov    %eax,(%esp)
  100b76:	e8 2c ff ff ff       	call   100aa7 <parse>
  100b7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b82:	75 0a                	jne    100b8e <runcmd+0x2e>
        return 0;
  100b84:	b8 00 00 00 00       	mov    $0x0,%eax
  100b89:	e9 83 00 00 00       	jmp    100c11 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b95:	eb 5a                	jmp    100bf1 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b97:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b9a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b9d:	89 c8                	mov    %ecx,%eax
  100b9f:	01 c0                	add    %eax,%eax
  100ba1:	01 c8                	add    %ecx,%eax
  100ba3:	c1 e0 02             	shl    $0x2,%eax
  100ba6:	05 00 90 11 00       	add    $0x119000,%eax
  100bab:	8b 00                	mov    (%eax),%eax
  100bad:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bb1:	89 04 24             	mov    %eax,(%esp)
  100bb4:	e8 53 52 00 00       	call   105e0c <strcmp>
  100bb9:	85 c0                	test   %eax,%eax
  100bbb:	75 31                	jne    100bee <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100bbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bc0:	89 d0                	mov    %edx,%eax
  100bc2:	01 c0                	add    %eax,%eax
  100bc4:	01 d0                	add    %edx,%eax
  100bc6:	c1 e0 02             	shl    $0x2,%eax
  100bc9:	05 08 90 11 00       	add    $0x119008,%eax
  100bce:	8b 10                	mov    (%eax),%edx
  100bd0:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bd3:	83 c0 04             	add    $0x4,%eax
  100bd6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100bd9:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be7:	89 1c 24             	mov    %ebx,(%esp)
  100bea:	ff d2                	call   *%edx
  100bec:	eb 23                	jmp    100c11 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bee:	ff 45 f4             	incl   -0xc(%ebp)
  100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bf4:	83 f8 02             	cmp    $0x2,%eax
  100bf7:	76 9e                	jbe    100b97 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bf9:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c00:	c7 04 24 37 64 10 00 	movl   $0x106437,(%esp)
  100c07:	e8 4a f7 ff ff       	call   100356 <cprintf>
    return 0;
  100c0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100c14:	89 ec                	mov    %ebp,%esp
  100c16:	5d                   	pop    %ebp
  100c17:	c3                   	ret    

00100c18 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c18:	55                   	push   %ebp
  100c19:	89 e5                	mov    %esp,%ebp
  100c1b:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c1e:	c7 04 24 50 64 10 00 	movl   $0x106450,(%esp)
  100c25:	e8 2c f7 ff ff       	call   100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c2a:	c7 04 24 78 64 10 00 	movl   $0x106478,(%esp)
  100c31:	e8 20 f7 ff ff       	call   100356 <cprintf>

    if (tf != NULL) {
  100c36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c3a:	74 0b                	je     100c47 <kmonitor+0x2f>
        print_trapframe(tf);
  100c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  100c3f:	89 04 24             	mov    %eax,(%esp)
  100c42:	e8 f1 0e 00 00       	call   101b38 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c47:	c7 04 24 9d 64 10 00 	movl   $0x10649d,(%esp)
  100c4e:	e8 f4 f5 ff ff       	call   100247 <readline>
  100c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c5a:	74 eb                	je     100c47 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  100c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c66:	89 04 24             	mov    %eax,(%esp)
  100c69:	e8 f2 fe ff ff       	call   100b60 <runcmd>
  100c6e:	85 c0                	test   %eax,%eax
  100c70:	78 02                	js     100c74 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c72:	eb d3                	jmp    100c47 <kmonitor+0x2f>
                break;
  100c74:	90                   	nop
            }
        }
    }
}
  100c75:	90                   	nop
  100c76:	89 ec                	mov    %ebp,%esp
  100c78:	5d                   	pop    %ebp
  100c79:	c3                   	ret    

00100c7a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c7a:	55                   	push   %ebp
  100c7b:	89 e5                	mov    %esp,%ebp
  100c7d:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c87:	eb 3d                	jmp    100cc6 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c8c:	89 d0                	mov    %edx,%eax
  100c8e:	01 c0                	add    %eax,%eax
  100c90:	01 d0                	add    %edx,%eax
  100c92:	c1 e0 02             	shl    $0x2,%eax
  100c95:	05 04 90 11 00       	add    $0x119004,%eax
  100c9a:	8b 10                	mov    (%eax),%edx
  100c9c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c9f:	89 c8                	mov    %ecx,%eax
  100ca1:	01 c0                	add    %eax,%eax
  100ca3:	01 c8                	add    %ecx,%eax
  100ca5:	c1 e0 02             	shl    $0x2,%eax
  100ca8:	05 00 90 11 00       	add    $0x119000,%eax
  100cad:	8b 00                	mov    (%eax),%eax
  100caf:	89 54 24 08          	mov    %edx,0x8(%esp)
  100cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cb7:	c7 04 24 a1 64 10 00 	movl   $0x1064a1,(%esp)
  100cbe:	e8 93 f6 ff ff       	call   100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cc3:	ff 45 f4             	incl   -0xc(%ebp)
  100cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cc9:	83 f8 02             	cmp    $0x2,%eax
  100ccc:	76 bb                	jbe    100c89 <mon_help+0xf>
    }
    return 0;
  100cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd3:	89 ec                	mov    %ebp,%esp
  100cd5:	5d                   	pop    %ebp
  100cd6:	c3                   	ret    

00100cd7 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cd7:	55                   	push   %ebp
  100cd8:	89 e5                	mov    %esp,%ebp
  100cda:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cdd:	e8 97 fb ff ff       	call   100879 <print_kerninfo>
    return 0;
  100ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ce7:	89 ec                	mov    %ebp,%esp
  100ce9:	5d                   	pop    %ebp
  100cea:	c3                   	ret    

00100ceb <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100ceb:	55                   	push   %ebp
  100cec:	89 e5                	mov    %esp,%ebp
  100cee:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cf1:	e8 cf fc ff ff       	call   1009c5 <print_stackframe>
    return 0;
  100cf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cfb:	89 ec                	mov    %ebp,%esp
  100cfd:	5d                   	pop    %ebp
  100cfe:	c3                   	ret    

00100cff <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cff:	55                   	push   %ebp
  100d00:	89 e5                	mov    %esp,%ebp
  100d02:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100d05:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100d0a:	85 c0                	test   %eax,%eax
  100d0c:	75 5b                	jne    100d69 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100d0e:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  100d15:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100d18:	8d 45 14             	lea    0x14(%ebp),%eax
  100d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d21:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d25:	8b 45 08             	mov    0x8(%ebp),%eax
  100d28:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d2c:	c7 04 24 aa 64 10 00 	movl   $0x1064aa,(%esp)
  100d33:	e8 1e f6 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d3f:	8b 45 10             	mov    0x10(%ebp),%eax
  100d42:	89 04 24             	mov    %eax,(%esp)
  100d45:	e8 d7 f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d4a:	c7 04 24 c6 64 10 00 	movl   $0x1064c6,(%esp)
  100d51:	e8 00 f6 ff ff       	call   100356 <cprintf>
    
    cprintf("stack trackback:\n");
  100d56:	c7 04 24 c8 64 10 00 	movl   $0x1064c8,(%esp)
  100d5d:	e8 f4 f5 ff ff       	call   100356 <cprintf>
    print_stackframe();
  100d62:	e8 5e fc ff ff       	call   1009c5 <print_stackframe>
  100d67:	eb 01                	jmp    100d6a <__panic+0x6b>
        goto panic_dead;
  100d69:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d6a:	e8 e9 09 00 00       	call   101758 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d76:	e8 9d fe ff ff       	call   100c18 <kmonitor>
  100d7b:	eb f2                	jmp    100d6f <__panic+0x70>

00100d7d <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d7d:	55                   	push   %ebp
  100d7e:	89 e5                	mov    %esp,%ebp
  100d80:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d83:	8d 45 14             	lea    0x14(%ebp),%eax
  100d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d89:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d90:	8b 45 08             	mov    0x8(%ebp),%eax
  100d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d97:	c7 04 24 da 64 10 00 	movl   $0x1064da,(%esp)
  100d9e:	e8 b3 f5 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100da6:	89 44 24 04          	mov    %eax,0x4(%esp)
  100daa:	8b 45 10             	mov    0x10(%ebp),%eax
  100dad:	89 04 24             	mov    %eax,(%esp)
  100db0:	e8 6c f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100db5:	c7 04 24 c6 64 10 00 	movl   $0x1064c6,(%esp)
  100dbc:	e8 95 f5 ff ff       	call   100356 <cprintf>
    va_end(ap);
}
  100dc1:	90                   	nop
  100dc2:	89 ec                	mov    %ebp,%esp
  100dc4:	5d                   	pop    %ebp
  100dc5:	c3                   	ret    

00100dc6 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100dc6:	55                   	push   %ebp
  100dc7:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100dc9:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  100dce:	5d                   	pop    %ebp
  100dcf:	c3                   	ret    

00100dd0 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dd0:	55                   	push   %ebp
  100dd1:	89 e5                	mov    %esp,%ebp
  100dd3:	83 ec 28             	sub    $0x28,%esp
  100dd6:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100ddc:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100de0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100de4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100de8:	ee                   	out    %al,(%dx)
}
  100de9:	90                   	nop
  100dea:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100df0:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100df4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100df8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dfc:	ee                   	out    %al,(%dx)
}
  100dfd:	90                   	nop
  100dfe:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100e04:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e08:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e0c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e10:	ee                   	out    %al,(%dx)
}
  100e11:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100e12:	c7 05 24 c4 11 00 00 	movl   $0x0,0x11c424
  100e19:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e1c:	c7 04 24 f8 64 10 00 	movl   $0x1064f8,(%esp)
  100e23:	e8 2e f5 ff ff       	call   100356 <cprintf>
    pic_enable(IRQ_TIMER);
  100e28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e2f:	e8 89 09 00 00       	call   1017bd <pic_enable>
}
  100e34:	90                   	nop
  100e35:	89 ec                	mov    %ebp,%esp
  100e37:	5d                   	pop    %ebp
  100e38:	c3                   	ret    

00100e39 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e39:	55                   	push   %ebp
  100e3a:	89 e5                	mov    %esp,%ebp
  100e3c:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e3f:	9c                   	pushf  
  100e40:	58                   	pop    %eax
  100e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e47:	25 00 02 00 00       	and    $0x200,%eax
  100e4c:	85 c0                	test   %eax,%eax
  100e4e:	74 0c                	je     100e5c <__intr_save+0x23>
        intr_disable();
  100e50:	e8 03 09 00 00       	call   101758 <intr_disable>
        return 1;
  100e55:	b8 01 00 00 00       	mov    $0x1,%eax
  100e5a:	eb 05                	jmp    100e61 <__intr_save+0x28>
    }
    return 0;
  100e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e61:	89 ec                	mov    %ebp,%esp
  100e63:	5d                   	pop    %ebp
  100e64:	c3                   	ret    

00100e65 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e65:	55                   	push   %ebp
  100e66:	89 e5                	mov    %esp,%ebp
  100e68:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e6f:	74 05                	je     100e76 <__intr_restore+0x11>
        intr_enable();
  100e71:	e8 da 08 00 00       	call   101750 <intr_enable>
    }
}
  100e76:	90                   	nop
  100e77:	89 ec                	mov    %ebp,%esp
  100e79:	5d                   	pop    %ebp
  100e7a:	c3                   	ret    

00100e7b <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e7b:	55                   	push   %ebp
  100e7c:	89 e5                	mov    %esp,%ebp
  100e7e:	83 ec 10             	sub    $0x10,%esp
  100e81:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e87:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e8b:	89 c2                	mov    %eax,%edx
  100e8d:	ec                   	in     (%dx),%al
  100e8e:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e91:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e97:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e9b:	89 c2                	mov    %eax,%edx
  100e9d:	ec                   	in     (%dx),%al
  100e9e:	88 45 f5             	mov    %al,-0xb(%ebp)
  100ea1:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100ea7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100eab:	89 c2                	mov    %eax,%edx
  100ead:	ec                   	in     (%dx),%al
  100eae:	88 45 f9             	mov    %al,-0x7(%ebp)
  100eb1:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100eb7:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100ebb:	89 c2                	mov    %eax,%edx
  100ebd:	ec                   	in     (%dx),%al
  100ebe:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100ec1:	90                   	nop
  100ec2:	89 ec                	mov    %ebp,%esp
  100ec4:	5d                   	pop    %ebp
  100ec5:	c3                   	ret    

00100ec6 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100ec6:	55                   	push   %ebp
  100ec7:	89 e5                	mov    %esp,%ebp
  100ec9:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100ecc:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ed6:	0f b7 00             	movzwl (%eax),%eax
  100ed9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100edd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee0:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee8:	0f b7 00             	movzwl (%eax),%eax
  100eeb:	0f b7 c0             	movzwl %ax,%eax
  100eee:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ef3:	74 12                	je     100f07 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ef5:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100efc:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100f03:	b4 03 
  100f05:	eb 13                	jmp    100f1a <cga_init+0x54>
    } else {
        *cp = was;
  100f07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f0a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100f0e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100f11:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100f18:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100f1a:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f21:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f25:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f29:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f2d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f31:	ee                   	out    %al,(%dx)
}
  100f32:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f33:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f3a:	40                   	inc    %eax
  100f3b:	0f b7 c0             	movzwl %ax,%eax
  100f3e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f42:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f46:	89 c2                	mov    %eax,%edx
  100f48:	ec                   	in     (%dx),%al
  100f49:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f4c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f50:	0f b6 c0             	movzbl %al,%eax
  100f53:	c1 e0 08             	shl    $0x8,%eax
  100f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f59:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f60:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f64:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f68:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f6c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f70:	ee                   	out    %al,(%dx)
}
  100f71:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f72:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f79:	40                   	inc    %eax
  100f7a:	0f b7 c0             	movzwl %ax,%eax
  100f7d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f81:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f85:	89 c2                	mov    %eax,%edx
  100f87:	ec                   	in     (%dx),%al
  100f88:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f8b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f8f:	0f b6 c0             	movzbl %al,%eax
  100f92:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f98:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100fa0:	0f b7 c0             	movzwl %ax,%eax
  100fa3:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100fa9:	90                   	nop
  100faa:	89 ec                	mov    %ebp,%esp
  100fac:	5d                   	pop    %ebp
  100fad:	c3                   	ret    

00100fae <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100fae:	55                   	push   %ebp
  100faf:	89 e5                	mov    %esp,%ebp
  100fb1:	83 ec 48             	sub    $0x48,%esp
  100fb4:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100fba:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fbe:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100fc2:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100fc6:	ee                   	out    %al,(%dx)
}
  100fc7:	90                   	nop
  100fc8:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100fce:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fd2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fd6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fda:	ee                   	out    %al,(%dx)
}
  100fdb:	90                   	nop
  100fdc:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fe2:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fe6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fea:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fee:	ee                   	out    %al,(%dx)
}
  100fef:	90                   	nop
  100ff0:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100ff6:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ffa:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ffe:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101002:	ee                   	out    %al,(%dx)
}
  101003:	90                   	nop
  101004:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  10100a:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10100e:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101012:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101016:	ee                   	out    %al,(%dx)
}
  101017:	90                   	nop
  101018:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  10101e:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101022:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101026:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10102a:	ee                   	out    %al,(%dx)
}
  10102b:	90                   	nop
  10102c:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  101032:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101036:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10103a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10103e:	ee                   	out    %al,(%dx)
}
  10103f:	90                   	nop
  101040:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101046:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  10104a:	89 c2                	mov    %eax,%edx
  10104c:	ec                   	in     (%dx),%al
  10104d:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101050:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101054:	3c ff                	cmp    $0xff,%al
  101056:	0f 95 c0             	setne  %al
  101059:	0f b6 c0             	movzbl %al,%eax
  10105c:	a3 48 c4 11 00       	mov    %eax,0x11c448
  101061:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101067:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10106b:	89 c2                	mov    %eax,%edx
  10106d:	ec                   	in     (%dx),%al
  10106e:	88 45 f1             	mov    %al,-0xf(%ebp)
  101071:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101077:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10107b:	89 c2                	mov    %eax,%edx
  10107d:	ec                   	in     (%dx),%al
  10107e:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101081:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101086:	85 c0                	test   %eax,%eax
  101088:	74 0c                	je     101096 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  10108a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101091:	e8 27 07 00 00       	call   1017bd <pic_enable>
    }
}
  101096:	90                   	nop
  101097:	89 ec                	mov    %ebp,%esp
  101099:	5d                   	pop    %ebp
  10109a:	c3                   	ret    

0010109b <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10109b:	55                   	push   %ebp
  10109c:	89 e5                	mov    %esp,%ebp
  10109e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1010a8:	eb 08                	jmp    1010b2 <lpt_putc_sub+0x17>
        delay();
  1010aa:	e8 cc fd ff ff       	call   100e7b <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010af:	ff 45 fc             	incl   -0x4(%ebp)
  1010b2:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  1010b8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1010bc:	89 c2                	mov    %eax,%edx
  1010be:	ec                   	in     (%dx),%al
  1010bf:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1010c2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1010c6:	84 c0                	test   %al,%al
  1010c8:	78 09                	js     1010d3 <lpt_putc_sub+0x38>
  1010ca:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010d1:	7e d7                	jle    1010aa <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  1010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d6:	0f b6 c0             	movzbl %al,%eax
  1010d9:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010df:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010e2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010e6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010ea:	ee                   	out    %al,(%dx)
}
  1010eb:	90                   	nop
  1010ec:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010f2:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010f6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010fa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010fe:	ee                   	out    %al,(%dx)
}
  1010ff:	90                   	nop
  101100:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101106:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10110a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10110e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101112:	ee                   	out    %al,(%dx)
}
  101113:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101114:	90                   	nop
  101115:	89 ec                	mov    %ebp,%esp
  101117:	5d                   	pop    %ebp
  101118:	c3                   	ret    

00101119 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101119:	55                   	push   %ebp
  10111a:	89 e5                	mov    %esp,%ebp
  10111c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10111f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101123:	74 0d                	je     101132 <lpt_putc+0x19>
        lpt_putc_sub(c);
  101125:	8b 45 08             	mov    0x8(%ebp),%eax
  101128:	89 04 24             	mov    %eax,(%esp)
  10112b:	e8 6b ff ff ff       	call   10109b <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101130:	eb 24                	jmp    101156 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  101132:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101139:	e8 5d ff ff ff       	call   10109b <lpt_putc_sub>
        lpt_putc_sub(' ');
  10113e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101145:	e8 51 ff ff ff       	call   10109b <lpt_putc_sub>
        lpt_putc_sub('\b');
  10114a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101151:	e8 45 ff ff ff       	call   10109b <lpt_putc_sub>
}
  101156:	90                   	nop
  101157:	89 ec                	mov    %ebp,%esp
  101159:	5d                   	pop    %ebp
  10115a:	c3                   	ret    

0010115b <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10115b:	55                   	push   %ebp
  10115c:	89 e5                	mov    %esp,%ebp
  10115e:	83 ec 38             	sub    $0x38,%esp
  101161:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  101164:	8b 45 08             	mov    0x8(%ebp),%eax
  101167:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10116c:	85 c0                	test   %eax,%eax
  10116e:	75 07                	jne    101177 <cga_putc+0x1c>
        c |= 0x0700;
  101170:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101177:	8b 45 08             	mov    0x8(%ebp),%eax
  10117a:	0f b6 c0             	movzbl %al,%eax
  10117d:	83 f8 0d             	cmp    $0xd,%eax
  101180:	74 72                	je     1011f4 <cga_putc+0x99>
  101182:	83 f8 0d             	cmp    $0xd,%eax
  101185:	0f 8f a3 00 00 00    	jg     10122e <cga_putc+0xd3>
  10118b:	83 f8 08             	cmp    $0x8,%eax
  10118e:	74 0a                	je     10119a <cga_putc+0x3f>
  101190:	83 f8 0a             	cmp    $0xa,%eax
  101193:	74 4c                	je     1011e1 <cga_putc+0x86>
  101195:	e9 94 00 00 00       	jmp    10122e <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  10119a:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011a1:	85 c0                	test   %eax,%eax
  1011a3:	0f 84 af 00 00 00    	je     101258 <cga_putc+0xfd>
            crt_pos --;
  1011a9:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011b0:	48                   	dec    %eax
  1011b1:	0f b7 c0             	movzwl %ax,%eax
  1011b4:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1011ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1011bd:	98                   	cwtl   
  1011be:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1011c3:	98                   	cwtl   
  1011c4:	83 c8 20             	or     $0x20,%eax
  1011c7:	98                   	cwtl   
  1011c8:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  1011ce:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  1011d5:	01 d2                	add    %edx,%edx
  1011d7:	01 ca                	add    %ecx,%edx
  1011d9:	0f b7 c0             	movzwl %ax,%eax
  1011dc:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011df:	eb 77                	jmp    101258 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011e1:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011e8:	83 c0 50             	add    $0x50,%eax
  1011eb:	0f b7 c0             	movzwl %ax,%eax
  1011ee:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011f4:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  1011fb:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  101202:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101207:	89 c8                	mov    %ecx,%eax
  101209:	f7 e2                	mul    %edx
  10120b:	c1 ea 06             	shr    $0x6,%edx
  10120e:	89 d0                	mov    %edx,%eax
  101210:	c1 e0 02             	shl    $0x2,%eax
  101213:	01 d0                	add    %edx,%eax
  101215:	c1 e0 04             	shl    $0x4,%eax
  101218:	29 c1                	sub    %eax,%ecx
  10121a:	89 ca                	mov    %ecx,%edx
  10121c:	0f b7 d2             	movzwl %dx,%edx
  10121f:	89 d8                	mov    %ebx,%eax
  101221:	29 d0                	sub    %edx,%eax
  101223:	0f b7 c0             	movzwl %ax,%eax
  101226:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  10122c:	eb 2b                	jmp    101259 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10122e:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  101234:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10123b:	8d 50 01             	lea    0x1(%eax),%edx
  10123e:	0f b7 d2             	movzwl %dx,%edx
  101241:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  101248:	01 c0                	add    %eax,%eax
  10124a:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10124d:	8b 45 08             	mov    0x8(%ebp),%eax
  101250:	0f b7 c0             	movzwl %ax,%eax
  101253:	66 89 02             	mov    %ax,(%edx)
        break;
  101256:	eb 01                	jmp    101259 <cga_putc+0xfe>
        break;
  101258:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101259:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101260:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101265:	76 5e                	jbe    1012c5 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101267:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10126c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101272:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101277:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10127e:	00 
  10127f:	89 54 24 04          	mov    %edx,0x4(%esp)
  101283:	89 04 24             	mov    %eax,(%esp)
  101286:	e8 1b 4e 00 00       	call   1060a6 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10128b:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101292:	eb 15                	jmp    1012a9 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  101294:	8b 15 40 c4 11 00    	mov    0x11c440,%edx
  10129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10129d:	01 c0                	add    %eax,%eax
  10129f:	01 d0                	add    %edx,%eax
  1012a1:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012a6:	ff 45 f4             	incl   -0xc(%ebp)
  1012a9:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1012b0:	7e e2                	jle    101294 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  1012b2:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012b9:	83 e8 50             	sub    $0x50,%eax
  1012bc:	0f b7 c0             	movzwl %ax,%eax
  1012bf:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1012c5:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012cc:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012d0:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012d4:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012d8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012dc:	ee                   	out    %al,(%dx)
}
  1012dd:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012de:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012e5:	c1 e8 08             	shr    $0x8,%eax
  1012e8:	0f b7 c0             	movzwl %ax,%eax
  1012eb:	0f b6 c0             	movzbl %al,%eax
  1012ee:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  1012f5:	42                   	inc    %edx
  1012f6:	0f b7 d2             	movzwl %dx,%edx
  1012f9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012fd:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101300:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101304:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101308:	ee                   	out    %al,(%dx)
}
  101309:	90                   	nop
    outb(addr_6845, 15);
  10130a:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  101311:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101315:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101319:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10131d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101321:	ee                   	out    %al,(%dx)
}
  101322:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  101323:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10132a:	0f b6 c0             	movzbl %al,%eax
  10132d:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  101334:	42                   	inc    %edx
  101335:	0f b7 d2             	movzwl %dx,%edx
  101338:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  10133c:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10133f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101343:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101347:	ee                   	out    %al,(%dx)
}
  101348:	90                   	nop
}
  101349:	90                   	nop
  10134a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10134d:	89 ec                	mov    %ebp,%esp
  10134f:	5d                   	pop    %ebp
  101350:	c3                   	ret    

00101351 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101351:	55                   	push   %ebp
  101352:	89 e5                	mov    %esp,%ebp
  101354:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101357:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10135e:	eb 08                	jmp    101368 <serial_putc_sub+0x17>
        delay();
  101360:	e8 16 fb ff ff       	call   100e7b <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101365:	ff 45 fc             	incl   -0x4(%ebp)
  101368:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10136e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101372:	89 c2                	mov    %eax,%edx
  101374:	ec                   	in     (%dx),%al
  101375:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101378:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10137c:	0f b6 c0             	movzbl %al,%eax
  10137f:	83 e0 20             	and    $0x20,%eax
  101382:	85 c0                	test   %eax,%eax
  101384:	75 09                	jne    10138f <serial_putc_sub+0x3e>
  101386:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10138d:	7e d1                	jle    101360 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  10138f:	8b 45 08             	mov    0x8(%ebp),%eax
  101392:	0f b6 c0             	movzbl %al,%eax
  101395:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10139b:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10139e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1013a2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1013a6:	ee                   	out    %al,(%dx)
}
  1013a7:	90                   	nop
}
  1013a8:	90                   	nop
  1013a9:	89 ec                	mov    %ebp,%esp
  1013ab:	5d                   	pop    %ebp
  1013ac:	c3                   	ret    

001013ad <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1013ad:	55                   	push   %ebp
  1013ae:	89 e5                	mov    %esp,%ebp
  1013b0:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1013b3:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1013b7:	74 0d                	je     1013c6 <serial_putc+0x19>
        serial_putc_sub(c);
  1013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1013bc:	89 04 24             	mov    %eax,(%esp)
  1013bf:	e8 8d ff ff ff       	call   101351 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1013c4:	eb 24                	jmp    1013ea <serial_putc+0x3d>
        serial_putc_sub('\b');
  1013c6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013cd:	e8 7f ff ff ff       	call   101351 <serial_putc_sub>
        serial_putc_sub(' ');
  1013d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013d9:	e8 73 ff ff ff       	call   101351 <serial_putc_sub>
        serial_putc_sub('\b');
  1013de:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013e5:	e8 67 ff ff ff       	call   101351 <serial_putc_sub>
}
  1013ea:	90                   	nop
  1013eb:	89 ec                	mov    %ebp,%esp
  1013ed:	5d                   	pop    %ebp
  1013ee:	c3                   	ret    

001013ef <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013ef:	55                   	push   %ebp
  1013f0:	89 e5                	mov    %esp,%ebp
  1013f2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013f5:	eb 33                	jmp    10142a <cons_intr+0x3b>
        if (c != 0) {
  1013f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013fb:	74 2d                	je     10142a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013fd:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101402:	8d 50 01             	lea    0x1(%eax),%edx
  101405:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  10140b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10140e:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101414:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101419:	3d 00 02 00 00       	cmp    $0x200,%eax
  10141e:	75 0a                	jne    10142a <cons_intr+0x3b>
                cons.wpos = 0;
  101420:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  101427:	00 00 00 
    while ((c = (*proc)()) != -1) {
  10142a:	8b 45 08             	mov    0x8(%ebp),%eax
  10142d:	ff d0                	call   *%eax
  10142f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101432:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101436:	75 bf                	jne    1013f7 <cons_intr+0x8>
            }
        }
    }
}
  101438:	90                   	nop
  101439:	90                   	nop
  10143a:	89 ec                	mov    %ebp,%esp
  10143c:	5d                   	pop    %ebp
  10143d:	c3                   	ret    

0010143e <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10143e:	55                   	push   %ebp
  10143f:	89 e5                	mov    %esp,%ebp
  101441:	83 ec 10             	sub    $0x10,%esp
  101444:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10144a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10144e:	89 c2                	mov    %eax,%edx
  101450:	ec                   	in     (%dx),%al
  101451:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101454:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101458:	0f b6 c0             	movzbl %al,%eax
  10145b:	83 e0 01             	and    $0x1,%eax
  10145e:	85 c0                	test   %eax,%eax
  101460:	75 07                	jne    101469 <serial_proc_data+0x2b>
        return -1;
  101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101467:	eb 2a                	jmp    101493 <serial_proc_data+0x55>
  101469:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10146f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101473:	89 c2                	mov    %eax,%edx
  101475:	ec                   	in     (%dx),%al
  101476:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101479:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10147d:	0f b6 c0             	movzbl %al,%eax
  101480:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101483:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101487:	75 07                	jne    101490 <serial_proc_data+0x52>
        c = '\b';
  101489:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101490:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101493:	89 ec                	mov    %ebp,%esp
  101495:	5d                   	pop    %ebp
  101496:	c3                   	ret    

00101497 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101497:	55                   	push   %ebp
  101498:	89 e5                	mov    %esp,%ebp
  10149a:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10149d:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1014a2:	85 c0                	test   %eax,%eax
  1014a4:	74 0c                	je     1014b2 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1014a6:	c7 04 24 3e 14 10 00 	movl   $0x10143e,(%esp)
  1014ad:	e8 3d ff ff ff       	call   1013ef <cons_intr>
    }
}
  1014b2:	90                   	nop
  1014b3:	89 ec                	mov    %ebp,%esp
  1014b5:	5d                   	pop    %ebp
  1014b6:	c3                   	ret    

001014b7 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1014b7:	55                   	push   %ebp
  1014b8:	89 e5                	mov    %esp,%ebp
  1014ba:	83 ec 38             	sub    $0x38,%esp
  1014bd:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014c6:	89 c2                	mov    %eax,%edx
  1014c8:	ec                   	in     (%dx),%al
  1014c9:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014d0:	0f b6 c0             	movzbl %al,%eax
  1014d3:	83 e0 01             	and    $0x1,%eax
  1014d6:	85 c0                	test   %eax,%eax
  1014d8:	75 0a                	jne    1014e4 <kbd_proc_data+0x2d>
        return -1;
  1014da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014df:	e9 56 01 00 00       	jmp    10163a <kbd_proc_data+0x183>
  1014e4:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014ed:	89 c2                	mov    %eax,%edx
  1014ef:	ec                   	in     (%dx),%al
  1014f0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014f3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014f7:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014fa:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014fe:	75 17                	jne    101517 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101500:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101505:	83 c8 40             	or     $0x40,%eax
  101508:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  10150d:	b8 00 00 00 00       	mov    $0x0,%eax
  101512:	e9 23 01 00 00       	jmp    10163a <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  101517:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151b:	84 c0                	test   %al,%al
  10151d:	79 45                	jns    101564 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10151f:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101524:	83 e0 40             	and    $0x40,%eax
  101527:	85 c0                	test   %eax,%eax
  101529:	75 08                	jne    101533 <kbd_proc_data+0x7c>
  10152b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10152f:	24 7f                	and    $0x7f,%al
  101531:	eb 04                	jmp    101537 <kbd_proc_data+0x80>
  101533:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101537:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  10153a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10153e:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101545:	0c 40                	or     $0x40,%al
  101547:	0f b6 c0             	movzbl %al,%eax
  10154a:	f7 d0                	not    %eax
  10154c:	89 c2                	mov    %eax,%edx
  10154e:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101553:	21 d0                	and    %edx,%eax
  101555:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  10155a:	b8 00 00 00 00       	mov    $0x0,%eax
  10155f:	e9 d6 00 00 00       	jmp    10163a <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101564:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101569:	83 e0 40             	and    $0x40,%eax
  10156c:	85 c0                	test   %eax,%eax
  10156e:	74 11                	je     101581 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101570:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101574:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101579:	83 e0 bf             	and    $0xffffffbf,%eax
  10157c:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  101581:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101585:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  10158c:	0f b6 d0             	movzbl %al,%edx
  10158f:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101594:	09 d0                	or     %edx,%eax
  101596:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  10159b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10159f:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  1015a6:	0f b6 d0             	movzbl %al,%edx
  1015a9:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015ae:	31 d0                	xor    %edx,%eax
  1015b0:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  1015b5:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015ba:	83 e0 03             	and    $0x3,%eax
  1015bd:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  1015c4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015c8:	01 d0                	add    %edx,%eax
  1015ca:	0f b6 00             	movzbl (%eax),%eax
  1015cd:	0f b6 c0             	movzbl %al,%eax
  1015d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015d3:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015d8:	83 e0 08             	and    $0x8,%eax
  1015db:	85 c0                	test   %eax,%eax
  1015dd:	74 22                	je     101601 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1015df:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015e3:	7e 0c                	jle    1015f1 <kbd_proc_data+0x13a>
  1015e5:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015e9:	7f 06                	jg     1015f1 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  1015eb:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015ef:	eb 10                	jmp    101601 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  1015f1:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015f5:	7e 0a                	jle    101601 <kbd_proc_data+0x14a>
  1015f7:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015fb:	7f 04                	jg     101601 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  1015fd:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101601:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101606:	f7 d0                	not    %eax
  101608:	83 e0 06             	and    $0x6,%eax
  10160b:	85 c0                	test   %eax,%eax
  10160d:	75 28                	jne    101637 <kbd_proc_data+0x180>
  10160f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101616:	75 1f                	jne    101637 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  101618:	c7 04 24 13 65 10 00 	movl   $0x106513,(%esp)
  10161f:	e8 32 ed ff ff       	call   100356 <cprintf>
  101624:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  10162a:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10162e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101632:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101635:	ee                   	out    %al,(%dx)
}
  101636:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101637:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10163a:	89 ec                	mov    %ebp,%esp
  10163c:	5d                   	pop    %ebp
  10163d:	c3                   	ret    

0010163e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10163e:	55                   	push   %ebp
  10163f:	89 e5                	mov    %esp,%ebp
  101641:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101644:	c7 04 24 b7 14 10 00 	movl   $0x1014b7,(%esp)
  10164b:	e8 9f fd ff ff       	call   1013ef <cons_intr>
}
  101650:	90                   	nop
  101651:	89 ec                	mov    %ebp,%esp
  101653:	5d                   	pop    %ebp
  101654:	c3                   	ret    

00101655 <kbd_init>:

static void
kbd_init(void) {
  101655:	55                   	push   %ebp
  101656:	89 e5                	mov    %esp,%ebp
  101658:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10165b:	e8 de ff ff ff       	call   10163e <kbd_intr>
    pic_enable(IRQ_KBD);
  101660:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101667:	e8 51 01 00 00       	call   1017bd <pic_enable>
}
  10166c:	90                   	nop
  10166d:	89 ec                	mov    %ebp,%esp
  10166f:	5d                   	pop    %ebp
  101670:	c3                   	ret    

00101671 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101671:	55                   	push   %ebp
  101672:	89 e5                	mov    %esp,%ebp
  101674:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101677:	e8 4a f8 ff ff       	call   100ec6 <cga_init>
    serial_init();
  10167c:	e8 2d f9 ff ff       	call   100fae <serial_init>
    kbd_init();
  101681:	e8 cf ff ff ff       	call   101655 <kbd_init>
    if (!serial_exists) {
  101686:	a1 48 c4 11 00       	mov    0x11c448,%eax
  10168b:	85 c0                	test   %eax,%eax
  10168d:	75 0c                	jne    10169b <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10168f:	c7 04 24 1f 65 10 00 	movl   $0x10651f,(%esp)
  101696:	e8 bb ec ff ff       	call   100356 <cprintf>
    }
}
  10169b:	90                   	nop
  10169c:	89 ec                	mov    %ebp,%esp
  10169e:	5d                   	pop    %ebp
  10169f:	c3                   	ret    

001016a0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1016a0:	55                   	push   %ebp
  1016a1:	89 e5                	mov    %esp,%ebp
  1016a3:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  1016a6:	e8 8e f7 ff ff       	call   100e39 <__intr_save>
  1016ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  1016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1016b1:	89 04 24             	mov    %eax,(%esp)
  1016b4:	e8 60 fa ff ff       	call   101119 <lpt_putc>
        cga_putc(c);
  1016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1016bc:	89 04 24             	mov    %eax,(%esp)
  1016bf:	e8 97 fa ff ff       	call   10115b <cga_putc>
        serial_putc(c);
  1016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1016c7:	89 04 24             	mov    %eax,(%esp)
  1016ca:	e8 de fc ff ff       	call   1013ad <serial_putc>
    }
    local_intr_restore(intr_flag);
  1016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016d2:	89 04 24             	mov    %eax,(%esp)
  1016d5:	e8 8b f7 ff ff       	call   100e65 <__intr_restore>
}
  1016da:	90                   	nop
  1016db:	89 ec                	mov    %ebp,%esp
  1016dd:	5d                   	pop    %ebp
  1016de:	c3                   	ret    

001016df <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016df:	55                   	push   %ebp
  1016e0:	89 e5                	mov    %esp,%ebp
  1016e2:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  1016e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1016ec:	e8 48 f7 ff ff       	call   100e39 <__intr_save>
  1016f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1016f4:	e8 9e fd ff ff       	call   101497 <serial_intr>
        kbd_intr();
  1016f9:	e8 40 ff ff ff       	call   10163e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1016fe:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  101704:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101709:	39 c2                	cmp    %eax,%edx
  10170b:	74 31                	je     10173e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10170d:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101712:	8d 50 01             	lea    0x1(%eax),%edx
  101715:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  10171b:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  101722:	0f b6 c0             	movzbl %al,%eax
  101725:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101728:	a1 60 c6 11 00       	mov    0x11c660,%eax
  10172d:	3d 00 02 00 00       	cmp    $0x200,%eax
  101732:	75 0a                	jne    10173e <cons_getc+0x5f>
                cons.rpos = 0;
  101734:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  10173b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101741:	89 04 24             	mov    %eax,(%esp)
  101744:	e8 1c f7 ff ff       	call   100e65 <__intr_restore>
    return c;
  101749:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10174c:	89 ec                	mov    %ebp,%esp
  10174e:	5d                   	pop    %ebp
  10174f:	c3                   	ret    

00101750 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101750:	55                   	push   %ebp
  101751:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101753:	fb                   	sti    
}
  101754:	90                   	nop
    sti();
}
  101755:	90                   	nop
  101756:	5d                   	pop    %ebp
  101757:	c3                   	ret    

00101758 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101758:	55                   	push   %ebp
  101759:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  10175b:	fa                   	cli    
}
  10175c:	90                   	nop
    cli();
}
  10175d:	90                   	nop
  10175e:	5d                   	pop    %ebp
  10175f:	c3                   	ret    

00101760 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101760:	55                   	push   %ebp
  101761:	89 e5                	mov    %esp,%ebp
  101763:	83 ec 14             	sub    $0x14,%esp
  101766:	8b 45 08             	mov    0x8(%ebp),%eax
  101769:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10176d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101770:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  101776:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  10177b:	85 c0                	test   %eax,%eax
  10177d:	74 39                	je     1017b8 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  10177f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101782:	0f b6 c0             	movzbl %al,%eax
  101785:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  10178b:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10178e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101792:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101796:	ee                   	out    %al,(%dx)
}
  101797:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  101798:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10179c:	c1 e8 08             	shr    $0x8,%eax
  10179f:	0f b7 c0             	movzwl %ax,%eax
  1017a2:	0f b6 c0             	movzbl %al,%eax
  1017a5:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  1017ab:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017ae:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1017b2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1017b6:	ee                   	out    %al,(%dx)
}
  1017b7:	90                   	nop
    }
}
  1017b8:	90                   	nop
  1017b9:	89 ec                	mov    %ebp,%esp
  1017bb:	5d                   	pop    %ebp
  1017bc:	c3                   	ret    

001017bd <pic_enable>:

void
pic_enable(unsigned int irq) {
  1017bd:	55                   	push   %ebp
  1017be:	89 e5                	mov    %esp,%ebp
  1017c0:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1017c6:	ba 01 00 00 00       	mov    $0x1,%edx
  1017cb:	88 c1                	mov    %al,%cl
  1017cd:	d3 e2                	shl    %cl,%edx
  1017cf:	89 d0                	mov    %edx,%eax
  1017d1:	98                   	cwtl   
  1017d2:	f7 d0                	not    %eax
  1017d4:	0f bf d0             	movswl %ax,%edx
  1017d7:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  1017de:	98                   	cwtl   
  1017df:	21 d0                	and    %edx,%eax
  1017e1:	98                   	cwtl   
  1017e2:	0f b7 c0             	movzwl %ax,%eax
  1017e5:	89 04 24             	mov    %eax,(%esp)
  1017e8:	e8 73 ff ff ff       	call   101760 <pic_setmask>
}
  1017ed:	90                   	nop
  1017ee:	89 ec                	mov    %ebp,%esp
  1017f0:	5d                   	pop    %ebp
  1017f1:	c3                   	ret    

001017f2 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017f2:	55                   	push   %ebp
  1017f3:	89 e5                	mov    %esp,%ebp
  1017f5:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1017f8:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  1017ff:	00 00 00 
  101802:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101808:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10180c:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101810:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101814:	ee                   	out    %al,(%dx)
}
  101815:	90                   	nop
  101816:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  10181c:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101820:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101824:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101828:	ee                   	out    %al,(%dx)
}
  101829:	90                   	nop
  10182a:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101830:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101834:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101838:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10183c:	ee                   	out    %al,(%dx)
}
  10183d:	90                   	nop
  10183e:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101844:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101848:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10184c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101850:	ee                   	out    %al,(%dx)
}
  101851:	90                   	nop
  101852:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101858:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10185c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101860:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101864:	ee                   	out    %al,(%dx)
}
  101865:	90                   	nop
  101866:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  10186c:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101870:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101874:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101878:	ee                   	out    %al,(%dx)
}
  101879:	90                   	nop
  10187a:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101880:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101884:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101888:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10188c:	ee                   	out    %al,(%dx)
}
  10188d:	90                   	nop
  10188e:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101894:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101898:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10189c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1018a0:	ee                   	out    %al,(%dx)
}
  1018a1:	90                   	nop
  1018a2:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  1018a8:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018ac:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1018b0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1018b4:	ee                   	out    %al,(%dx)
}
  1018b5:	90                   	nop
  1018b6:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1018bc:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018c0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1018c4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1018c8:	ee                   	out    %al,(%dx)
}
  1018c9:	90                   	nop
  1018ca:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1018d0:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018d4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1018d8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1018dc:	ee                   	out    %al,(%dx)
}
  1018dd:	90                   	nop
  1018de:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1018e4:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018e8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018ec:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018f0:	ee                   	out    %al,(%dx)
}
  1018f1:	90                   	nop
  1018f2:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018f8:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101900:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101904:	ee                   	out    %al,(%dx)
}
  101905:	90                   	nop
  101906:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  10190c:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101910:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101914:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101918:	ee                   	out    %al,(%dx)
}
  101919:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10191a:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101921:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101926:	74 0f                	je     101937 <pic_init+0x145>
        pic_setmask(irq_mask);
  101928:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  10192f:	89 04 24             	mov    %eax,(%esp)
  101932:	e8 29 fe ff ff       	call   101760 <pic_setmask>
    }
}
  101937:	90                   	nop
  101938:	89 ec                	mov    %ebp,%esp
  10193a:	5d                   	pop    %ebp
  10193b:	c3                   	ret    

0010193c <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10193c:	55                   	push   %ebp
  10193d:	89 e5                	mov    %esp,%ebp
  10193f:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101942:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101949:	00 
  10194a:	c7 04 24 40 65 10 00 	movl   $0x106540,(%esp)
  101951:	e8 00 ea ff ff       	call   100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101956:	c7 04 24 4a 65 10 00 	movl   $0x10654a,(%esp)
  10195d:	e8 f4 e9 ff ff       	call   100356 <cprintf>
    panic("EOT: kernel seems ok.");
  101962:	c7 44 24 08 58 65 10 	movl   $0x106558,0x8(%esp)
  101969:	00 
  10196a:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  101971:	00 
  101972:	c7 04 24 6e 65 10 00 	movl   $0x10656e,(%esp)
  101979:	e8 81 f3 ff ff       	call   100cff <__panic>

0010197e <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10197e:	55                   	push   %ebp
  10197f:	89 e5                	mov    %esp,%ebp
  101981:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */

     extern uintptr_t __vectors[];
     int i;
     for(i=0;i<256;i++)
  101984:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10198b:	e9 c4 00 00 00       	jmp    101a54 <idt_init+0xd6>
     {
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
  101990:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101993:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  10199a:	0f b7 d0             	movzwl %ax,%edx
  10199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a0:	66 89 14 c5 80 c6 11 	mov    %dx,0x11c680(,%eax,8)
  1019a7:	00 
  1019a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ab:	66 c7 04 c5 82 c6 11 	movw   $0x8,0x11c682(,%eax,8)
  1019b2:	00 08 00 
  1019b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b8:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  1019bf:	00 
  1019c0:	80 e2 e0             	and    $0xe0,%dl
  1019c3:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  1019ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019cd:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  1019d4:	00 
  1019d5:	80 e2 1f             	and    $0x1f,%dl
  1019d8:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  1019df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019e2:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  1019e9:	00 
  1019ea:	80 e2 f0             	and    $0xf0,%dl
  1019ed:	80 ca 0e             	or     $0xe,%dl
  1019f0:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  1019f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019fa:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a01:	00 
  101a02:	80 e2 ef             	and    $0xef,%dl
  101a05:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a0f:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a16:	00 
  101a17:	80 e2 9f             	and    $0x9f,%dl
  101a1a:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a24:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a2b:	00 
  101a2c:	80 ca 80             	or     $0x80,%dl
  101a2f:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a39:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101a40:	c1 e8 10             	shr    $0x10,%eax
  101a43:	0f b7 d0             	movzwl %ax,%edx
  101a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a49:	66 89 14 c5 86 c6 11 	mov    %dx,0x11c686(,%eax,8)
  101a50:	00 
     for(i=0;i<256;i++)
  101a51:	ff 45 fc             	incl   -0x4(%ebp)
  101a54:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101a5b:	0f 8e 2f ff ff ff    	jle    101990 <idt_init+0x12>
     }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], 3);
  101a61:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101a66:	0f b7 c0             	movzwl %ax,%eax
  101a69:	66 a3 48 ca 11 00    	mov    %ax,0x11ca48
  101a6f:	66 c7 05 4a ca 11 00 	movw   $0x8,0x11ca4a
  101a76:	08 00 
  101a78:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  101a7f:	24 e0                	and    $0xe0,%al
  101a81:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  101a86:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  101a8d:	24 1f                	and    $0x1f,%al
  101a8f:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  101a94:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a9b:	24 f0                	and    $0xf0,%al
  101a9d:	0c 0e                	or     $0xe,%al
  101a9f:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101aa4:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101aab:	24 ef                	and    $0xef,%al
  101aad:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101ab2:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101ab9:	0c 60                	or     $0x60,%al
  101abb:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101ac0:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101ac7:	0c 80                	or     $0x80,%al
  101ac9:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101ace:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101ad3:	c1 e8 10             	shr    $0x10,%eax
  101ad6:	0f b7 c0             	movzwl %ax,%eax
  101ad9:	66 a3 4e ca 11 00    	mov    %ax,0x11ca4e
  101adf:	c7 45 f8 60 95 11 00 	movl   $0x119560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101ae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101ae9:	0f 01 18             	lidtl  (%eax)
}
  101aec:	90                   	nop





}
  101aed:	90                   	nop
  101aee:	89 ec                	mov    %ebp,%esp
  101af0:	5d                   	pop    %ebp
  101af1:	c3                   	ret    

00101af2 <trapname>:

static const char *
trapname(int trapno) {
  101af2:	55                   	push   %ebp
  101af3:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101af5:	8b 45 08             	mov    0x8(%ebp),%eax
  101af8:	83 f8 13             	cmp    $0x13,%eax
  101afb:	77 0c                	ja     101b09 <trapname+0x17>
        return excnames[trapno];
  101afd:	8b 45 08             	mov    0x8(%ebp),%eax
  101b00:	8b 04 85 c0 68 10 00 	mov    0x1068c0(,%eax,4),%eax
  101b07:	eb 18                	jmp    101b21 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101b09:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101b0d:	7e 0d                	jle    101b1c <trapname+0x2a>
  101b0f:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101b13:	7f 07                	jg     101b1c <trapname+0x2a>
        return "Hardware Interrupt";
  101b15:	b8 7f 65 10 00       	mov    $0x10657f,%eax
  101b1a:	eb 05                	jmp    101b21 <trapname+0x2f>
    }
    return "(unknown trap)";
  101b1c:	b8 92 65 10 00       	mov    $0x106592,%eax
}
  101b21:	5d                   	pop    %ebp
  101b22:	c3                   	ret    

00101b23 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b23:	55                   	push   %ebp
  101b24:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b26:	8b 45 08             	mov    0x8(%ebp),%eax
  101b29:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b2d:	83 f8 08             	cmp    $0x8,%eax
  101b30:	0f 94 c0             	sete   %al
  101b33:	0f b6 c0             	movzbl %al,%eax
}
  101b36:	5d                   	pop    %ebp
  101b37:	c3                   	ret    

00101b38 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b38:	55                   	push   %ebp
  101b39:	89 e5                	mov    %esp,%ebp
  101b3b:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b45:	c7 04 24 d3 65 10 00 	movl   $0x1065d3,(%esp)
  101b4c:	e8 05 e8 ff ff       	call   100356 <cprintf>
    print_regs(&tf->tf_regs);
  101b51:	8b 45 08             	mov    0x8(%ebp),%eax
  101b54:	89 04 24             	mov    %eax,(%esp)
  101b57:	e8 8f 01 00 00       	call   101ceb <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5f:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b67:	c7 04 24 e4 65 10 00 	movl   $0x1065e4,(%esp)
  101b6e:	e8 e3 e7 ff ff       	call   100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b73:	8b 45 08             	mov    0x8(%ebp),%eax
  101b76:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7e:	c7 04 24 f7 65 10 00 	movl   $0x1065f7,(%esp)
  101b85:	e8 cc e7 ff ff       	call   100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b95:	c7 04 24 0a 66 10 00 	movl   $0x10660a,(%esp)
  101b9c:	e8 b5 e7 ff ff       	call   100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba4:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bac:	c7 04 24 1d 66 10 00 	movl   $0x10661d,(%esp)
  101bb3:	e8 9e e7 ff ff       	call   100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbb:	8b 40 30             	mov    0x30(%eax),%eax
  101bbe:	89 04 24             	mov    %eax,(%esp)
  101bc1:	e8 2c ff ff ff       	call   101af2 <trapname>
  101bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  101bc9:	8b 52 30             	mov    0x30(%edx),%edx
  101bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
  101bd0:	89 54 24 04          	mov    %edx,0x4(%esp)
  101bd4:	c7 04 24 30 66 10 00 	movl   $0x106630,(%esp)
  101bdb:	e8 76 e7 ff ff       	call   100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101be0:	8b 45 08             	mov    0x8(%ebp),%eax
  101be3:	8b 40 34             	mov    0x34(%eax),%eax
  101be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bea:	c7 04 24 42 66 10 00 	movl   $0x106642,(%esp)
  101bf1:	e8 60 e7 ff ff       	call   100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf9:	8b 40 38             	mov    0x38(%eax),%eax
  101bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c00:	c7 04 24 51 66 10 00 	movl   $0x106651,(%esp)
  101c07:	e8 4a e7 ff ff       	call   100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101c13:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c17:	c7 04 24 60 66 10 00 	movl   $0x106660,(%esp)
  101c1e:	e8 33 e7 ff ff       	call   100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c23:	8b 45 08             	mov    0x8(%ebp),%eax
  101c26:	8b 40 40             	mov    0x40(%eax),%eax
  101c29:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2d:	c7 04 24 73 66 10 00 	movl   $0x106673,(%esp)
  101c34:	e8 1d e7 ff ff       	call   100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c40:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c47:	eb 3d                	jmp    101c86 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c49:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4c:	8b 50 40             	mov    0x40(%eax),%edx
  101c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c52:	21 d0                	and    %edx,%eax
  101c54:	85 c0                	test   %eax,%eax
  101c56:	74 28                	je     101c80 <print_trapframe+0x148>
  101c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c5b:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101c62:	85 c0                	test   %eax,%eax
  101c64:	74 1a                	je     101c80 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c69:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101c70:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c74:	c7 04 24 82 66 10 00 	movl   $0x106682,(%esp)
  101c7b:	e8 d6 e6 ff ff       	call   100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c80:	ff 45 f4             	incl   -0xc(%ebp)
  101c83:	d1 65 f0             	shll   -0x10(%ebp)
  101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c89:	83 f8 17             	cmp    $0x17,%eax
  101c8c:	76 bb                	jbe    101c49 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c91:	8b 40 40             	mov    0x40(%eax),%eax
  101c94:	c1 e8 0c             	shr    $0xc,%eax
  101c97:	83 e0 03             	and    $0x3,%eax
  101c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9e:	c7 04 24 86 66 10 00 	movl   $0x106686,(%esp)
  101ca5:	e8 ac e6 ff ff       	call   100356 <cprintf>

    if (!trap_in_kernel(tf)) {
  101caa:	8b 45 08             	mov    0x8(%ebp),%eax
  101cad:	89 04 24             	mov    %eax,(%esp)
  101cb0:	e8 6e fe ff ff       	call   101b23 <trap_in_kernel>
  101cb5:	85 c0                	test   %eax,%eax
  101cb7:	75 2d                	jne    101ce6 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbc:	8b 40 44             	mov    0x44(%eax),%eax
  101cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc3:	c7 04 24 8f 66 10 00 	movl   $0x10668f,(%esp)
  101cca:	e8 87 e6 ff ff       	call   100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd2:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cda:	c7 04 24 9e 66 10 00 	movl   $0x10669e,(%esp)
  101ce1:	e8 70 e6 ff ff       	call   100356 <cprintf>
    }
}
  101ce6:	90                   	nop
  101ce7:	89 ec                	mov    %ebp,%esp
  101ce9:	5d                   	pop    %ebp
  101cea:	c3                   	ret    

00101ceb <print_regs>:

void
print_regs(struct pushregs *regs) {
  101ceb:	55                   	push   %ebp
  101cec:	89 e5                	mov    %esp,%ebp
  101cee:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf4:	8b 00                	mov    (%eax),%eax
  101cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cfa:	c7 04 24 b1 66 10 00 	movl   $0x1066b1,(%esp)
  101d01:	e8 50 e6 ff ff       	call   100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101d06:	8b 45 08             	mov    0x8(%ebp),%eax
  101d09:	8b 40 04             	mov    0x4(%eax),%eax
  101d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d10:	c7 04 24 c0 66 10 00 	movl   $0x1066c0,(%esp)
  101d17:	e8 3a e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1f:	8b 40 08             	mov    0x8(%eax),%eax
  101d22:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d26:	c7 04 24 cf 66 10 00 	movl   $0x1066cf,(%esp)
  101d2d:	e8 24 e6 ff ff       	call   100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d32:	8b 45 08             	mov    0x8(%ebp),%eax
  101d35:	8b 40 0c             	mov    0xc(%eax),%eax
  101d38:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d3c:	c7 04 24 de 66 10 00 	movl   $0x1066de,(%esp)
  101d43:	e8 0e e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d48:	8b 45 08             	mov    0x8(%ebp),%eax
  101d4b:	8b 40 10             	mov    0x10(%eax),%eax
  101d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d52:	c7 04 24 ed 66 10 00 	movl   $0x1066ed,(%esp)
  101d59:	e8 f8 e5 ff ff       	call   100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d61:	8b 40 14             	mov    0x14(%eax),%eax
  101d64:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d68:	c7 04 24 fc 66 10 00 	movl   $0x1066fc,(%esp)
  101d6f:	e8 e2 e5 ff ff       	call   100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d74:	8b 45 08             	mov    0x8(%ebp),%eax
  101d77:	8b 40 18             	mov    0x18(%eax),%eax
  101d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d7e:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  101d85:	e8 cc e5 ff ff       	call   100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8d:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d90:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d94:	c7 04 24 1a 67 10 00 	movl   $0x10671a,(%esp)
  101d9b:	e8 b6 e5 ff ff       	call   100356 <cprintf>
}
  101da0:	90                   	nop
  101da1:	89 ec                	mov    %ebp,%esp
  101da3:	5d                   	pop    %ebp
  101da4:	c3                   	ret    

00101da5 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101da5:	55                   	push   %ebp
  101da6:	89 e5                	mov    %esp,%ebp
  101da8:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101dab:	8b 45 08             	mov    0x8(%ebp),%eax
  101dae:	8b 40 30             	mov    0x30(%eax),%eax
  101db1:	83 f8 79             	cmp    $0x79,%eax
  101db4:	0f 87 e6 00 00 00    	ja     101ea0 <trap_dispatch+0xfb>
  101dba:	83 f8 78             	cmp    $0x78,%eax
  101dbd:	0f 83 c1 00 00 00    	jae    101e84 <trap_dispatch+0xdf>
  101dc3:	83 f8 2f             	cmp    $0x2f,%eax
  101dc6:	0f 87 d4 00 00 00    	ja     101ea0 <trap_dispatch+0xfb>
  101dcc:	83 f8 2e             	cmp    $0x2e,%eax
  101dcf:	0f 83 00 01 00 00    	jae    101ed5 <trap_dispatch+0x130>
  101dd5:	83 f8 24             	cmp    $0x24,%eax
  101dd8:	74 5e                	je     101e38 <trap_dispatch+0x93>
  101dda:	83 f8 24             	cmp    $0x24,%eax
  101ddd:	0f 87 bd 00 00 00    	ja     101ea0 <trap_dispatch+0xfb>
  101de3:	83 f8 20             	cmp    $0x20,%eax
  101de6:	74 0a                	je     101df2 <trap_dispatch+0x4d>
  101de8:	83 f8 21             	cmp    $0x21,%eax
  101deb:	74 71                	je     101e5e <trap_dispatch+0xb9>
  101ded:	e9 ae 00 00 00       	jmp    101ea0 <trap_dispatch+0xfb>
    case IRQ_OFFSET + IRQ_TIMER:
        ticks+=1;
  101df2:	a1 24 c4 11 00       	mov    0x11c424,%eax
  101df7:	40                   	inc    %eax
  101df8:	a3 24 c4 11 00       	mov    %eax,0x11c424
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        if (ticks % TICK_NUM == 0) {
  101dfd:	8b 0d 24 c4 11 00    	mov    0x11c424,%ecx
  101e03:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e08:	89 c8                	mov    %ecx,%eax
  101e0a:	f7 e2                	mul    %edx
  101e0c:	c1 ea 05             	shr    $0x5,%edx
  101e0f:	89 d0                	mov    %edx,%eax
  101e11:	c1 e0 02             	shl    $0x2,%eax
  101e14:	01 d0                	add    %edx,%eax
  101e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e1d:	01 d0                	add    %edx,%eax
  101e1f:	c1 e0 02             	shl    $0x2,%eax
  101e22:	29 c1                	sub    %eax,%ecx
  101e24:	89 ca                	mov    %ecx,%edx
  101e26:	85 d2                	test   %edx,%edx
  101e28:	0f 85 aa 00 00 00    	jne    101ed8 <trap_dispatch+0x133>
            print_ticks();
  101e2e:	e8 09 fb ff ff       	call   10193c <print_ticks>
        }
        break;
  101e33:	e9 a0 00 00 00       	jmp    101ed8 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e38:	e8 a2 f8 ff ff       	call   1016df <cons_getc>
  101e3d:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e40:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e44:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e48:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e50:	c7 04 24 29 67 10 00 	movl   $0x106729,(%esp)
  101e57:	e8 fa e4 ff ff       	call   100356 <cprintf>
        break;
  101e5c:	eb 7b                	jmp    101ed9 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e5e:	e8 7c f8 ff ff       	call   1016df <cons_getc>
  101e63:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e66:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e6a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e6e:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e72:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e76:	c7 04 24 3b 67 10 00 	movl   $0x10673b,(%esp)
  101e7d:	e8 d4 e4 ff ff       	call   100356 <cprintf>
        break;
  101e82:	eb 55                	jmp    101ed9 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101e84:	c7 44 24 08 4a 67 10 	movl   $0x10674a,0x8(%esp)
  101e8b:	00 
  101e8c:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101e93:	00 
  101e94:	c7 04 24 6e 65 10 00 	movl   $0x10656e,(%esp)
  101e9b:	e8 5f ee ff ff       	call   100cff <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ea7:	83 e0 03             	and    $0x3,%eax
  101eaa:	85 c0                	test   %eax,%eax
  101eac:	75 2b                	jne    101ed9 <trap_dispatch+0x134>
            print_trapframe(tf);
  101eae:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb1:	89 04 24             	mov    %eax,(%esp)
  101eb4:	e8 7f fc ff ff       	call   101b38 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101eb9:	c7 44 24 08 5a 67 10 	movl   $0x10675a,0x8(%esp)
  101ec0:	00 
  101ec1:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
  101ec8:	00 
  101ec9:	c7 04 24 6e 65 10 00 	movl   $0x10656e,(%esp)
  101ed0:	e8 2a ee ff ff       	call   100cff <__panic>
        break;
  101ed5:	90                   	nop
  101ed6:	eb 01                	jmp    101ed9 <trap_dispatch+0x134>
        break;
  101ed8:	90                   	nop
        }
    }
}
  101ed9:	90                   	nop
  101eda:	89 ec                	mov    %ebp,%esp
  101edc:	5d                   	pop    %ebp
  101edd:	c3                   	ret    

00101ede <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101ede:	55                   	push   %ebp
  101edf:	89 e5                	mov    %esp,%ebp
  101ee1:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee7:	89 04 24             	mov    %eax,(%esp)
  101eea:	e8 b6 fe ff ff       	call   101da5 <trap_dispatch>


}
  101eef:	90                   	nop
  101ef0:	89 ec                	mov    %ebp,%esp
  101ef2:	5d                   	pop    %ebp
  101ef3:	c3                   	ret    

00101ef4 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101ef4:	1e                   	push   %ds
    pushl %es
  101ef5:	06                   	push   %es
    pushl %fs
  101ef6:	0f a0                	push   %fs
    pushl %gs
  101ef8:	0f a8                	push   %gs
    pushal
  101efa:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101efb:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101f00:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101f02:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101f04:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101f05:	e8 d4 ff ff ff       	call   101ede <trap>

    # pop the pushed stack pointer
    popl %esp
  101f0a:	5c                   	pop    %esp

00101f0b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101f0b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101f0c:	0f a9                	pop    %gs
    popl %fs
  101f0e:	0f a1                	pop    %fs
    popl %es
  101f10:	07                   	pop    %es
    popl %ds
  101f11:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101f12:	83 c4 08             	add    $0x8,%esp
    iret
  101f15:	cf                   	iret   

00101f16 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f16:	6a 00                	push   $0x0
  pushl $0
  101f18:	6a 00                	push   $0x0
  jmp __alltraps
  101f1a:	e9 d5 ff ff ff       	jmp    101ef4 <__alltraps>

00101f1f <vector1>:
.globl vector1
vector1:
  pushl $0
  101f1f:	6a 00                	push   $0x0
  pushl $1
  101f21:	6a 01                	push   $0x1
  jmp __alltraps
  101f23:	e9 cc ff ff ff       	jmp    101ef4 <__alltraps>

00101f28 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $2
  101f2a:	6a 02                	push   $0x2
  jmp __alltraps
  101f2c:	e9 c3 ff ff ff       	jmp    101ef4 <__alltraps>

00101f31 <vector3>:
.globl vector3
vector3:
  pushl $0
  101f31:	6a 00                	push   $0x0
  pushl $3
  101f33:	6a 03                	push   $0x3
  jmp __alltraps
  101f35:	e9 ba ff ff ff       	jmp    101ef4 <__alltraps>

00101f3a <vector4>:
.globl vector4
vector4:
  pushl $0
  101f3a:	6a 00                	push   $0x0
  pushl $4
  101f3c:	6a 04                	push   $0x4
  jmp __alltraps
  101f3e:	e9 b1 ff ff ff       	jmp    101ef4 <__alltraps>

00101f43 <vector5>:
.globl vector5
vector5:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $5
  101f45:	6a 05                	push   $0x5
  jmp __alltraps
  101f47:	e9 a8 ff ff ff       	jmp    101ef4 <__alltraps>

00101f4c <vector6>:
.globl vector6
vector6:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $6
  101f4e:	6a 06                	push   $0x6
  jmp __alltraps
  101f50:	e9 9f ff ff ff       	jmp    101ef4 <__alltraps>

00101f55 <vector7>:
.globl vector7
vector7:
  pushl $0
  101f55:	6a 00                	push   $0x0
  pushl $7
  101f57:	6a 07                	push   $0x7
  jmp __alltraps
  101f59:	e9 96 ff ff ff       	jmp    101ef4 <__alltraps>

00101f5e <vector8>:
.globl vector8
vector8:
  pushl $8
  101f5e:	6a 08                	push   $0x8
  jmp __alltraps
  101f60:	e9 8f ff ff ff       	jmp    101ef4 <__alltraps>

00101f65 <vector9>:
.globl vector9
vector9:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $9
  101f67:	6a 09                	push   $0x9
  jmp __alltraps
  101f69:	e9 86 ff ff ff       	jmp    101ef4 <__alltraps>

00101f6e <vector10>:
.globl vector10
vector10:
  pushl $10
  101f6e:	6a 0a                	push   $0xa
  jmp __alltraps
  101f70:	e9 7f ff ff ff       	jmp    101ef4 <__alltraps>

00101f75 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f75:	6a 0b                	push   $0xb
  jmp __alltraps
  101f77:	e9 78 ff ff ff       	jmp    101ef4 <__alltraps>

00101f7c <vector12>:
.globl vector12
vector12:
  pushl $12
  101f7c:	6a 0c                	push   $0xc
  jmp __alltraps
  101f7e:	e9 71 ff ff ff       	jmp    101ef4 <__alltraps>

00101f83 <vector13>:
.globl vector13
vector13:
  pushl $13
  101f83:	6a 0d                	push   $0xd
  jmp __alltraps
  101f85:	e9 6a ff ff ff       	jmp    101ef4 <__alltraps>

00101f8a <vector14>:
.globl vector14
vector14:
  pushl $14
  101f8a:	6a 0e                	push   $0xe
  jmp __alltraps
  101f8c:	e9 63 ff ff ff       	jmp    101ef4 <__alltraps>

00101f91 <vector15>:
.globl vector15
vector15:
  pushl $0
  101f91:	6a 00                	push   $0x0
  pushl $15
  101f93:	6a 0f                	push   $0xf
  jmp __alltraps
  101f95:	e9 5a ff ff ff       	jmp    101ef4 <__alltraps>

00101f9a <vector16>:
.globl vector16
vector16:
  pushl $0
  101f9a:	6a 00                	push   $0x0
  pushl $16
  101f9c:	6a 10                	push   $0x10
  jmp __alltraps
  101f9e:	e9 51 ff ff ff       	jmp    101ef4 <__alltraps>

00101fa3 <vector17>:
.globl vector17
vector17:
  pushl $17
  101fa3:	6a 11                	push   $0x11
  jmp __alltraps
  101fa5:	e9 4a ff ff ff       	jmp    101ef4 <__alltraps>

00101faa <vector18>:
.globl vector18
vector18:
  pushl $0
  101faa:	6a 00                	push   $0x0
  pushl $18
  101fac:	6a 12                	push   $0x12
  jmp __alltraps
  101fae:	e9 41 ff ff ff       	jmp    101ef4 <__alltraps>

00101fb3 <vector19>:
.globl vector19
vector19:
  pushl $0
  101fb3:	6a 00                	push   $0x0
  pushl $19
  101fb5:	6a 13                	push   $0x13
  jmp __alltraps
  101fb7:	e9 38 ff ff ff       	jmp    101ef4 <__alltraps>

00101fbc <vector20>:
.globl vector20
vector20:
  pushl $0
  101fbc:	6a 00                	push   $0x0
  pushl $20
  101fbe:	6a 14                	push   $0x14
  jmp __alltraps
  101fc0:	e9 2f ff ff ff       	jmp    101ef4 <__alltraps>

00101fc5 <vector21>:
.globl vector21
vector21:
  pushl $0
  101fc5:	6a 00                	push   $0x0
  pushl $21
  101fc7:	6a 15                	push   $0x15
  jmp __alltraps
  101fc9:	e9 26 ff ff ff       	jmp    101ef4 <__alltraps>

00101fce <vector22>:
.globl vector22
vector22:
  pushl $0
  101fce:	6a 00                	push   $0x0
  pushl $22
  101fd0:	6a 16                	push   $0x16
  jmp __alltraps
  101fd2:	e9 1d ff ff ff       	jmp    101ef4 <__alltraps>

00101fd7 <vector23>:
.globl vector23
vector23:
  pushl $0
  101fd7:	6a 00                	push   $0x0
  pushl $23
  101fd9:	6a 17                	push   $0x17
  jmp __alltraps
  101fdb:	e9 14 ff ff ff       	jmp    101ef4 <__alltraps>

00101fe0 <vector24>:
.globl vector24
vector24:
  pushl $0
  101fe0:	6a 00                	push   $0x0
  pushl $24
  101fe2:	6a 18                	push   $0x18
  jmp __alltraps
  101fe4:	e9 0b ff ff ff       	jmp    101ef4 <__alltraps>

00101fe9 <vector25>:
.globl vector25
vector25:
  pushl $0
  101fe9:	6a 00                	push   $0x0
  pushl $25
  101feb:	6a 19                	push   $0x19
  jmp __alltraps
  101fed:	e9 02 ff ff ff       	jmp    101ef4 <__alltraps>

00101ff2 <vector26>:
.globl vector26
vector26:
  pushl $0
  101ff2:	6a 00                	push   $0x0
  pushl $26
  101ff4:	6a 1a                	push   $0x1a
  jmp __alltraps
  101ff6:	e9 f9 fe ff ff       	jmp    101ef4 <__alltraps>

00101ffb <vector27>:
.globl vector27
vector27:
  pushl $0
  101ffb:	6a 00                	push   $0x0
  pushl $27
  101ffd:	6a 1b                	push   $0x1b
  jmp __alltraps
  101fff:	e9 f0 fe ff ff       	jmp    101ef4 <__alltraps>

00102004 <vector28>:
.globl vector28
vector28:
  pushl $0
  102004:	6a 00                	push   $0x0
  pushl $28
  102006:	6a 1c                	push   $0x1c
  jmp __alltraps
  102008:	e9 e7 fe ff ff       	jmp    101ef4 <__alltraps>

0010200d <vector29>:
.globl vector29
vector29:
  pushl $0
  10200d:	6a 00                	push   $0x0
  pushl $29
  10200f:	6a 1d                	push   $0x1d
  jmp __alltraps
  102011:	e9 de fe ff ff       	jmp    101ef4 <__alltraps>

00102016 <vector30>:
.globl vector30
vector30:
  pushl $0
  102016:	6a 00                	push   $0x0
  pushl $30
  102018:	6a 1e                	push   $0x1e
  jmp __alltraps
  10201a:	e9 d5 fe ff ff       	jmp    101ef4 <__alltraps>

0010201f <vector31>:
.globl vector31
vector31:
  pushl $0
  10201f:	6a 00                	push   $0x0
  pushl $31
  102021:	6a 1f                	push   $0x1f
  jmp __alltraps
  102023:	e9 cc fe ff ff       	jmp    101ef4 <__alltraps>

00102028 <vector32>:
.globl vector32
vector32:
  pushl $0
  102028:	6a 00                	push   $0x0
  pushl $32
  10202a:	6a 20                	push   $0x20
  jmp __alltraps
  10202c:	e9 c3 fe ff ff       	jmp    101ef4 <__alltraps>

00102031 <vector33>:
.globl vector33
vector33:
  pushl $0
  102031:	6a 00                	push   $0x0
  pushl $33
  102033:	6a 21                	push   $0x21
  jmp __alltraps
  102035:	e9 ba fe ff ff       	jmp    101ef4 <__alltraps>

0010203a <vector34>:
.globl vector34
vector34:
  pushl $0
  10203a:	6a 00                	push   $0x0
  pushl $34
  10203c:	6a 22                	push   $0x22
  jmp __alltraps
  10203e:	e9 b1 fe ff ff       	jmp    101ef4 <__alltraps>

00102043 <vector35>:
.globl vector35
vector35:
  pushl $0
  102043:	6a 00                	push   $0x0
  pushl $35
  102045:	6a 23                	push   $0x23
  jmp __alltraps
  102047:	e9 a8 fe ff ff       	jmp    101ef4 <__alltraps>

0010204c <vector36>:
.globl vector36
vector36:
  pushl $0
  10204c:	6a 00                	push   $0x0
  pushl $36
  10204e:	6a 24                	push   $0x24
  jmp __alltraps
  102050:	e9 9f fe ff ff       	jmp    101ef4 <__alltraps>

00102055 <vector37>:
.globl vector37
vector37:
  pushl $0
  102055:	6a 00                	push   $0x0
  pushl $37
  102057:	6a 25                	push   $0x25
  jmp __alltraps
  102059:	e9 96 fe ff ff       	jmp    101ef4 <__alltraps>

0010205e <vector38>:
.globl vector38
vector38:
  pushl $0
  10205e:	6a 00                	push   $0x0
  pushl $38
  102060:	6a 26                	push   $0x26
  jmp __alltraps
  102062:	e9 8d fe ff ff       	jmp    101ef4 <__alltraps>

00102067 <vector39>:
.globl vector39
vector39:
  pushl $0
  102067:	6a 00                	push   $0x0
  pushl $39
  102069:	6a 27                	push   $0x27
  jmp __alltraps
  10206b:	e9 84 fe ff ff       	jmp    101ef4 <__alltraps>

00102070 <vector40>:
.globl vector40
vector40:
  pushl $0
  102070:	6a 00                	push   $0x0
  pushl $40
  102072:	6a 28                	push   $0x28
  jmp __alltraps
  102074:	e9 7b fe ff ff       	jmp    101ef4 <__alltraps>

00102079 <vector41>:
.globl vector41
vector41:
  pushl $0
  102079:	6a 00                	push   $0x0
  pushl $41
  10207b:	6a 29                	push   $0x29
  jmp __alltraps
  10207d:	e9 72 fe ff ff       	jmp    101ef4 <__alltraps>

00102082 <vector42>:
.globl vector42
vector42:
  pushl $0
  102082:	6a 00                	push   $0x0
  pushl $42
  102084:	6a 2a                	push   $0x2a
  jmp __alltraps
  102086:	e9 69 fe ff ff       	jmp    101ef4 <__alltraps>

0010208b <vector43>:
.globl vector43
vector43:
  pushl $0
  10208b:	6a 00                	push   $0x0
  pushl $43
  10208d:	6a 2b                	push   $0x2b
  jmp __alltraps
  10208f:	e9 60 fe ff ff       	jmp    101ef4 <__alltraps>

00102094 <vector44>:
.globl vector44
vector44:
  pushl $0
  102094:	6a 00                	push   $0x0
  pushl $44
  102096:	6a 2c                	push   $0x2c
  jmp __alltraps
  102098:	e9 57 fe ff ff       	jmp    101ef4 <__alltraps>

0010209d <vector45>:
.globl vector45
vector45:
  pushl $0
  10209d:	6a 00                	push   $0x0
  pushl $45
  10209f:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020a1:	e9 4e fe ff ff       	jmp    101ef4 <__alltraps>

001020a6 <vector46>:
.globl vector46
vector46:
  pushl $0
  1020a6:	6a 00                	push   $0x0
  pushl $46
  1020a8:	6a 2e                	push   $0x2e
  jmp __alltraps
  1020aa:	e9 45 fe ff ff       	jmp    101ef4 <__alltraps>

001020af <vector47>:
.globl vector47
vector47:
  pushl $0
  1020af:	6a 00                	push   $0x0
  pushl $47
  1020b1:	6a 2f                	push   $0x2f
  jmp __alltraps
  1020b3:	e9 3c fe ff ff       	jmp    101ef4 <__alltraps>

001020b8 <vector48>:
.globl vector48
vector48:
  pushl $0
  1020b8:	6a 00                	push   $0x0
  pushl $48
  1020ba:	6a 30                	push   $0x30
  jmp __alltraps
  1020bc:	e9 33 fe ff ff       	jmp    101ef4 <__alltraps>

001020c1 <vector49>:
.globl vector49
vector49:
  pushl $0
  1020c1:	6a 00                	push   $0x0
  pushl $49
  1020c3:	6a 31                	push   $0x31
  jmp __alltraps
  1020c5:	e9 2a fe ff ff       	jmp    101ef4 <__alltraps>

001020ca <vector50>:
.globl vector50
vector50:
  pushl $0
  1020ca:	6a 00                	push   $0x0
  pushl $50
  1020cc:	6a 32                	push   $0x32
  jmp __alltraps
  1020ce:	e9 21 fe ff ff       	jmp    101ef4 <__alltraps>

001020d3 <vector51>:
.globl vector51
vector51:
  pushl $0
  1020d3:	6a 00                	push   $0x0
  pushl $51
  1020d5:	6a 33                	push   $0x33
  jmp __alltraps
  1020d7:	e9 18 fe ff ff       	jmp    101ef4 <__alltraps>

001020dc <vector52>:
.globl vector52
vector52:
  pushl $0
  1020dc:	6a 00                	push   $0x0
  pushl $52
  1020de:	6a 34                	push   $0x34
  jmp __alltraps
  1020e0:	e9 0f fe ff ff       	jmp    101ef4 <__alltraps>

001020e5 <vector53>:
.globl vector53
vector53:
  pushl $0
  1020e5:	6a 00                	push   $0x0
  pushl $53
  1020e7:	6a 35                	push   $0x35
  jmp __alltraps
  1020e9:	e9 06 fe ff ff       	jmp    101ef4 <__alltraps>

001020ee <vector54>:
.globl vector54
vector54:
  pushl $0
  1020ee:	6a 00                	push   $0x0
  pushl $54
  1020f0:	6a 36                	push   $0x36
  jmp __alltraps
  1020f2:	e9 fd fd ff ff       	jmp    101ef4 <__alltraps>

001020f7 <vector55>:
.globl vector55
vector55:
  pushl $0
  1020f7:	6a 00                	push   $0x0
  pushl $55
  1020f9:	6a 37                	push   $0x37
  jmp __alltraps
  1020fb:	e9 f4 fd ff ff       	jmp    101ef4 <__alltraps>

00102100 <vector56>:
.globl vector56
vector56:
  pushl $0
  102100:	6a 00                	push   $0x0
  pushl $56
  102102:	6a 38                	push   $0x38
  jmp __alltraps
  102104:	e9 eb fd ff ff       	jmp    101ef4 <__alltraps>

00102109 <vector57>:
.globl vector57
vector57:
  pushl $0
  102109:	6a 00                	push   $0x0
  pushl $57
  10210b:	6a 39                	push   $0x39
  jmp __alltraps
  10210d:	e9 e2 fd ff ff       	jmp    101ef4 <__alltraps>

00102112 <vector58>:
.globl vector58
vector58:
  pushl $0
  102112:	6a 00                	push   $0x0
  pushl $58
  102114:	6a 3a                	push   $0x3a
  jmp __alltraps
  102116:	e9 d9 fd ff ff       	jmp    101ef4 <__alltraps>

0010211b <vector59>:
.globl vector59
vector59:
  pushl $0
  10211b:	6a 00                	push   $0x0
  pushl $59
  10211d:	6a 3b                	push   $0x3b
  jmp __alltraps
  10211f:	e9 d0 fd ff ff       	jmp    101ef4 <__alltraps>

00102124 <vector60>:
.globl vector60
vector60:
  pushl $0
  102124:	6a 00                	push   $0x0
  pushl $60
  102126:	6a 3c                	push   $0x3c
  jmp __alltraps
  102128:	e9 c7 fd ff ff       	jmp    101ef4 <__alltraps>

0010212d <vector61>:
.globl vector61
vector61:
  pushl $0
  10212d:	6a 00                	push   $0x0
  pushl $61
  10212f:	6a 3d                	push   $0x3d
  jmp __alltraps
  102131:	e9 be fd ff ff       	jmp    101ef4 <__alltraps>

00102136 <vector62>:
.globl vector62
vector62:
  pushl $0
  102136:	6a 00                	push   $0x0
  pushl $62
  102138:	6a 3e                	push   $0x3e
  jmp __alltraps
  10213a:	e9 b5 fd ff ff       	jmp    101ef4 <__alltraps>

0010213f <vector63>:
.globl vector63
vector63:
  pushl $0
  10213f:	6a 00                	push   $0x0
  pushl $63
  102141:	6a 3f                	push   $0x3f
  jmp __alltraps
  102143:	e9 ac fd ff ff       	jmp    101ef4 <__alltraps>

00102148 <vector64>:
.globl vector64
vector64:
  pushl $0
  102148:	6a 00                	push   $0x0
  pushl $64
  10214a:	6a 40                	push   $0x40
  jmp __alltraps
  10214c:	e9 a3 fd ff ff       	jmp    101ef4 <__alltraps>

00102151 <vector65>:
.globl vector65
vector65:
  pushl $0
  102151:	6a 00                	push   $0x0
  pushl $65
  102153:	6a 41                	push   $0x41
  jmp __alltraps
  102155:	e9 9a fd ff ff       	jmp    101ef4 <__alltraps>

0010215a <vector66>:
.globl vector66
vector66:
  pushl $0
  10215a:	6a 00                	push   $0x0
  pushl $66
  10215c:	6a 42                	push   $0x42
  jmp __alltraps
  10215e:	e9 91 fd ff ff       	jmp    101ef4 <__alltraps>

00102163 <vector67>:
.globl vector67
vector67:
  pushl $0
  102163:	6a 00                	push   $0x0
  pushl $67
  102165:	6a 43                	push   $0x43
  jmp __alltraps
  102167:	e9 88 fd ff ff       	jmp    101ef4 <__alltraps>

0010216c <vector68>:
.globl vector68
vector68:
  pushl $0
  10216c:	6a 00                	push   $0x0
  pushl $68
  10216e:	6a 44                	push   $0x44
  jmp __alltraps
  102170:	e9 7f fd ff ff       	jmp    101ef4 <__alltraps>

00102175 <vector69>:
.globl vector69
vector69:
  pushl $0
  102175:	6a 00                	push   $0x0
  pushl $69
  102177:	6a 45                	push   $0x45
  jmp __alltraps
  102179:	e9 76 fd ff ff       	jmp    101ef4 <__alltraps>

0010217e <vector70>:
.globl vector70
vector70:
  pushl $0
  10217e:	6a 00                	push   $0x0
  pushl $70
  102180:	6a 46                	push   $0x46
  jmp __alltraps
  102182:	e9 6d fd ff ff       	jmp    101ef4 <__alltraps>

00102187 <vector71>:
.globl vector71
vector71:
  pushl $0
  102187:	6a 00                	push   $0x0
  pushl $71
  102189:	6a 47                	push   $0x47
  jmp __alltraps
  10218b:	e9 64 fd ff ff       	jmp    101ef4 <__alltraps>

00102190 <vector72>:
.globl vector72
vector72:
  pushl $0
  102190:	6a 00                	push   $0x0
  pushl $72
  102192:	6a 48                	push   $0x48
  jmp __alltraps
  102194:	e9 5b fd ff ff       	jmp    101ef4 <__alltraps>

00102199 <vector73>:
.globl vector73
vector73:
  pushl $0
  102199:	6a 00                	push   $0x0
  pushl $73
  10219b:	6a 49                	push   $0x49
  jmp __alltraps
  10219d:	e9 52 fd ff ff       	jmp    101ef4 <__alltraps>

001021a2 <vector74>:
.globl vector74
vector74:
  pushl $0
  1021a2:	6a 00                	push   $0x0
  pushl $74
  1021a4:	6a 4a                	push   $0x4a
  jmp __alltraps
  1021a6:	e9 49 fd ff ff       	jmp    101ef4 <__alltraps>

001021ab <vector75>:
.globl vector75
vector75:
  pushl $0
  1021ab:	6a 00                	push   $0x0
  pushl $75
  1021ad:	6a 4b                	push   $0x4b
  jmp __alltraps
  1021af:	e9 40 fd ff ff       	jmp    101ef4 <__alltraps>

001021b4 <vector76>:
.globl vector76
vector76:
  pushl $0
  1021b4:	6a 00                	push   $0x0
  pushl $76
  1021b6:	6a 4c                	push   $0x4c
  jmp __alltraps
  1021b8:	e9 37 fd ff ff       	jmp    101ef4 <__alltraps>

001021bd <vector77>:
.globl vector77
vector77:
  pushl $0
  1021bd:	6a 00                	push   $0x0
  pushl $77
  1021bf:	6a 4d                	push   $0x4d
  jmp __alltraps
  1021c1:	e9 2e fd ff ff       	jmp    101ef4 <__alltraps>

001021c6 <vector78>:
.globl vector78
vector78:
  pushl $0
  1021c6:	6a 00                	push   $0x0
  pushl $78
  1021c8:	6a 4e                	push   $0x4e
  jmp __alltraps
  1021ca:	e9 25 fd ff ff       	jmp    101ef4 <__alltraps>

001021cf <vector79>:
.globl vector79
vector79:
  pushl $0
  1021cf:	6a 00                	push   $0x0
  pushl $79
  1021d1:	6a 4f                	push   $0x4f
  jmp __alltraps
  1021d3:	e9 1c fd ff ff       	jmp    101ef4 <__alltraps>

001021d8 <vector80>:
.globl vector80
vector80:
  pushl $0
  1021d8:	6a 00                	push   $0x0
  pushl $80
  1021da:	6a 50                	push   $0x50
  jmp __alltraps
  1021dc:	e9 13 fd ff ff       	jmp    101ef4 <__alltraps>

001021e1 <vector81>:
.globl vector81
vector81:
  pushl $0
  1021e1:	6a 00                	push   $0x0
  pushl $81
  1021e3:	6a 51                	push   $0x51
  jmp __alltraps
  1021e5:	e9 0a fd ff ff       	jmp    101ef4 <__alltraps>

001021ea <vector82>:
.globl vector82
vector82:
  pushl $0
  1021ea:	6a 00                	push   $0x0
  pushl $82
  1021ec:	6a 52                	push   $0x52
  jmp __alltraps
  1021ee:	e9 01 fd ff ff       	jmp    101ef4 <__alltraps>

001021f3 <vector83>:
.globl vector83
vector83:
  pushl $0
  1021f3:	6a 00                	push   $0x0
  pushl $83
  1021f5:	6a 53                	push   $0x53
  jmp __alltraps
  1021f7:	e9 f8 fc ff ff       	jmp    101ef4 <__alltraps>

001021fc <vector84>:
.globl vector84
vector84:
  pushl $0
  1021fc:	6a 00                	push   $0x0
  pushl $84
  1021fe:	6a 54                	push   $0x54
  jmp __alltraps
  102200:	e9 ef fc ff ff       	jmp    101ef4 <__alltraps>

00102205 <vector85>:
.globl vector85
vector85:
  pushl $0
  102205:	6a 00                	push   $0x0
  pushl $85
  102207:	6a 55                	push   $0x55
  jmp __alltraps
  102209:	e9 e6 fc ff ff       	jmp    101ef4 <__alltraps>

0010220e <vector86>:
.globl vector86
vector86:
  pushl $0
  10220e:	6a 00                	push   $0x0
  pushl $86
  102210:	6a 56                	push   $0x56
  jmp __alltraps
  102212:	e9 dd fc ff ff       	jmp    101ef4 <__alltraps>

00102217 <vector87>:
.globl vector87
vector87:
  pushl $0
  102217:	6a 00                	push   $0x0
  pushl $87
  102219:	6a 57                	push   $0x57
  jmp __alltraps
  10221b:	e9 d4 fc ff ff       	jmp    101ef4 <__alltraps>

00102220 <vector88>:
.globl vector88
vector88:
  pushl $0
  102220:	6a 00                	push   $0x0
  pushl $88
  102222:	6a 58                	push   $0x58
  jmp __alltraps
  102224:	e9 cb fc ff ff       	jmp    101ef4 <__alltraps>

00102229 <vector89>:
.globl vector89
vector89:
  pushl $0
  102229:	6a 00                	push   $0x0
  pushl $89
  10222b:	6a 59                	push   $0x59
  jmp __alltraps
  10222d:	e9 c2 fc ff ff       	jmp    101ef4 <__alltraps>

00102232 <vector90>:
.globl vector90
vector90:
  pushl $0
  102232:	6a 00                	push   $0x0
  pushl $90
  102234:	6a 5a                	push   $0x5a
  jmp __alltraps
  102236:	e9 b9 fc ff ff       	jmp    101ef4 <__alltraps>

0010223b <vector91>:
.globl vector91
vector91:
  pushl $0
  10223b:	6a 00                	push   $0x0
  pushl $91
  10223d:	6a 5b                	push   $0x5b
  jmp __alltraps
  10223f:	e9 b0 fc ff ff       	jmp    101ef4 <__alltraps>

00102244 <vector92>:
.globl vector92
vector92:
  pushl $0
  102244:	6a 00                	push   $0x0
  pushl $92
  102246:	6a 5c                	push   $0x5c
  jmp __alltraps
  102248:	e9 a7 fc ff ff       	jmp    101ef4 <__alltraps>

0010224d <vector93>:
.globl vector93
vector93:
  pushl $0
  10224d:	6a 00                	push   $0x0
  pushl $93
  10224f:	6a 5d                	push   $0x5d
  jmp __alltraps
  102251:	e9 9e fc ff ff       	jmp    101ef4 <__alltraps>

00102256 <vector94>:
.globl vector94
vector94:
  pushl $0
  102256:	6a 00                	push   $0x0
  pushl $94
  102258:	6a 5e                	push   $0x5e
  jmp __alltraps
  10225a:	e9 95 fc ff ff       	jmp    101ef4 <__alltraps>

0010225f <vector95>:
.globl vector95
vector95:
  pushl $0
  10225f:	6a 00                	push   $0x0
  pushl $95
  102261:	6a 5f                	push   $0x5f
  jmp __alltraps
  102263:	e9 8c fc ff ff       	jmp    101ef4 <__alltraps>

00102268 <vector96>:
.globl vector96
vector96:
  pushl $0
  102268:	6a 00                	push   $0x0
  pushl $96
  10226a:	6a 60                	push   $0x60
  jmp __alltraps
  10226c:	e9 83 fc ff ff       	jmp    101ef4 <__alltraps>

00102271 <vector97>:
.globl vector97
vector97:
  pushl $0
  102271:	6a 00                	push   $0x0
  pushl $97
  102273:	6a 61                	push   $0x61
  jmp __alltraps
  102275:	e9 7a fc ff ff       	jmp    101ef4 <__alltraps>

0010227a <vector98>:
.globl vector98
vector98:
  pushl $0
  10227a:	6a 00                	push   $0x0
  pushl $98
  10227c:	6a 62                	push   $0x62
  jmp __alltraps
  10227e:	e9 71 fc ff ff       	jmp    101ef4 <__alltraps>

00102283 <vector99>:
.globl vector99
vector99:
  pushl $0
  102283:	6a 00                	push   $0x0
  pushl $99
  102285:	6a 63                	push   $0x63
  jmp __alltraps
  102287:	e9 68 fc ff ff       	jmp    101ef4 <__alltraps>

0010228c <vector100>:
.globl vector100
vector100:
  pushl $0
  10228c:	6a 00                	push   $0x0
  pushl $100
  10228e:	6a 64                	push   $0x64
  jmp __alltraps
  102290:	e9 5f fc ff ff       	jmp    101ef4 <__alltraps>

00102295 <vector101>:
.globl vector101
vector101:
  pushl $0
  102295:	6a 00                	push   $0x0
  pushl $101
  102297:	6a 65                	push   $0x65
  jmp __alltraps
  102299:	e9 56 fc ff ff       	jmp    101ef4 <__alltraps>

0010229e <vector102>:
.globl vector102
vector102:
  pushl $0
  10229e:	6a 00                	push   $0x0
  pushl $102
  1022a0:	6a 66                	push   $0x66
  jmp __alltraps
  1022a2:	e9 4d fc ff ff       	jmp    101ef4 <__alltraps>

001022a7 <vector103>:
.globl vector103
vector103:
  pushl $0
  1022a7:	6a 00                	push   $0x0
  pushl $103
  1022a9:	6a 67                	push   $0x67
  jmp __alltraps
  1022ab:	e9 44 fc ff ff       	jmp    101ef4 <__alltraps>

001022b0 <vector104>:
.globl vector104
vector104:
  pushl $0
  1022b0:	6a 00                	push   $0x0
  pushl $104
  1022b2:	6a 68                	push   $0x68
  jmp __alltraps
  1022b4:	e9 3b fc ff ff       	jmp    101ef4 <__alltraps>

001022b9 <vector105>:
.globl vector105
vector105:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $105
  1022bb:	6a 69                	push   $0x69
  jmp __alltraps
  1022bd:	e9 32 fc ff ff       	jmp    101ef4 <__alltraps>

001022c2 <vector106>:
.globl vector106
vector106:
  pushl $0
  1022c2:	6a 00                	push   $0x0
  pushl $106
  1022c4:	6a 6a                	push   $0x6a
  jmp __alltraps
  1022c6:	e9 29 fc ff ff       	jmp    101ef4 <__alltraps>

001022cb <vector107>:
.globl vector107
vector107:
  pushl $0
  1022cb:	6a 00                	push   $0x0
  pushl $107
  1022cd:	6a 6b                	push   $0x6b
  jmp __alltraps
  1022cf:	e9 20 fc ff ff       	jmp    101ef4 <__alltraps>

001022d4 <vector108>:
.globl vector108
vector108:
  pushl $0
  1022d4:	6a 00                	push   $0x0
  pushl $108
  1022d6:	6a 6c                	push   $0x6c
  jmp __alltraps
  1022d8:	e9 17 fc ff ff       	jmp    101ef4 <__alltraps>

001022dd <vector109>:
.globl vector109
vector109:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $109
  1022df:	6a 6d                	push   $0x6d
  jmp __alltraps
  1022e1:	e9 0e fc ff ff       	jmp    101ef4 <__alltraps>

001022e6 <vector110>:
.globl vector110
vector110:
  pushl $0
  1022e6:	6a 00                	push   $0x0
  pushl $110
  1022e8:	6a 6e                	push   $0x6e
  jmp __alltraps
  1022ea:	e9 05 fc ff ff       	jmp    101ef4 <__alltraps>

001022ef <vector111>:
.globl vector111
vector111:
  pushl $0
  1022ef:	6a 00                	push   $0x0
  pushl $111
  1022f1:	6a 6f                	push   $0x6f
  jmp __alltraps
  1022f3:	e9 fc fb ff ff       	jmp    101ef4 <__alltraps>

001022f8 <vector112>:
.globl vector112
vector112:
  pushl $0
  1022f8:	6a 00                	push   $0x0
  pushl $112
  1022fa:	6a 70                	push   $0x70
  jmp __alltraps
  1022fc:	e9 f3 fb ff ff       	jmp    101ef4 <__alltraps>

00102301 <vector113>:
.globl vector113
vector113:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $113
  102303:	6a 71                	push   $0x71
  jmp __alltraps
  102305:	e9 ea fb ff ff       	jmp    101ef4 <__alltraps>

0010230a <vector114>:
.globl vector114
vector114:
  pushl $0
  10230a:	6a 00                	push   $0x0
  pushl $114
  10230c:	6a 72                	push   $0x72
  jmp __alltraps
  10230e:	e9 e1 fb ff ff       	jmp    101ef4 <__alltraps>

00102313 <vector115>:
.globl vector115
vector115:
  pushl $0
  102313:	6a 00                	push   $0x0
  pushl $115
  102315:	6a 73                	push   $0x73
  jmp __alltraps
  102317:	e9 d8 fb ff ff       	jmp    101ef4 <__alltraps>

0010231c <vector116>:
.globl vector116
vector116:
  pushl $0
  10231c:	6a 00                	push   $0x0
  pushl $116
  10231e:	6a 74                	push   $0x74
  jmp __alltraps
  102320:	e9 cf fb ff ff       	jmp    101ef4 <__alltraps>

00102325 <vector117>:
.globl vector117
vector117:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $117
  102327:	6a 75                	push   $0x75
  jmp __alltraps
  102329:	e9 c6 fb ff ff       	jmp    101ef4 <__alltraps>

0010232e <vector118>:
.globl vector118
vector118:
  pushl $0
  10232e:	6a 00                	push   $0x0
  pushl $118
  102330:	6a 76                	push   $0x76
  jmp __alltraps
  102332:	e9 bd fb ff ff       	jmp    101ef4 <__alltraps>

00102337 <vector119>:
.globl vector119
vector119:
  pushl $0
  102337:	6a 00                	push   $0x0
  pushl $119
  102339:	6a 77                	push   $0x77
  jmp __alltraps
  10233b:	e9 b4 fb ff ff       	jmp    101ef4 <__alltraps>

00102340 <vector120>:
.globl vector120
vector120:
  pushl $0
  102340:	6a 00                	push   $0x0
  pushl $120
  102342:	6a 78                	push   $0x78
  jmp __alltraps
  102344:	e9 ab fb ff ff       	jmp    101ef4 <__alltraps>

00102349 <vector121>:
.globl vector121
vector121:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $121
  10234b:	6a 79                	push   $0x79
  jmp __alltraps
  10234d:	e9 a2 fb ff ff       	jmp    101ef4 <__alltraps>

00102352 <vector122>:
.globl vector122
vector122:
  pushl $0
  102352:	6a 00                	push   $0x0
  pushl $122
  102354:	6a 7a                	push   $0x7a
  jmp __alltraps
  102356:	e9 99 fb ff ff       	jmp    101ef4 <__alltraps>

0010235b <vector123>:
.globl vector123
vector123:
  pushl $0
  10235b:	6a 00                	push   $0x0
  pushl $123
  10235d:	6a 7b                	push   $0x7b
  jmp __alltraps
  10235f:	e9 90 fb ff ff       	jmp    101ef4 <__alltraps>

00102364 <vector124>:
.globl vector124
vector124:
  pushl $0
  102364:	6a 00                	push   $0x0
  pushl $124
  102366:	6a 7c                	push   $0x7c
  jmp __alltraps
  102368:	e9 87 fb ff ff       	jmp    101ef4 <__alltraps>

0010236d <vector125>:
.globl vector125
vector125:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $125
  10236f:	6a 7d                	push   $0x7d
  jmp __alltraps
  102371:	e9 7e fb ff ff       	jmp    101ef4 <__alltraps>

00102376 <vector126>:
.globl vector126
vector126:
  pushl $0
  102376:	6a 00                	push   $0x0
  pushl $126
  102378:	6a 7e                	push   $0x7e
  jmp __alltraps
  10237a:	e9 75 fb ff ff       	jmp    101ef4 <__alltraps>

0010237f <vector127>:
.globl vector127
vector127:
  pushl $0
  10237f:	6a 00                	push   $0x0
  pushl $127
  102381:	6a 7f                	push   $0x7f
  jmp __alltraps
  102383:	e9 6c fb ff ff       	jmp    101ef4 <__alltraps>

00102388 <vector128>:
.globl vector128
vector128:
  pushl $0
  102388:	6a 00                	push   $0x0
  pushl $128
  10238a:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10238f:	e9 60 fb ff ff       	jmp    101ef4 <__alltraps>

00102394 <vector129>:
.globl vector129
vector129:
  pushl $0
  102394:	6a 00                	push   $0x0
  pushl $129
  102396:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10239b:	e9 54 fb ff ff       	jmp    101ef4 <__alltraps>

001023a0 <vector130>:
.globl vector130
vector130:
  pushl $0
  1023a0:	6a 00                	push   $0x0
  pushl $130
  1023a2:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1023a7:	e9 48 fb ff ff       	jmp    101ef4 <__alltraps>

001023ac <vector131>:
.globl vector131
vector131:
  pushl $0
  1023ac:	6a 00                	push   $0x0
  pushl $131
  1023ae:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1023b3:	e9 3c fb ff ff       	jmp    101ef4 <__alltraps>

001023b8 <vector132>:
.globl vector132
vector132:
  pushl $0
  1023b8:	6a 00                	push   $0x0
  pushl $132
  1023ba:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1023bf:	e9 30 fb ff ff       	jmp    101ef4 <__alltraps>

001023c4 <vector133>:
.globl vector133
vector133:
  pushl $0
  1023c4:	6a 00                	push   $0x0
  pushl $133
  1023c6:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1023cb:	e9 24 fb ff ff       	jmp    101ef4 <__alltraps>

001023d0 <vector134>:
.globl vector134
vector134:
  pushl $0
  1023d0:	6a 00                	push   $0x0
  pushl $134
  1023d2:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1023d7:	e9 18 fb ff ff       	jmp    101ef4 <__alltraps>

001023dc <vector135>:
.globl vector135
vector135:
  pushl $0
  1023dc:	6a 00                	push   $0x0
  pushl $135
  1023de:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1023e3:	e9 0c fb ff ff       	jmp    101ef4 <__alltraps>

001023e8 <vector136>:
.globl vector136
vector136:
  pushl $0
  1023e8:	6a 00                	push   $0x0
  pushl $136
  1023ea:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1023ef:	e9 00 fb ff ff       	jmp    101ef4 <__alltraps>

001023f4 <vector137>:
.globl vector137
vector137:
  pushl $0
  1023f4:	6a 00                	push   $0x0
  pushl $137
  1023f6:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1023fb:	e9 f4 fa ff ff       	jmp    101ef4 <__alltraps>

00102400 <vector138>:
.globl vector138
vector138:
  pushl $0
  102400:	6a 00                	push   $0x0
  pushl $138
  102402:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102407:	e9 e8 fa ff ff       	jmp    101ef4 <__alltraps>

0010240c <vector139>:
.globl vector139
vector139:
  pushl $0
  10240c:	6a 00                	push   $0x0
  pushl $139
  10240e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102413:	e9 dc fa ff ff       	jmp    101ef4 <__alltraps>

00102418 <vector140>:
.globl vector140
vector140:
  pushl $0
  102418:	6a 00                	push   $0x0
  pushl $140
  10241a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10241f:	e9 d0 fa ff ff       	jmp    101ef4 <__alltraps>

00102424 <vector141>:
.globl vector141
vector141:
  pushl $0
  102424:	6a 00                	push   $0x0
  pushl $141
  102426:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10242b:	e9 c4 fa ff ff       	jmp    101ef4 <__alltraps>

00102430 <vector142>:
.globl vector142
vector142:
  pushl $0
  102430:	6a 00                	push   $0x0
  pushl $142
  102432:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102437:	e9 b8 fa ff ff       	jmp    101ef4 <__alltraps>

0010243c <vector143>:
.globl vector143
vector143:
  pushl $0
  10243c:	6a 00                	push   $0x0
  pushl $143
  10243e:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102443:	e9 ac fa ff ff       	jmp    101ef4 <__alltraps>

00102448 <vector144>:
.globl vector144
vector144:
  pushl $0
  102448:	6a 00                	push   $0x0
  pushl $144
  10244a:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10244f:	e9 a0 fa ff ff       	jmp    101ef4 <__alltraps>

00102454 <vector145>:
.globl vector145
vector145:
  pushl $0
  102454:	6a 00                	push   $0x0
  pushl $145
  102456:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10245b:	e9 94 fa ff ff       	jmp    101ef4 <__alltraps>

00102460 <vector146>:
.globl vector146
vector146:
  pushl $0
  102460:	6a 00                	push   $0x0
  pushl $146
  102462:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102467:	e9 88 fa ff ff       	jmp    101ef4 <__alltraps>

0010246c <vector147>:
.globl vector147
vector147:
  pushl $0
  10246c:	6a 00                	push   $0x0
  pushl $147
  10246e:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102473:	e9 7c fa ff ff       	jmp    101ef4 <__alltraps>

00102478 <vector148>:
.globl vector148
vector148:
  pushl $0
  102478:	6a 00                	push   $0x0
  pushl $148
  10247a:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10247f:	e9 70 fa ff ff       	jmp    101ef4 <__alltraps>

00102484 <vector149>:
.globl vector149
vector149:
  pushl $0
  102484:	6a 00                	push   $0x0
  pushl $149
  102486:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10248b:	e9 64 fa ff ff       	jmp    101ef4 <__alltraps>

00102490 <vector150>:
.globl vector150
vector150:
  pushl $0
  102490:	6a 00                	push   $0x0
  pushl $150
  102492:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102497:	e9 58 fa ff ff       	jmp    101ef4 <__alltraps>

0010249c <vector151>:
.globl vector151
vector151:
  pushl $0
  10249c:	6a 00                	push   $0x0
  pushl $151
  10249e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1024a3:	e9 4c fa ff ff       	jmp    101ef4 <__alltraps>

001024a8 <vector152>:
.globl vector152
vector152:
  pushl $0
  1024a8:	6a 00                	push   $0x0
  pushl $152
  1024aa:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1024af:	e9 40 fa ff ff       	jmp    101ef4 <__alltraps>

001024b4 <vector153>:
.globl vector153
vector153:
  pushl $0
  1024b4:	6a 00                	push   $0x0
  pushl $153
  1024b6:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1024bb:	e9 34 fa ff ff       	jmp    101ef4 <__alltraps>

001024c0 <vector154>:
.globl vector154
vector154:
  pushl $0
  1024c0:	6a 00                	push   $0x0
  pushl $154
  1024c2:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1024c7:	e9 28 fa ff ff       	jmp    101ef4 <__alltraps>

001024cc <vector155>:
.globl vector155
vector155:
  pushl $0
  1024cc:	6a 00                	push   $0x0
  pushl $155
  1024ce:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1024d3:	e9 1c fa ff ff       	jmp    101ef4 <__alltraps>

001024d8 <vector156>:
.globl vector156
vector156:
  pushl $0
  1024d8:	6a 00                	push   $0x0
  pushl $156
  1024da:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1024df:	e9 10 fa ff ff       	jmp    101ef4 <__alltraps>

001024e4 <vector157>:
.globl vector157
vector157:
  pushl $0
  1024e4:	6a 00                	push   $0x0
  pushl $157
  1024e6:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1024eb:	e9 04 fa ff ff       	jmp    101ef4 <__alltraps>

001024f0 <vector158>:
.globl vector158
vector158:
  pushl $0
  1024f0:	6a 00                	push   $0x0
  pushl $158
  1024f2:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1024f7:	e9 f8 f9 ff ff       	jmp    101ef4 <__alltraps>

001024fc <vector159>:
.globl vector159
vector159:
  pushl $0
  1024fc:	6a 00                	push   $0x0
  pushl $159
  1024fe:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102503:	e9 ec f9 ff ff       	jmp    101ef4 <__alltraps>

00102508 <vector160>:
.globl vector160
vector160:
  pushl $0
  102508:	6a 00                	push   $0x0
  pushl $160
  10250a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10250f:	e9 e0 f9 ff ff       	jmp    101ef4 <__alltraps>

00102514 <vector161>:
.globl vector161
vector161:
  pushl $0
  102514:	6a 00                	push   $0x0
  pushl $161
  102516:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10251b:	e9 d4 f9 ff ff       	jmp    101ef4 <__alltraps>

00102520 <vector162>:
.globl vector162
vector162:
  pushl $0
  102520:	6a 00                	push   $0x0
  pushl $162
  102522:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102527:	e9 c8 f9 ff ff       	jmp    101ef4 <__alltraps>

0010252c <vector163>:
.globl vector163
vector163:
  pushl $0
  10252c:	6a 00                	push   $0x0
  pushl $163
  10252e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102533:	e9 bc f9 ff ff       	jmp    101ef4 <__alltraps>

00102538 <vector164>:
.globl vector164
vector164:
  pushl $0
  102538:	6a 00                	push   $0x0
  pushl $164
  10253a:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10253f:	e9 b0 f9 ff ff       	jmp    101ef4 <__alltraps>

00102544 <vector165>:
.globl vector165
vector165:
  pushl $0
  102544:	6a 00                	push   $0x0
  pushl $165
  102546:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10254b:	e9 a4 f9 ff ff       	jmp    101ef4 <__alltraps>

00102550 <vector166>:
.globl vector166
vector166:
  pushl $0
  102550:	6a 00                	push   $0x0
  pushl $166
  102552:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102557:	e9 98 f9 ff ff       	jmp    101ef4 <__alltraps>

0010255c <vector167>:
.globl vector167
vector167:
  pushl $0
  10255c:	6a 00                	push   $0x0
  pushl $167
  10255e:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102563:	e9 8c f9 ff ff       	jmp    101ef4 <__alltraps>

00102568 <vector168>:
.globl vector168
vector168:
  pushl $0
  102568:	6a 00                	push   $0x0
  pushl $168
  10256a:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10256f:	e9 80 f9 ff ff       	jmp    101ef4 <__alltraps>

00102574 <vector169>:
.globl vector169
vector169:
  pushl $0
  102574:	6a 00                	push   $0x0
  pushl $169
  102576:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10257b:	e9 74 f9 ff ff       	jmp    101ef4 <__alltraps>

00102580 <vector170>:
.globl vector170
vector170:
  pushl $0
  102580:	6a 00                	push   $0x0
  pushl $170
  102582:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102587:	e9 68 f9 ff ff       	jmp    101ef4 <__alltraps>

0010258c <vector171>:
.globl vector171
vector171:
  pushl $0
  10258c:	6a 00                	push   $0x0
  pushl $171
  10258e:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102593:	e9 5c f9 ff ff       	jmp    101ef4 <__alltraps>

00102598 <vector172>:
.globl vector172
vector172:
  pushl $0
  102598:	6a 00                	push   $0x0
  pushl $172
  10259a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10259f:	e9 50 f9 ff ff       	jmp    101ef4 <__alltraps>

001025a4 <vector173>:
.globl vector173
vector173:
  pushl $0
  1025a4:	6a 00                	push   $0x0
  pushl $173
  1025a6:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1025ab:	e9 44 f9 ff ff       	jmp    101ef4 <__alltraps>

001025b0 <vector174>:
.globl vector174
vector174:
  pushl $0
  1025b0:	6a 00                	push   $0x0
  pushl $174
  1025b2:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1025b7:	e9 38 f9 ff ff       	jmp    101ef4 <__alltraps>

001025bc <vector175>:
.globl vector175
vector175:
  pushl $0
  1025bc:	6a 00                	push   $0x0
  pushl $175
  1025be:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1025c3:	e9 2c f9 ff ff       	jmp    101ef4 <__alltraps>

001025c8 <vector176>:
.globl vector176
vector176:
  pushl $0
  1025c8:	6a 00                	push   $0x0
  pushl $176
  1025ca:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1025cf:	e9 20 f9 ff ff       	jmp    101ef4 <__alltraps>

001025d4 <vector177>:
.globl vector177
vector177:
  pushl $0
  1025d4:	6a 00                	push   $0x0
  pushl $177
  1025d6:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1025db:	e9 14 f9 ff ff       	jmp    101ef4 <__alltraps>

001025e0 <vector178>:
.globl vector178
vector178:
  pushl $0
  1025e0:	6a 00                	push   $0x0
  pushl $178
  1025e2:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1025e7:	e9 08 f9 ff ff       	jmp    101ef4 <__alltraps>

001025ec <vector179>:
.globl vector179
vector179:
  pushl $0
  1025ec:	6a 00                	push   $0x0
  pushl $179
  1025ee:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1025f3:	e9 fc f8 ff ff       	jmp    101ef4 <__alltraps>

001025f8 <vector180>:
.globl vector180
vector180:
  pushl $0
  1025f8:	6a 00                	push   $0x0
  pushl $180
  1025fa:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1025ff:	e9 f0 f8 ff ff       	jmp    101ef4 <__alltraps>

00102604 <vector181>:
.globl vector181
vector181:
  pushl $0
  102604:	6a 00                	push   $0x0
  pushl $181
  102606:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10260b:	e9 e4 f8 ff ff       	jmp    101ef4 <__alltraps>

00102610 <vector182>:
.globl vector182
vector182:
  pushl $0
  102610:	6a 00                	push   $0x0
  pushl $182
  102612:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102617:	e9 d8 f8 ff ff       	jmp    101ef4 <__alltraps>

0010261c <vector183>:
.globl vector183
vector183:
  pushl $0
  10261c:	6a 00                	push   $0x0
  pushl $183
  10261e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102623:	e9 cc f8 ff ff       	jmp    101ef4 <__alltraps>

00102628 <vector184>:
.globl vector184
vector184:
  pushl $0
  102628:	6a 00                	push   $0x0
  pushl $184
  10262a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10262f:	e9 c0 f8 ff ff       	jmp    101ef4 <__alltraps>

00102634 <vector185>:
.globl vector185
vector185:
  pushl $0
  102634:	6a 00                	push   $0x0
  pushl $185
  102636:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10263b:	e9 b4 f8 ff ff       	jmp    101ef4 <__alltraps>

00102640 <vector186>:
.globl vector186
vector186:
  pushl $0
  102640:	6a 00                	push   $0x0
  pushl $186
  102642:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102647:	e9 a8 f8 ff ff       	jmp    101ef4 <__alltraps>

0010264c <vector187>:
.globl vector187
vector187:
  pushl $0
  10264c:	6a 00                	push   $0x0
  pushl $187
  10264e:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102653:	e9 9c f8 ff ff       	jmp    101ef4 <__alltraps>

00102658 <vector188>:
.globl vector188
vector188:
  pushl $0
  102658:	6a 00                	push   $0x0
  pushl $188
  10265a:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10265f:	e9 90 f8 ff ff       	jmp    101ef4 <__alltraps>

00102664 <vector189>:
.globl vector189
vector189:
  pushl $0
  102664:	6a 00                	push   $0x0
  pushl $189
  102666:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10266b:	e9 84 f8 ff ff       	jmp    101ef4 <__alltraps>

00102670 <vector190>:
.globl vector190
vector190:
  pushl $0
  102670:	6a 00                	push   $0x0
  pushl $190
  102672:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102677:	e9 78 f8 ff ff       	jmp    101ef4 <__alltraps>

0010267c <vector191>:
.globl vector191
vector191:
  pushl $0
  10267c:	6a 00                	push   $0x0
  pushl $191
  10267e:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102683:	e9 6c f8 ff ff       	jmp    101ef4 <__alltraps>

00102688 <vector192>:
.globl vector192
vector192:
  pushl $0
  102688:	6a 00                	push   $0x0
  pushl $192
  10268a:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10268f:	e9 60 f8 ff ff       	jmp    101ef4 <__alltraps>

00102694 <vector193>:
.globl vector193
vector193:
  pushl $0
  102694:	6a 00                	push   $0x0
  pushl $193
  102696:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10269b:	e9 54 f8 ff ff       	jmp    101ef4 <__alltraps>

001026a0 <vector194>:
.globl vector194
vector194:
  pushl $0
  1026a0:	6a 00                	push   $0x0
  pushl $194
  1026a2:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1026a7:	e9 48 f8 ff ff       	jmp    101ef4 <__alltraps>

001026ac <vector195>:
.globl vector195
vector195:
  pushl $0
  1026ac:	6a 00                	push   $0x0
  pushl $195
  1026ae:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1026b3:	e9 3c f8 ff ff       	jmp    101ef4 <__alltraps>

001026b8 <vector196>:
.globl vector196
vector196:
  pushl $0
  1026b8:	6a 00                	push   $0x0
  pushl $196
  1026ba:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1026bf:	e9 30 f8 ff ff       	jmp    101ef4 <__alltraps>

001026c4 <vector197>:
.globl vector197
vector197:
  pushl $0
  1026c4:	6a 00                	push   $0x0
  pushl $197
  1026c6:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1026cb:	e9 24 f8 ff ff       	jmp    101ef4 <__alltraps>

001026d0 <vector198>:
.globl vector198
vector198:
  pushl $0
  1026d0:	6a 00                	push   $0x0
  pushl $198
  1026d2:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1026d7:	e9 18 f8 ff ff       	jmp    101ef4 <__alltraps>

001026dc <vector199>:
.globl vector199
vector199:
  pushl $0
  1026dc:	6a 00                	push   $0x0
  pushl $199
  1026de:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1026e3:	e9 0c f8 ff ff       	jmp    101ef4 <__alltraps>

001026e8 <vector200>:
.globl vector200
vector200:
  pushl $0
  1026e8:	6a 00                	push   $0x0
  pushl $200
  1026ea:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1026ef:	e9 00 f8 ff ff       	jmp    101ef4 <__alltraps>

001026f4 <vector201>:
.globl vector201
vector201:
  pushl $0
  1026f4:	6a 00                	push   $0x0
  pushl $201
  1026f6:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1026fb:	e9 f4 f7 ff ff       	jmp    101ef4 <__alltraps>

00102700 <vector202>:
.globl vector202
vector202:
  pushl $0
  102700:	6a 00                	push   $0x0
  pushl $202
  102702:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102707:	e9 e8 f7 ff ff       	jmp    101ef4 <__alltraps>

0010270c <vector203>:
.globl vector203
vector203:
  pushl $0
  10270c:	6a 00                	push   $0x0
  pushl $203
  10270e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102713:	e9 dc f7 ff ff       	jmp    101ef4 <__alltraps>

00102718 <vector204>:
.globl vector204
vector204:
  pushl $0
  102718:	6a 00                	push   $0x0
  pushl $204
  10271a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10271f:	e9 d0 f7 ff ff       	jmp    101ef4 <__alltraps>

00102724 <vector205>:
.globl vector205
vector205:
  pushl $0
  102724:	6a 00                	push   $0x0
  pushl $205
  102726:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10272b:	e9 c4 f7 ff ff       	jmp    101ef4 <__alltraps>

00102730 <vector206>:
.globl vector206
vector206:
  pushl $0
  102730:	6a 00                	push   $0x0
  pushl $206
  102732:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102737:	e9 b8 f7 ff ff       	jmp    101ef4 <__alltraps>

0010273c <vector207>:
.globl vector207
vector207:
  pushl $0
  10273c:	6a 00                	push   $0x0
  pushl $207
  10273e:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102743:	e9 ac f7 ff ff       	jmp    101ef4 <__alltraps>

00102748 <vector208>:
.globl vector208
vector208:
  pushl $0
  102748:	6a 00                	push   $0x0
  pushl $208
  10274a:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10274f:	e9 a0 f7 ff ff       	jmp    101ef4 <__alltraps>

00102754 <vector209>:
.globl vector209
vector209:
  pushl $0
  102754:	6a 00                	push   $0x0
  pushl $209
  102756:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10275b:	e9 94 f7 ff ff       	jmp    101ef4 <__alltraps>

00102760 <vector210>:
.globl vector210
vector210:
  pushl $0
  102760:	6a 00                	push   $0x0
  pushl $210
  102762:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102767:	e9 88 f7 ff ff       	jmp    101ef4 <__alltraps>

0010276c <vector211>:
.globl vector211
vector211:
  pushl $0
  10276c:	6a 00                	push   $0x0
  pushl $211
  10276e:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102773:	e9 7c f7 ff ff       	jmp    101ef4 <__alltraps>

00102778 <vector212>:
.globl vector212
vector212:
  pushl $0
  102778:	6a 00                	push   $0x0
  pushl $212
  10277a:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10277f:	e9 70 f7 ff ff       	jmp    101ef4 <__alltraps>

00102784 <vector213>:
.globl vector213
vector213:
  pushl $0
  102784:	6a 00                	push   $0x0
  pushl $213
  102786:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10278b:	e9 64 f7 ff ff       	jmp    101ef4 <__alltraps>

00102790 <vector214>:
.globl vector214
vector214:
  pushl $0
  102790:	6a 00                	push   $0x0
  pushl $214
  102792:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102797:	e9 58 f7 ff ff       	jmp    101ef4 <__alltraps>

0010279c <vector215>:
.globl vector215
vector215:
  pushl $0
  10279c:	6a 00                	push   $0x0
  pushl $215
  10279e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1027a3:	e9 4c f7 ff ff       	jmp    101ef4 <__alltraps>

001027a8 <vector216>:
.globl vector216
vector216:
  pushl $0
  1027a8:	6a 00                	push   $0x0
  pushl $216
  1027aa:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1027af:	e9 40 f7 ff ff       	jmp    101ef4 <__alltraps>

001027b4 <vector217>:
.globl vector217
vector217:
  pushl $0
  1027b4:	6a 00                	push   $0x0
  pushl $217
  1027b6:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1027bb:	e9 34 f7 ff ff       	jmp    101ef4 <__alltraps>

001027c0 <vector218>:
.globl vector218
vector218:
  pushl $0
  1027c0:	6a 00                	push   $0x0
  pushl $218
  1027c2:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1027c7:	e9 28 f7 ff ff       	jmp    101ef4 <__alltraps>

001027cc <vector219>:
.globl vector219
vector219:
  pushl $0
  1027cc:	6a 00                	push   $0x0
  pushl $219
  1027ce:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1027d3:	e9 1c f7 ff ff       	jmp    101ef4 <__alltraps>

001027d8 <vector220>:
.globl vector220
vector220:
  pushl $0
  1027d8:	6a 00                	push   $0x0
  pushl $220
  1027da:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1027df:	e9 10 f7 ff ff       	jmp    101ef4 <__alltraps>

001027e4 <vector221>:
.globl vector221
vector221:
  pushl $0
  1027e4:	6a 00                	push   $0x0
  pushl $221
  1027e6:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1027eb:	e9 04 f7 ff ff       	jmp    101ef4 <__alltraps>

001027f0 <vector222>:
.globl vector222
vector222:
  pushl $0
  1027f0:	6a 00                	push   $0x0
  pushl $222
  1027f2:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1027f7:	e9 f8 f6 ff ff       	jmp    101ef4 <__alltraps>

001027fc <vector223>:
.globl vector223
vector223:
  pushl $0
  1027fc:	6a 00                	push   $0x0
  pushl $223
  1027fe:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102803:	e9 ec f6 ff ff       	jmp    101ef4 <__alltraps>

00102808 <vector224>:
.globl vector224
vector224:
  pushl $0
  102808:	6a 00                	push   $0x0
  pushl $224
  10280a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10280f:	e9 e0 f6 ff ff       	jmp    101ef4 <__alltraps>

00102814 <vector225>:
.globl vector225
vector225:
  pushl $0
  102814:	6a 00                	push   $0x0
  pushl $225
  102816:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10281b:	e9 d4 f6 ff ff       	jmp    101ef4 <__alltraps>

00102820 <vector226>:
.globl vector226
vector226:
  pushl $0
  102820:	6a 00                	push   $0x0
  pushl $226
  102822:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102827:	e9 c8 f6 ff ff       	jmp    101ef4 <__alltraps>

0010282c <vector227>:
.globl vector227
vector227:
  pushl $0
  10282c:	6a 00                	push   $0x0
  pushl $227
  10282e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102833:	e9 bc f6 ff ff       	jmp    101ef4 <__alltraps>

00102838 <vector228>:
.globl vector228
vector228:
  pushl $0
  102838:	6a 00                	push   $0x0
  pushl $228
  10283a:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10283f:	e9 b0 f6 ff ff       	jmp    101ef4 <__alltraps>

00102844 <vector229>:
.globl vector229
vector229:
  pushl $0
  102844:	6a 00                	push   $0x0
  pushl $229
  102846:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10284b:	e9 a4 f6 ff ff       	jmp    101ef4 <__alltraps>

00102850 <vector230>:
.globl vector230
vector230:
  pushl $0
  102850:	6a 00                	push   $0x0
  pushl $230
  102852:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102857:	e9 98 f6 ff ff       	jmp    101ef4 <__alltraps>

0010285c <vector231>:
.globl vector231
vector231:
  pushl $0
  10285c:	6a 00                	push   $0x0
  pushl $231
  10285e:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102863:	e9 8c f6 ff ff       	jmp    101ef4 <__alltraps>

00102868 <vector232>:
.globl vector232
vector232:
  pushl $0
  102868:	6a 00                	push   $0x0
  pushl $232
  10286a:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10286f:	e9 80 f6 ff ff       	jmp    101ef4 <__alltraps>

00102874 <vector233>:
.globl vector233
vector233:
  pushl $0
  102874:	6a 00                	push   $0x0
  pushl $233
  102876:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10287b:	e9 74 f6 ff ff       	jmp    101ef4 <__alltraps>

00102880 <vector234>:
.globl vector234
vector234:
  pushl $0
  102880:	6a 00                	push   $0x0
  pushl $234
  102882:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102887:	e9 68 f6 ff ff       	jmp    101ef4 <__alltraps>

0010288c <vector235>:
.globl vector235
vector235:
  pushl $0
  10288c:	6a 00                	push   $0x0
  pushl $235
  10288e:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102893:	e9 5c f6 ff ff       	jmp    101ef4 <__alltraps>

00102898 <vector236>:
.globl vector236
vector236:
  pushl $0
  102898:	6a 00                	push   $0x0
  pushl $236
  10289a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10289f:	e9 50 f6 ff ff       	jmp    101ef4 <__alltraps>

001028a4 <vector237>:
.globl vector237
vector237:
  pushl $0
  1028a4:	6a 00                	push   $0x0
  pushl $237
  1028a6:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1028ab:	e9 44 f6 ff ff       	jmp    101ef4 <__alltraps>

001028b0 <vector238>:
.globl vector238
vector238:
  pushl $0
  1028b0:	6a 00                	push   $0x0
  pushl $238
  1028b2:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1028b7:	e9 38 f6 ff ff       	jmp    101ef4 <__alltraps>

001028bc <vector239>:
.globl vector239
vector239:
  pushl $0
  1028bc:	6a 00                	push   $0x0
  pushl $239
  1028be:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1028c3:	e9 2c f6 ff ff       	jmp    101ef4 <__alltraps>

001028c8 <vector240>:
.globl vector240
vector240:
  pushl $0
  1028c8:	6a 00                	push   $0x0
  pushl $240
  1028ca:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1028cf:	e9 20 f6 ff ff       	jmp    101ef4 <__alltraps>

001028d4 <vector241>:
.globl vector241
vector241:
  pushl $0
  1028d4:	6a 00                	push   $0x0
  pushl $241
  1028d6:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1028db:	e9 14 f6 ff ff       	jmp    101ef4 <__alltraps>

001028e0 <vector242>:
.globl vector242
vector242:
  pushl $0
  1028e0:	6a 00                	push   $0x0
  pushl $242
  1028e2:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1028e7:	e9 08 f6 ff ff       	jmp    101ef4 <__alltraps>

001028ec <vector243>:
.globl vector243
vector243:
  pushl $0
  1028ec:	6a 00                	push   $0x0
  pushl $243
  1028ee:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1028f3:	e9 fc f5 ff ff       	jmp    101ef4 <__alltraps>

001028f8 <vector244>:
.globl vector244
vector244:
  pushl $0
  1028f8:	6a 00                	push   $0x0
  pushl $244
  1028fa:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1028ff:	e9 f0 f5 ff ff       	jmp    101ef4 <__alltraps>

00102904 <vector245>:
.globl vector245
vector245:
  pushl $0
  102904:	6a 00                	push   $0x0
  pushl $245
  102906:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10290b:	e9 e4 f5 ff ff       	jmp    101ef4 <__alltraps>

00102910 <vector246>:
.globl vector246
vector246:
  pushl $0
  102910:	6a 00                	push   $0x0
  pushl $246
  102912:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102917:	e9 d8 f5 ff ff       	jmp    101ef4 <__alltraps>

0010291c <vector247>:
.globl vector247
vector247:
  pushl $0
  10291c:	6a 00                	push   $0x0
  pushl $247
  10291e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102923:	e9 cc f5 ff ff       	jmp    101ef4 <__alltraps>

00102928 <vector248>:
.globl vector248
vector248:
  pushl $0
  102928:	6a 00                	push   $0x0
  pushl $248
  10292a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10292f:	e9 c0 f5 ff ff       	jmp    101ef4 <__alltraps>

00102934 <vector249>:
.globl vector249
vector249:
  pushl $0
  102934:	6a 00                	push   $0x0
  pushl $249
  102936:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10293b:	e9 b4 f5 ff ff       	jmp    101ef4 <__alltraps>

00102940 <vector250>:
.globl vector250
vector250:
  pushl $0
  102940:	6a 00                	push   $0x0
  pushl $250
  102942:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102947:	e9 a8 f5 ff ff       	jmp    101ef4 <__alltraps>

0010294c <vector251>:
.globl vector251
vector251:
  pushl $0
  10294c:	6a 00                	push   $0x0
  pushl $251
  10294e:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102953:	e9 9c f5 ff ff       	jmp    101ef4 <__alltraps>

00102958 <vector252>:
.globl vector252
vector252:
  pushl $0
  102958:	6a 00                	push   $0x0
  pushl $252
  10295a:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  10295f:	e9 90 f5 ff ff       	jmp    101ef4 <__alltraps>

00102964 <vector253>:
.globl vector253
vector253:
  pushl $0
  102964:	6a 00                	push   $0x0
  pushl $253
  102966:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10296b:	e9 84 f5 ff ff       	jmp    101ef4 <__alltraps>

00102970 <vector254>:
.globl vector254
vector254:
  pushl $0
  102970:	6a 00                	push   $0x0
  pushl $254
  102972:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102977:	e9 78 f5 ff ff       	jmp    101ef4 <__alltraps>

0010297c <vector255>:
.globl vector255
vector255:
  pushl $0
  10297c:	6a 00                	push   $0x0
  pushl $255
  10297e:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102983:	e9 6c f5 ff ff       	jmp    101ef4 <__alltraps>

00102988 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102988:	55                   	push   %ebp
  102989:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10298b:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  102991:	8b 45 08             	mov    0x8(%ebp),%eax
  102994:	29 d0                	sub    %edx,%eax
  102996:	c1 f8 02             	sar    $0x2,%eax
  102999:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10299f:	5d                   	pop    %ebp
  1029a0:	c3                   	ret    

001029a1 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1029a1:	55                   	push   %ebp
  1029a2:	89 e5                	mov    %esp,%ebp
  1029a4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1029a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1029aa:	89 04 24             	mov    %eax,(%esp)
  1029ad:	e8 d6 ff ff ff       	call   102988 <page2ppn>
  1029b2:	c1 e0 0c             	shl    $0xc,%eax
}
  1029b5:	89 ec                	mov    %ebp,%esp
  1029b7:	5d                   	pop    %ebp
  1029b8:	c3                   	ret    

001029b9 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  1029b9:	55                   	push   %ebp
  1029ba:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1029bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1029bf:	8b 00                	mov    (%eax),%eax
}
  1029c1:	5d                   	pop    %ebp
  1029c2:	c3                   	ret    

001029c3 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029c3:	55                   	push   %ebp
  1029c4:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029cc:	89 10                	mov    %edx,(%eax)
}
  1029ce:	90                   	nop
  1029cf:	5d                   	pop    %ebp
  1029d0:	c3                   	ret    

001029d1 <default_init>:
//free_list本身不会对应Page结构
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1029d1:	55                   	push   %ebp
  1029d2:	89 e5                	mov    %esp,%ebp
  1029d4:	83 ec 10             	sub    $0x10,%esp
  1029d7:	c7 45 fc 80 ce 11 00 	movl   $0x11ce80,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1029de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1029e4:	89 50 04             	mov    %edx,0x4(%eax)
  1029e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029ea:	8b 50 04             	mov    0x4(%eax),%edx
  1029ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029f0:	89 10                	mov    %edx,(%eax)
}
  1029f2:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
  1029f3:	c7 05 88 ce 11 00 00 	movl   $0x0,0x11ce88
  1029fa:	00 00 00 
}
  1029fd:	90                   	nop
  1029fe:	89 ec                	mov    %ebp,%esp
  102a00:	5d                   	pop    %ebp
  102a01:	c3                   	ret    

00102a02 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  102a02:	55                   	push   %ebp
  102a03:	89 e5                	mov    %esp,%ebp
  102a05:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  102a08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102a0c:	75 24                	jne    102a32 <default_init_memmap+0x30>
  102a0e:	c7 44 24 0c 10 69 10 	movl   $0x106910,0xc(%esp)
  102a15:	00 
  102a16:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  102a1d:	00 
  102a1e:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  102a25:	00 
  102a26:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  102a2d:	e8 cd e2 ff ff       	call   100cff <__panic>
    struct Page *p = base;
  102a32:	8b 45 08             	mov    0x8(%ebp),%eax
  102a35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //相邻的page结构在内存上也是相邻的
    for (; p != base + n; p ++) {
  102a38:	e9 97 00 00 00       	jmp    102ad4 <default_init_memmap+0xd2>
        //检查是否被保留,是否有问题，
        assert(PageReserved(p));
  102a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a40:	83 c0 04             	add    $0x4,%eax
  102a43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102a4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102a53:	0f a3 10             	bt     %edx,(%eax)
  102a56:	19 c0                	sbb    %eax,%eax
  102a58:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102a5b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102a5f:	0f 95 c0             	setne  %al
  102a62:	0f b6 c0             	movzbl %al,%eax
  102a65:	85 c0                	test   %eax,%eax
  102a67:	75 24                	jne    102a8d <default_init_memmap+0x8b>
  102a69:	c7 44 24 0c 41 69 10 	movl   $0x106941,0xc(%esp)
  102a70:	00 
  102a71:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  102a78:	00 
  102a79:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  102a80:	00 
  102a81:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  102a88:	e8 72 e2 ff ff       	call   100cff <__panic>
        p->flags = p->property = 0;
  102a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a90:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a9a:	8b 50 08             	mov    0x8(%eax),%edx
  102a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aa0:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102aa3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102aaa:	00 
  102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aae:	89 04 24             	mov    %eax,(%esp)
  102ab1:	e8 0d ff ff ff       	call   1029c3 <set_page_ref>
        //my_add
        SetPageProperty(p);
  102ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ab9:	83 c0 04             	add    $0x4,%eax
  102abc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102ac3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ac9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102acc:	0f ab 10             	bts    %edx,(%eax)
}
  102acf:	90                   	nop
    for (; p != base + n; p ++) {
  102ad0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ad7:	89 d0                	mov    %edx,%eax
  102ad9:	c1 e0 02             	shl    $0x2,%eax
  102adc:	01 d0                	add    %edx,%eax
  102ade:	c1 e0 02             	shl    $0x2,%eax
  102ae1:	89 c2                	mov    %eax,%edx
  102ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae6:	01 d0                	add    %edx,%eax
  102ae8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102aeb:	0f 85 4c ff ff ff    	jne    102a3d <default_init_memmap+0x3b>

    }
    base->property = n;
  102af1:	8b 45 08             	mov    0x8(%ebp),%eax
  102af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  102af7:	89 50 08             	mov    %edx,0x8(%eax)
    //置位标志位代表可以分配
   //SetPageProperty(base);
    nr_free += n;
  102afa:	8b 15 88 ce 11 00    	mov    0x11ce88,%edx
  102b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b03:	01 d0                	add    %edx,%eax
  102b05:	a3 88 ce 11 00       	mov    %eax,0x11ce88
    list_add(&free_list, &(base->page_link));
  102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0d:	83 c0 0c             	add    $0xc,%eax
  102b10:	c7 45 dc 80 ce 11 00 	movl   $0x11ce80,-0x24(%ebp)
  102b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
  102b1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  102b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b23:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102b26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102b29:	8b 40 04             	mov    0x4(%eax),%eax
  102b2c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b2f:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102b32:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b35:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102b38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * the prev/next entries already!
 * */
//前面带有两个横杠代表为各种调用函数的“基函数”，实质上不会调用，为了保持函数具有一个比较好的封装性。
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b3e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b41:	89 10                	mov    %edx,(%eax)
  102b43:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b46:	8b 10                	mov    (%eax),%edx
  102b48:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b4b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b4e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b51:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102b54:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b57:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b5a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b5d:	89 10                	mov    %edx,(%eax)
}
  102b5f:	90                   	nop
}
  102b60:	90                   	nop
}
  102b61:	90                   	nop
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
  102b62:	90                   	nop
  102b63:	89 ec                	mov    %ebp,%esp
  102b65:	5d                   	pop    %ebp
  102b66:	c3                   	ret    

00102b67 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102b67:	55                   	push   %ebp
  102b68:	89 e5                	mov    %esp,%ebp
  102b6a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102b6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102b71:	75 24                	jne    102b97 <default_alloc_pages+0x30>
  102b73:	c7 44 24 0c 10 69 10 	movl   $0x106910,0xc(%esp)
  102b7a:	00 
  102b7b:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  102b82:	00 
  102b83:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  102b8a:	00 
  102b8b:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  102b92:	e8 68 e1 ff ff       	call   100cff <__panic>
    if (n > nr_free) {
  102b97:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102b9c:	39 45 08             	cmp    %eax,0x8(%ebp)
  102b9f:	76 0a                	jbe    102bab <default_alloc_pages+0x44>
        return NULL;
  102ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  102ba6:	e9 82 01 00 00       	jmp    102d2d <default_alloc_pages+0x1c6>
    }
    struct Page *page = NULL;
  102bab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102bb2:	c7 45 f0 80 ce 11 00 	movl   $0x11ce80,-0x10(%ebp)

    //遍历free_list
    while ((le = list_next(le)) != &free_list) {
  102bb9:	eb 1c                	jmp    102bd7 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bbe:	83 e8 0c             	sub    $0xc,%eax
  102bc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
  102bc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bc7:	8b 40 08             	mov    0x8(%eax),%eax
  102bca:	39 45 08             	cmp    %eax,0x8(%ebp)
  102bcd:	77 08                	ja     102bd7 <default_alloc_pages+0x70>
            page = p;
  102bcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102bd5:	eb 18                	jmp    102bef <default_alloc_pages+0x88>
  102bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bda:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
  102bdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102be0:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  102be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102be6:	81 7d f0 80 ce 11 00 	cmpl   $0x11ce80,-0x10(%ebp)
  102bed:	75 cc                	jne    102bbb <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  102bef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102bf3:	0f 84 31 01 00 00    	je     102d2a <default_alloc_pages+0x1c3>
        struct Page *temp=page;
  102bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for(;temp!=page+n;temp++)
  102bff:	eb 1e                	jmp    102c1f <default_alloc_pages+0xb8>
            ClearPageProperty(temp);
  102c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c04:	83 c0 04             	add    $0x4,%eax
  102c07:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  102c0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c11:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102c14:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c17:	0f b3 10             	btr    %edx,(%eax)
}
  102c1a:	90                   	nop
        for(;temp!=page+n;temp++)
  102c1b:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
  102c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  102c22:	89 d0                	mov    %edx,%eax
  102c24:	c1 e0 02             	shl    $0x2,%eax
  102c27:	01 d0                	add    %edx,%eax
  102c29:	c1 e0 02             	shl    $0x2,%eax
  102c2c:	89 c2                	mov    %eax,%edx
  102c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c31:	01 d0                	add    %edx,%eax
  102c33:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  102c36:	75 c9                	jne    102c01 <default_alloc_pages+0x9a>
        if (page->property > n) {
  102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c3b:	8b 40 08             	mov    0x8(%eax),%eax
  102c3e:	39 45 08             	cmp    %eax,0x8(%ebp)
  102c41:	0f 83 8f 00 00 00    	jae    102cd6 <default_alloc_pages+0x16f>
            struct Page *p = page + n;
  102c47:	8b 55 08             	mov    0x8(%ebp),%edx
  102c4a:	89 d0                	mov    %edx,%eax
  102c4c:	c1 e0 02             	shl    $0x2,%eax
  102c4f:	01 d0                	add    %edx,%eax
  102c51:	c1 e0 02             	shl    $0x2,%eax
  102c54:	89 c2                	mov    %eax,%edx
  102c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c59:	01 d0                	add    %edx,%eax
  102c5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
  102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c61:	8b 40 08             	mov    0x8(%eax),%eax
  102c64:	2b 45 08             	sub    0x8(%ebp),%eax
  102c67:	89 c2                	mov    %eax,%edx
  102c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c6c:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102c6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c72:	83 c0 04             	add    $0x4,%eax
  102c75:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  102c7c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c7f:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102c82:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102c85:	0f ab 10             	bts    %edx,(%eax)
}
  102c88:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
  102c89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c8c:	83 c0 0c             	add    $0xc,%eax
  102c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102c92:	83 c2 0c             	add    $0xc,%edx
  102c95:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102c98:	89 45 d0             	mov    %eax,-0x30(%ebp)
    __list_add(elm, listelm, listelm->next);
  102c9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102c9e:	8b 40 04             	mov    0x4(%eax),%eax
  102ca1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102ca4:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102ca7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102caa:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102cad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
  102cb0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102cb3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102cb6:	89 10                	mov    %edx,(%eax)
  102cb8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102cbb:	8b 10                	mov    (%eax),%edx
  102cbd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102cc0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102cc3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102cc6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102cc9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102ccc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102ccf:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102cd2:	89 10                	mov    %edx,(%eax)
}
  102cd4:	90                   	nop
}
  102cd5:	90                   	nop
        }
        list_del(&(page->page_link));
  102cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cd9:	83 c0 0c             	add    $0xc,%eax
  102cdc:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  102cdf:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102ce2:	8b 40 04             	mov    0x4(%eax),%eax
  102ce5:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102ce8:	8b 12                	mov    (%edx),%edx
  102cea:	89 55 ac             	mov    %edx,-0x54(%ebp)
  102ced:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102cf0:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102cf3:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102cf6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102cf9:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102cfc:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102cff:	89 10                	mov    %edx,(%eax)
}
  102d01:	90                   	nop
}
  102d02:	90                   	nop
        nr_free -= n;
  102d03:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102d08:	2b 45 08             	sub    0x8(%ebp),%eax
  102d0b:	a3 88 ce 11 00       	mov    %eax,0x11ce88
        ClearPageProperty(page);
  102d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d13:	83 c0 04             	add    $0x4,%eax
  102d16:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102d1d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d20:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102d23:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102d26:	0f b3 10             	btr    %edx,(%eax)
}
  102d29:	90                   	nop
    }
    return page;
  102d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;*/
}
  102d2d:	89 ec                	mov    %ebp,%esp
  102d2f:	5d                   	pop    %ebp
  102d30:	c3                   	ret    

00102d31 <merge_backward>:

static bool merge_backward(struct  Page*base)
{
  102d31:	55                   	push   %ebp
  102d32:	89 e5                	mov    %esp,%ebp
  102d34:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_next(&(base->page_link));
  102d37:	8b 45 08             	mov    0x8(%ebp),%eax
  102d3a:	83 c0 0c             	add    $0xc,%eax
  102d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->next;
  102d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d43:	8b 40 04             	mov    0x4(%eax),%eax
  102d46:	89 45 fc             	mov    %eax,-0x4(%ebp)
    //判断是否为头节点
    if (le==&free_list)
  102d49:	81 7d fc 80 ce 11 00 	cmpl   $0x11ce80,-0x4(%ebp)
  102d50:	75 0a                	jne    102d5c <merge_backward+0x2b>
    return 0;
  102d52:	b8 00 00 00 00       	mov    $0x0,%eax
  102d57:	e9 ac 00 00 00       	jmp    102e08 <merge_backward+0xd7>
    struct Page*p=le2page(le,page_link);
  102d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102d5f:	83 e8 0c             	sub    $0xc,%eax
  102d62:	89 45 f8             	mov    %eax,-0x8(%ebp)
    
    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
  102d65:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102d68:	83 c0 04             	add    $0x4,%eax
  102d6b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  102d72:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d75:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102d7b:	0f a3 10             	bt     %edx,(%eax)
  102d7e:	19 c0                	sbb    %eax,%eax
  102d80:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102d83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d87:	0f 95 c0             	setne  %al
  102d8a:	0f b6 c0             	movzbl %al,%eax
  102d8d:	85 c0                	test   %eax,%eax
  102d8f:	75 07                	jne    102d98 <merge_backward+0x67>
  102d91:	b8 00 00 00 00       	mov    $0x0,%eax
  102d96:	eb 70                	jmp    102e08 <merge_backward+0xd7>
    //判断地址是否连续
    if(base+base->property==p)
  102d98:	8b 45 08             	mov    0x8(%ebp),%eax
  102d9b:	8b 50 08             	mov    0x8(%eax),%edx
  102d9e:	89 d0                	mov    %edx,%eax
  102da0:	c1 e0 02             	shl    $0x2,%eax
  102da3:	01 d0                	add    %edx,%eax
  102da5:	c1 e0 02             	shl    $0x2,%eax
  102da8:	89 c2                	mov    %eax,%edx
  102daa:	8b 45 08             	mov    0x8(%ebp),%eax
  102dad:	01 d0                	add    %edx,%eax
  102daf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
  102db2:	75 4f                	jne    102e03 <merge_backward+0xd2>
    {
        base->property+=p->property;
  102db4:	8b 45 08             	mov    0x8(%ebp),%eax
  102db7:	8b 50 08             	mov    0x8(%eax),%edx
  102dba:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dbd:	8b 40 08             	mov    0x8(%eax),%eax
  102dc0:	01 c2                	add    %eax,%edx
  102dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc5:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
  102dc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dcb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ddb:	8b 40 04             	mov    0x4(%eax),%eax
  102dde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102de1:	8b 12                	mov    (%edx),%edx
  102de3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  102de6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
  102de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102def:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102df2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102df5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102df8:	89 10                	mov    %edx,(%eax)
}
  102dfa:	90                   	nop
}
  102dfb:	90                   	nop
        list_del(le);
        return 1;
  102dfc:	b8 01 00 00 00       	mov    $0x1,%eax
  102e01:	eb 05                	jmp    102e08 <merge_backward+0xd7>
        
    }
    else
    {
        return 0;
  102e03:	b8 00 00 00 00       	mov    $0x0,%eax
    }

}
  102e08:	89 ec                	mov    %ebp,%esp
  102e0a:	5d                   	pop    %ebp
  102e0b:	c3                   	ret    

00102e0c <merge_beforeward>:
static bool merge_beforeward(struct Page*base)
{
  102e0c:	55                   	push   %ebp
  102e0d:	89 e5                	mov    %esp,%ebp
  102e0f:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_prev(&(base->page_link));
  102e12:	8b 45 08             	mov    0x8(%ebp),%eax
  102e15:	83 c0 0c             	add    $0xc,%eax
  102e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->prev;
  102e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e1e:	8b 00                	mov    (%eax),%eax
  102e20:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le==&free_list)
  102e23:	81 7d fc 80 ce 11 00 	cmpl   $0x11ce80,-0x4(%ebp)
  102e2a:	75 0a                	jne    102e36 <merge_beforeward+0x2a>
    return 0;
  102e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  102e31:	e9 b5 00 00 00       	jmp    102eeb <merge_beforeward+0xdf>
    struct Page*p=le2page(le,page_link);
  102e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102e39:	83 e8 0c             	sub    $0xc,%eax
  102e3c:	89 45 f8             	mov    %eax,-0x8(%ebp)

    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
  102e3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e42:	83 c0 04             	add    $0x4,%eax
  102e45:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  102e4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102e4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e52:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102e55:	0f a3 10             	bt     %edx,(%eax)
  102e58:	19 c0                	sbb    %eax,%eax
  102e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102e5d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e61:	0f 95 c0             	setne  %al
  102e64:	0f b6 c0             	movzbl %al,%eax
  102e67:	85 c0                	test   %eax,%eax
  102e69:	75 07                	jne    102e72 <merge_beforeward+0x66>
  102e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  102e70:	eb 79                	jmp    102eeb <merge_beforeward+0xdf>
    //判断地址是否连续
    if(p+p->property==base)
  102e72:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e75:	8b 50 08             	mov    0x8(%eax),%edx
  102e78:	89 d0                	mov    %edx,%eax
  102e7a:	c1 e0 02             	shl    $0x2,%eax
  102e7d:	01 d0                	add    %edx,%eax
  102e7f:	c1 e0 02             	shl    $0x2,%eax
  102e82:	89 c2                	mov    %eax,%edx
  102e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e87:	01 d0                	add    %edx,%eax
  102e89:	39 45 08             	cmp    %eax,0x8(%ebp)
  102e8c:	75 58                	jne    102ee6 <merge_beforeward+0xda>
    {
        p->property+=base->property;
  102e8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e91:	8b 50 08             	mov    0x8(%eax),%edx
  102e94:	8b 45 08             	mov    0x8(%ebp),%eax
  102e97:	8b 40 08             	mov    0x8(%eax),%eax
  102e9a:	01 c2                	add    %eax,%edx
  102e9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e9f:	89 50 08             	mov    %edx,0x8(%eax)
        base->property=0;
  102ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_del(&(base->page_link));
  102eac:	8b 45 08             	mov    0x8(%ebp),%eax
  102eaf:	83 c0 0c             	add    $0xc,%eax
  102eb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102eb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102eb8:	8b 40 04             	mov    0x4(%eax),%eax
  102ebb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ebe:	8b 12                	mov    (%edx),%edx
  102ec0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  102ec3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
  102ec6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ec9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ecc:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102ecf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ed2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102ed5:	89 10                	mov    %edx,(%eax)
}
  102ed7:	90                   	nop
}
  102ed8:	90                   	nop
        base=p;
  102ed9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102edc:	89 45 08             	mov    %eax,0x8(%ebp)
        return 1;   
  102edf:	b8 01 00 00 00       	mov    $0x1,%eax
  102ee4:	eb 05                	jmp    102eeb <merge_beforeward+0xdf>
    }
    else
    {
        return 0;
  102ee6:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    

}
  102eeb:	89 ec                	mov    %ebp,%esp
  102eed:	5d                   	pop    %ebp
  102eee:	c3                   	ret    

00102eef <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102eef:	55                   	push   %ebp
  102ef0:	89 e5                	mov    %esp,%ebp
  102ef2:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102ef5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102ef9:	75 24                	jne    102f1f <default_free_pages+0x30>
  102efb:	c7 44 24 0c 10 69 10 	movl   $0x106910,0xc(%esp)
  102f02:	00 
  102f03:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  102f0a:	00 
  102f0b:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  102f12:	00 
  102f13:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  102f1a:	e8 e0 dd ff ff       	call   100cff <__panic>
    struct Page *p = base;
  102f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102f22:	89 45 f4             	mov    %eax,-0xc(%ebp)

    for (; p != base + n; p ++) {
  102f25:	e9 ad 00 00 00       	jmp    102fd7 <default_free_pages+0xe8>
        
        //需要满足不是给内核的且不是空闲的
        assert(!PageReserved(p) && !PageProperty(p));
  102f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f2d:	83 c0 04             	add    $0x4,%eax
  102f30:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102f37:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f3d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f40:	0f a3 10             	bt     %edx,(%eax)
  102f43:	19 c0                	sbb    %eax,%eax
  102f45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102f48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f4c:	0f 95 c0             	setne  %al
  102f4f:	0f b6 c0             	movzbl %al,%eax
  102f52:	85 c0                	test   %eax,%eax
  102f54:	75 2c                	jne    102f82 <default_free_pages+0x93>
  102f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f59:	83 c0 04             	add    $0x4,%eax
  102f5c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102f63:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102f66:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102f69:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102f6c:	0f a3 10             	bt     %edx,(%eax)
  102f6f:	19 c0                	sbb    %eax,%eax
  102f71:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102f74:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102f78:	0f 95 c0             	setne  %al
  102f7b:	0f b6 c0             	movzbl %al,%eax
  102f7e:	85 c0                	test   %eax,%eax
  102f80:	74 24                	je     102fa6 <default_free_pages+0xb7>
  102f82:	c7 44 24 0c 54 69 10 	movl   $0x106954,0xc(%esp)
  102f89:	00 
  102f8a:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  102f91:	00 
  102f92:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  102f99:	00 
  102f9a:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  102fa1:	e8 59 dd ff ff       	call   100cff <__panic>
        //p->flags = 0;
        SetPageProperty(p);
  102fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fa9:	83 c0 04             	add    $0x4,%eax
  102fac:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102fb3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fb9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fbc:	0f ab 10             	bts    %edx,(%eax)
}
  102fbf:	90                   	nop
        set_page_ref(p, 0);
  102fc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102fc7:	00 
  102fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fcb:	89 04 24             	mov    %eax,(%esp)
  102fce:	e8 f0 f9 ff ff       	call   1029c3 <set_page_ref>
    for (; p != base + n; p ++) {
  102fd3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  102fda:	89 d0                	mov    %edx,%eax
  102fdc:	c1 e0 02             	shl    $0x2,%eax
  102fdf:	01 d0                	add    %edx,%eax
  102fe1:	c1 e0 02             	shl    $0x2,%eax
  102fe4:	89 c2                	mov    %eax,%edx
  102fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  102fe9:	01 d0                	add    %edx,%eax
  102feb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102fee:	0f 85 36 ff ff ff    	jne    102f2a <default_free_pages+0x3b>
    }

    base->property = n;
  102ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ffa:	89 50 08             	mov    %edx,0x8(%eax)
  102ffd:	c7 45 cc 80 ce 11 00 	movl   $0x11ce80,-0x34(%ebp)
    return listelm->next;
  103004:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103007:	8b 40 04             	mov    0x4(%eax),%eax
    //SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
  10300a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    for(;le!=&free_list && le<&(base->page_link);le=list_next(le));
  10300d:	eb 0f                	jmp    10301e <default_free_pages+0x12f>
  10300f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103012:	89 45 c8             	mov    %eax,-0x38(%ebp)
  103015:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103018:	8b 40 04             	mov    0x4(%eax),%eax
  10301b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10301e:	81 7d f0 80 ce 11 00 	cmpl   $0x11ce80,-0x10(%ebp)
  103025:	74 0b                	je     103032 <default_free_pages+0x143>
  103027:	8b 45 08             	mov    0x8(%ebp),%eax
  10302a:	83 c0 0c             	add    $0xc,%eax
  10302d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103030:	72 dd                	jb     10300f <default_free_pages+0x120>

     nr_free += n;
  103032:	8b 15 88 ce 11 00    	mov    0x11ce88,%edx
  103038:	8b 45 0c             	mov    0xc(%ebp),%eax
  10303b:	01 d0                	add    %edx,%eax
  10303d:	a3 88 ce 11 00       	mov    %eax,0x11ce88
    list_add_before(le,&base->page_link);
  103042:	8b 45 08             	mov    0x8(%ebp),%eax
  103045:	8d 50 0c             	lea    0xc(%eax),%edx
  103048:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10304b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  10304e:	89 55 c0             	mov    %edx,-0x40(%ebp)
    __list_add(elm, listelm->prev, listelm);
  103051:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103054:	8b 00                	mov    (%eax),%eax
  103056:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103059:	89 55 bc             	mov    %edx,-0x44(%ebp)
  10305c:	89 45 b8             	mov    %eax,-0x48(%ebp)
  10305f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103062:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next->prev = elm;
  103065:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103068:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10306b:	89 10                	mov    %edx,(%eax)
  10306d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103070:	8b 10                	mov    (%eax),%edx
  103072:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103075:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103078:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10307b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10307e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103081:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103084:	8b 55 b8             	mov    -0x48(%ebp),%edx
  103087:	89 10                	mov    %edx,(%eax)
}
  103089:	90                   	nop
}
  10308a:	90                   	nop
    while(merge_backward(base));
  10308b:	90                   	nop
  10308c:	8b 45 08             	mov    0x8(%ebp),%eax
  10308f:	89 04 24             	mov    %eax,(%esp)
  103092:	e8 9a fc ff ff       	call   102d31 <merge_backward>
  103097:	85 c0                	test   %eax,%eax
  103099:	75 f1                	jne    10308c <default_free_pages+0x19d>
    while(merge_beforeward(base));
  10309b:	90                   	nop
  10309c:	8b 45 08             	mov    0x8(%ebp),%eax
  10309f:	89 04 24             	mov    %eax,(%esp)
  1030a2:	e8 65 fd ff ff       	call   102e0c <merge_beforeward>
  1030a7:	85 c0                	test   %eax,%eax
  1030a9:	75 f1                	jne    10309c <default_free_pages+0x1ad>
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));*/


}
  1030ab:	90                   	nop
  1030ac:	90                   	nop
  1030ad:	89 ec                	mov    %ebp,%esp
  1030af:	5d                   	pop    %ebp
  1030b0:	c3                   	ret    

001030b1 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  1030b1:	55                   	push   %ebp
  1030b2:	89 e5                	mov    %esp,%ebp
    return nr_free;
  1030b4:	a1 88 ce 11 00       	mov    0x11ce88,%eax
}
  1030b9:	5d                   	pop    %ebp
  1030ba:	c3                   	ret    

001030bb <basic_check>:

static void
basic_check(void) {
  1030bb:	55                   	push   %ebp
  1030bc:	89 e5                	mov    %esp,%ebp
  1030be:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  1030c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1030c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  1030d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030db:	e8 ed 0e 00 00       	call   103fcd <alloc_pages>
  1030e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1030e7:	75 24                	jne    10310d <basic_check+0x52>
  1030e9:	c7 44 24 0c 79 69 10 	movl   $0x106979,0xc(%esp)
  1030f0:	00 
  1030f1:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1030f8:	00 
  1030f9:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
  103100:	00 
  103101:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103108:	e8 f2 db ff ff       	call   100cff <__panic>
    assert((p1 = alloc_page()) != NULL);
  10310d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103114:	e8 b4 0e 00 00       	call   103fcd <alloc_pages>
  103119:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10311c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103120:	75 24                	jne    103146 <basic_check+0x8b>
  103122:	c7 44 24 0c 95 69 10 	movl   $0x106995,0xc(%esp)
  103129:	00 
  10312a:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103131:	00 
  103132:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
  103139:	00 
  10313a:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103141:	e8 b9 db ff ff       	call   100cff <__panic>
    assert((p2 = alloc_page()) != NULL);
  103146:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10314d:	e8 7b 0e 00 00       	call   103fcd <alloc_pages>
  103152:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103155:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103159:	75 24                	jne    10317f <basic_check+0xc4>
  10315b:	c7 44 24 0c b1 69 10 	movl   $0x1069b1,0xc(%esp)
  103162:	00 
  103163:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10316a:	00 
  10316b:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
  103172:	00 
  103173:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10317a:	e8 80 db ff ff       	call   100cff <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  10317f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103182:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103185:	74 10                	je     103197 <basic_check+0xdc>
  103187:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10318a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10318d:	74 08                	je     103197 <basic_check+0xdc>
  10318f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103192:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103195:	75 24                	jne    1031bb <basic_check+0x100>
  103197:	c7 44 24 0c d0 69 10 	movl   $0x1069d0,0xc(%esp)
  10319e:	00 
  10319f:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1031a6:	00 
  1031a7:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  1031ae:	00 
  1031af:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1031b6:	e8 44 db ff ff       	call   100cff <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  1031bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031be:	89 04 24             	mov    %eax,(%esp)
  1031c1:	e8 f3 f7 ff ff       	call   1029b9 <page_ref>
  1031c6:	85 c0                	test   %eax,%eax
  1031c8:	75 1e                	jne    1031e8 <basic_check+0x12d>
  1031ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031cd:	89 04 24             	mov    %eax,(%esp)
  1031d0:	e8 e4 f7 ff ff       	call   1029b9 <page_ref>
  1031d5:	85 c0                	test   %eax,%eax
  1031d7:	75 0f                	jne    1031e8 <basic_check+0x12d>
  1031d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031dc:	89 04 24             	mov    %eax,(%esp)
  1031df:	e8 d5 f7 ff ff       	call   1029b9 <page_ref>
  1031e4:	85 c0                	test   %eax,%eax
  1031e6:	74 24                	je     10320c <basic_check+0x151>
  1031e8:	c7 44 24 0c f4 69 10 	movl   $0x1069f4,0xc(%esp)
  1031ef:	00 
  1031f0:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1031f7:	00 
  1031f8:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  1031ff:	00 
  103200:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103207:	e8 f3 da ff ff       	call   100cff <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  10320c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10320f:	89 04 24             	mov    %eax,(%esp)
  103212:	e8 8a f7 ff ff       	call   1029a1 <page2pa>
  103217:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  10321d:	c1 e2 0c             	shl    $0xc,%edx
  103220:	39 d0                	cmp    %edx,%eax
  103222:	72 24                	jb     103248 <basic_check+0x18d>
  103224:	c7 44 24 0c 30 6a 10 	movl   $0x106a30,0xc(%esp)
  10322b:	00 
  10322c:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103233:	00 
  103234:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
  10323b:	00 
  10323c:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103243:	e8 b7 da ff ff       	call   100cff <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  103248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10324b:	89 04 24             	mov    %eax,(%esp)
  10324e:	e8 4e f7 ff ff       	call   1029a1 <page2pa>
  103253:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  103259:	c1 e2 0c             	shl    $0xc,%edx
  10325c:	39 d0                	cmp    %edx,%eax
  10325e:	72 24                	jb     103284 <basic_check+0x1c9>
  103260:	c7 44 24 0c 4d 6a 10 	movl   $0x106a4d,0xc(%esp)
  103267:	00 
  103268:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10326f:	00 
  103270:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
  103277:	00 
  103278:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10327f:	e8 7b da ff ff       	call   100cff <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103284:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103287:	89 04 24             	mov    %eax,(%esp)
  10328a:	e8 12 f7 ff ff       	call   1029a1 <page2pa>
  10328f:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  103295:	c1 e2 0c             	shl    $0xc,%edx
  103298:	39 d0                	cmp    %edx,%eax
  10329a:	72 24                	jb     1032c0 <basic_check+0x205>
  10329c:	c7 44 24 0c 6a 6a 10 	movl   $0x106a6a,0xc(%esp)
  1032a3:	00 
  1032a4:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1032ab:	00 
  1032ac:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
  1032b3:	00 
  1032b4:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1032bb:	e8 3f da ff ff       	call   100cff <__panic>

    list_entry_t free_list_store = free_list;
  1032c0:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  1032c5:	8b 15 84 ce 11 00    	mov    0x11ce84,%edx
  1032cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1032ce:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1032d1:	c7 45 dc 80 ce 11 00 	movl   $0x11ce80,-0x24(%ebp)
    elm->prev = elm->next = elm;
  1032d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1032db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1032de:	89 50 04             	mov    %edx,0x4(%eax)
  1032e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1032e4:	8b 50 04             	mov    0x4(%eax),%edx
  1032e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1032ea:	89 10                	mov    %edx,(%eax)
}
  1032ec:	90                   	nop
  1032ed:	c7 45 e0 80 ce 11 00 	movl   $0x11ce80,-0x20(%ebp)
    return list->next == list;
  1032f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032f7:	8b 40 04             	mov    0x4(%eax),%eax
  1032fa:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1032fd:	0f 94 c0             	sete   %al
  103300:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103303:	85 c0                	test   %eax,%eax
  103305:	75 24                	jne    10332b <basic_check+0x270>
  103307:	c7 44 24 0c 87 6a 10 	movl   $0x106a87,0xc(%esp)
  10330e:	00 
  10330f:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103316:	00 
  103317:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
  10331e:	00 
  10331f:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103326:	e8 d4 d9 ff ff       	call   100cff <__panic>

    unsigned int nr_free_store = nr_free;
  10332b:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103330:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103333:	c7 05 88 ce 11 00 00 	movl   $0x0,0x11ce88
  10333a:	00 00 00 

    assert(alloc_page() == NULL);
  10333d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103344:	e8 84 0c 00 00       	call   103fcd <alloc_pages>
  103349:	85 c0                	test   %eax,%eax
  10334b:	74 24                	je     103371 <basic_check+0x2b6>
  10334d:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  103354:	00 
  103355:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10335c:	00 
  10335d:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
  103364:	00 
  103365:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10336c:	e8 8e d9 ff ff       	call   100cff <__panic>

    free_page(p0);
  103371:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103378:	00 
  103379:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10337c:	89 04 24             	mov    %eax,(%esp)
  10337f:	e8 83 0c 00 00       	call   104007 <free_pages>
    free_page(p1);
  103384:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10338b:	00 
  10338c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10338f:	89 04 24             	mov    %eax,(%esp)
  103392:	e8 70 0c 00 00       	call   104007 <free_pages>
    free_page(p2);
  103397:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10339e:	00 
  10339f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033a2:	89 04 24             	mov    %eax,(%esp)
  1033a5:	e8 5d 0c 00 00       	call   104007 <free_pages>
    assert(nr_free == 3);
  1033aa:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  1033af:	83 f8 03             	cmp    $0x3,%eax
  1033b2:	74 24                	je     1033d8 <basic_check+0x31d>
  1033b4:	c7 44 24 0c b3 6a 10 	movl   $0x106ab3,0xc(%esp)
  1033bb:	00 
  1033bc:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1033c3:	00 
  1033c4:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
  1033cb:	00 
  1033cc:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1033d3:	e8 27 d9 ff ff       	call   100cff <__panic>

    assert((p0 = alloc_page()) != NULL);
  1033d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033df:	e8 e9 0b 00 00       	call   103fcd <alloc_pages>
  1033e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1033e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1033eb:	75 24                	jne    103411 <basic_check+0x356>
  1033ed:	c7 44 24 0c 79 69 10 	movl   $0x106979,0xc(%esp)
  1033f4:	00 
  1033f5:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1033fc:	00 
  1033fd:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
  103404:	00 
  103405:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10340c:	e8 ee d8 ff ff       	call   100cff <__panic>
    assert((p1 = alloc_page()) != NULL);
  103411:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103418:	e8 b0 0b 00 00       	call   103fcd <alloc_pages>
  10341d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103424:	75 24                	jne    10344a <basic_check+0x38f>
  103426:	c7 44 24 0c 95 69 10 	movl   $0x106995,0xc(%esp)
  10342d:	00 
  10342e:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103435:	00 
  103436:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
  10343d:	00 
  10343e:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103445:	e8 b5 d8 ff ff       	call   100cff <__panic>
    assert((p2 = alloc_page()) != NULL);
  10344a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103451:	e8 77 0b 00 00       	call   103fcd <alloc_pages>
  103456:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103459:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10345d:	75 24                	jne    103483 <basic_check+0x3c8>
  10345f:	c7 44 24 0c b1 69 10 	movl   $0x1069b1,0xc(%esp)
  103466:	00 
  103467:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10346e:	00 
  10346f:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
  103476:	00 
  103477:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10347e:	e8 7c d8 ff ff       	call   100cff <__panic>

    assert(alloc_page() == NULL);
  103483:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10348a:	e8 3e 0b 00 00       	call   103fcd <alloc_pages>
  10348f:	85 c0                	test   %eax,%eax
  103491:	74 24                	je     1034b7 <basic_check+0x3fc>
  103493:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  10349a:	00 
  10349b:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1034a2:	00 
  1034a3:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
  1034aa:	00 
  1034ab:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1034b2:	e8 48 d8 ff ff       	call   100cff <__panic>

    free_page(p0);
  1034b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1034be:	00 
  1034bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034c2:	89 04 24             	mov    %eax,(%esp)
  1034c5:	e8 3d 0b 00 00       	call   104007 <free_pages>
  1034ca:	c7 45 d8 80 ce 11 00 	movl   $0x11ce80,-0x28(%ebp)
  1034d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1034d4:	8b 40 04             	mov    0x4(%eax),%eax
  1034d7:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1034da:	0f 94 c0             	sete   %al
  1034dd:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  1034e0:	85 c0                	test   %eax,%eax
  1034e2:	74 24                	je     103508 <basic_check+0x44d>
  1034e4:	c7 44 24 0c c0 6a 10 	movl   $0x106ac0,0xc(%esp)
  1034eb:	00 
  1034ec:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1034f3:	00 
  1034f4:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
  1034fb:	00 
  1034fc:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103503:	e8 f7 d7 ff ff       	call   100cff <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103508:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10350f:	e8 b9 0a 00 00       	call   103fcd <alloc_pages>
  103514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10351a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10351d:	74 24                	je     103543 <basic_check+0x488>
  10351f:	c7 44 24 0c d8 6a 10 	movl   $0x106ad8,0xc(%esp)
  103526:	00 
  103527:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10352e:	00 
  10352f:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
  103536:	00 
  103537:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10353e:	e8 bc d7 ff ff       	call   100cff <__panic>
    assert(alloc_page() == NULL);
  103543:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10354a:	e8 7e 0a 00 00       	call   103fcd <alloc_pages>
  10354f:	85 c0                	test   %eax,%eax
  103551:	74 24                	je     103577 <basic_check+0x4bc>
  103553:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  10355a:	00 
  10355b:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103562:	00 
  103563:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
  10356a:	00 
  10356b:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103572:	e8 88 d7 ff ff       	call   100cff <__panic>

    assert(nr_free == 0);
  103577:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  10357c:	85 c0                	test   %eax,%eax
  10357e:	74 24                	je     1035a4 <basic_check+0x4e9>
  103580:	c7 44 24 0c f1 6a 10 	movl   $0x106af1,0xc(%esp)
  103587:	00 
  103588:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10358f:	00 
  103590:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
  103597:	00 
  103598:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10359f:	e8 5b d7 ff ff       	call   100cff <__panic>
    free_list = free_list_store;
  1035a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1035a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1035aa:	a3 80 ce 11 00       	mov    %eax,0x11ce80
  1035af:	89 15 84 ce 11 00    	mov    %edx,0x11ce84
    nr_free = nr_free_store;
  1035b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1035b8:	a3 88 ce 11 00       	mov    %eax,0x11ce88

    free_page(p);
  1035bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1035c4:	00 
  1035c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1035c8:	89 04 24             	mov    %eax,(%esp)
  1035cb:	e8 37 0a 00 00       	call   104007 <free_pages>
    free_page(p1);
  1035d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1035d7:	00 
  1035d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035db:	89 04 24             	mov    %eax,(%esp)
  1035de:	e8 24 0a 00 00       	call   104007 <free_pages>
    free_page(p2);
  1035e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1035ea:	00 
  1035eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035ee:	89 04 24             	mov    %eax,(%esp)
  1035f1:	e8 11 0a 00 00       	call   104007 <free_pages>
}
  1035f6:	90                   	nop
  1035f7:	89 ec                	mov    %ebp,%esp
  1035f9:	5d                   	pop    %ebp
  1035fa:	c3                   	ret    

001035fb <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1035fb:	55                   	push   %ebp
  1035fc:	89 e5                	mov    %esp,%ebp
  1035fe:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  103604:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10360b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103612:	c7 45 ec 80 ce 11 00 	movl   $0x11ce80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103619:	eb 6a                	jmp    103685 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  10361b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10361e:	83 e8 0c             	sub    $0xc,%eax
  103621:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  103624:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103627:	83 c0 04             	add    $0x4,%eax
  10362a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103631:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103634:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103637:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10363a:	0f a3 10             	bt     %edx,(%eax)
  10363d:	19 c0                	sbb    %eax,%eax
  10363f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103642:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  103646:	0f 95 c0             	setne  %al
  103649:	0f b6 c0             	movzbl %al,%eax
  10364c:	85 c0                	test   %eax,%eax
  10364e:	75 24                	jne    103674 <default_check+0x79>
  103650:	c7 44 24 0c fe 6a 10 	movl   $0x106afe,0xc(%esp)
  103657:	00 
  103658:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10365f:	00 
  103660:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
  103667:	00 
  103668:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10366f:	e8 8b d6 ff ff       	call   100cff <__panic>
        count ++, total += p->property;
  103674:	ff 45 f4             	incl   -0xc(%ebp)
  103677:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10367a:	8b 50 08             	mov    0x8(%eax),%edx
  10367d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103680:	01 d0                	add    %edx,%eax
  103682:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103688:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  10368b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10368e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103694:	81 7d ec 80 ce 11 00 	cmpl   $0x11ce80,-0x14(%ebp)
  10369b:	0f 85 7a ff ff ff    	jne    10361b <default_check+0x20>
    }
    assert(total == nr_free_pages());
  1036a1:	e8 96 09 00 00       	call   10403c <nr_free_pages>
  1036a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1036a9:	39 d0                	cmp    %edx,%eax
  1036ab:	74 24                	je     1036d1 <default_check+0xd6>
  1036ad:	c7 44 24 0c 0e 6b 10 	movl   $0x106b0e,0xc(%esp)
  1036b4:	00 
  1036b5:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1036bc:	00 
  1036bd:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
  1036c4:	00 
  1036c5:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1036cc:	e8 2e d6 ff ff       	call   100cff <__panic>

    basic_check();
  1036d1:	e8 e5 f9 ff ff       	call   1030bb <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  1036d6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1036dd:	e8 eb 08 00 00       	call   103fcd <alloc_pages>
  1036e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  1036e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1036e9:	75 24                	jne    10370f <default_check+0x114>
  1036eb:	c7 44 24 0c 27 6b 10 	movl   $0x106b27,0xc(%esp)
  1036f2:	00 
  1036f3:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1036fa:	00 
  1036fb:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
  103702:	00 
  103703:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10370a:	e8 f0 d5 ff ff       	call   100cff <__panic>
    assert(!PageProperty(p0));
  10370f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103712:	83 c0 04             	add    $0x4,%eax
  103715:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10371c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10371f:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103722:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103725:	0f a3 10             	bt     %edx,(%eax)
  103728:	19 c0                	sbb    %eax,%eax
  10372a:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  10372d:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  103731:	0f 95 c0             	setne  %al
  103734:	0f b6 c0             	movzbl %al,%eax
  103737:	85 c0                	test   %eax,%eax
  103739:	74 24                	je     10375f <default_check+0x164>
  10373b:	c7 44 24 0c 32 6b 10 	movl   $0x106b32,0xc(%esp)
  103742:	00 
  103743:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  10374a:	00 
  10374b:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
  103752:	00 
  103753:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  10375a:	e8 a0 d5 ff ff       	call   100cff <__panic>

    list_entry_t free_list_store = free_list;
  10375f:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103764:	8b 15 84 ce 11 00    	mov    0x11ce84,%edx
  10376a:	89 45 80             	mov    %eax,-0x80(%ebp)
  10376d:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103770:	c7 45 b0 80 ce 11 00 	movl   $0x11ce80,-0x50(%ebp)
    elm->prev = elm->next = elm;
  103777:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10377a:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10377d:	89 50 04             	mov    %edx,0x4(%eax)
  103780:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103783:	8b 50 04             	mov    0x4(%eax),%edx
  103786:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103789:	89 10                	mov    %edx,(%eax)
}
  10378b:	90                   	nop
  10378c:	c7 45 b4 80 ce 11 00 	movl   $0x11ce80,-0x4c(%ebp)
    return list->next == list;
  103793:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103796:	8b 40 04             	mov    0x4(%eax),%eax
  103799:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  10379c:	0f 94 c0             	sete   %al
  10379f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1037a2:	85 c0                	test   %eax,%eax
  1037a4:	75 24                	jne    1037ca <default_check+0x1cf>
  1037a6:	c7 44 24 0c 87 6a 10 	movl   $0x106a87,0xc(%esp)
  1037ad:	00 
  1037ae:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1037b5:	00 
  1037b6:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
  1037bd:	00 
  1037be:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1037c5:	e8 35 d5 ff ff       	call   100cff <__panic>
    assert(alloc_page() == NULL);
  1037ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037d1:	e8 f7 07 00 00       	call   103fcd <alloc_pages>
  1037d6:	85 c0                	test   %eax,%eax
  1037d8:	74 24                	je     1037fe <default_check+0x203>
  1037da:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  1037e1:	00 
  1037e2:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1037e9:	00 
  1037ea:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
  1037f1:	00 
  1037f2:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1037f9:	e8 01 d5 ff ff       	call   100cff <__panic>

    unsigned int nr_free_store = nr_free;
  1037fe:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103803:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  103806:	c7 05 88 ce 11 00 00 	movl   $0x0,0x11ce88
  10380d:	00 00 00 

    free_pages(p0 + 2, 3);
  103810:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103813:	83 c0 28             	add    $0x28,%eax
  103816:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10381d:	00 
  10381e:	89 04 24             	mov    %eax,(%esp)
  103821:	e8 e1 07 00 00       	call   104007 <free_pages>
    assert(alloc_pages(4) == NULL);
  103826:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10382d:	e8 9b 07 00 00       	call   103fcd <alloc_pages>
  103832:	85 c0                	test   %eax,%eax
  103834:	74 24                	je     10385a <default_check+0x25f>
  103836:	c7 44 24 0c 44 6b 10 	movl   $0x106b44,0xc(%esp)
  10383d:	00 
  10383e:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103845:	00 
  103846:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
  10384d:	00 
  10384e:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103855:	e8 a5 d4 ff ff       	call   100cff <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10385a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10385d:	83 c0 28             	add    $0x28,%eax
  103860:	83 c0 04             	add    $0x4,%eax
  103863:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10386a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10386d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103870:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103873:	0f a3 10             	bt     %edx,(%eax)
  103876:	19 c0                	sbb    %eax,%eax
  103878:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10387b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  10387f:	0f 95 c0             	setne  %al
  103882:	0f b6 c0             	movzbl %al,%eax
  103885:	85 c0                	test   %eax,%eax
  103887:	74 0e                	je     103897 <default_check+0x29c>
  103889:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10388c:	83 c0 28             	add    $0x28,%eax
  10388f:	8b 40 08             	mov    0x8(%eax),%eax
  103892:	83 f8 03             	cmp    $0x3,%eax
  103895:	74 24                	je     1038bb <default_check+0x2c0>
  103897:	c7 44 24 0c 5c 6b 10 	movl   $0x106b5c,0xc(%esp)
  10389e:	00 
  10389f:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1038a6:	00 
  1038a7:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
  1038ae:	00 
  1038af:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1038b6:	e8 44 d4 ff ff       	call   100cff <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1038bb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1038c2:	e8 06 07 00 00       	call   103fcd <alloc_pages>
  1038c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1038ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1038ce:	75 24                	jne    1038f4 <default_check+0x2f9>
  1038d0:	c7 44 24 0c 88 6b 10 	movl   $0x106b88,0xc(%esp)
  1038d7:	00 
  1038d8:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1038df:	00 
  1038e0:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
  1038e7:	00 
  1038e8:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1038ef:	e8 0b d4 ff ff       	call   100cff <__panic>
    assert(alloc_page() == NULL);
  1038f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038fb:	e8 cd 06 00 00       	call   103fcd <alloc_pages>
  103900:	85 c0                	test   %eax,%eax
  103902:	74 24                	je     103928 <default_check+0x32d>
  103904:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  10390b:	00 
  10390c:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103913:	00 
  103914:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
  10391b:	00 
  10391c:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103923:	e8 d7 d3 ff ff       	call   100cff <__panic>
    assert(p0 + 2 == p1);
  103928:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10392b:	83 c0 28             	add    $0x28,%eax
  10392e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103931:	74 24                	je     103957 <default_check+0x35c>
  103933:	c7 44 24 0c a6 6b 10 	movl   $0x106ba6,0xc(%esp)
  10393a:	00 
  10393b:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103942:	00 
  103943:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
  10394a:	00 
  10394b:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103952:	e8 a8 d3 ff ff       	call   100cff <__panic>

    p2 = p0 + 1;
  103957:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10395a:	83 c0 14             	add    $0x14,%eax
  10395d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  103960:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103967:	00 
  103968:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10396b:	89 04 24             	mov    %eax,(%esp)
  10396e:	e8 94 06 00 00       	call   104007 <free_pages>
    free_pages(p1, 3);
  103973:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10397a:	00 
  10397b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10397e:	89 04 24             	mov    %eax,(%esp)
  103981:	e8 81 06 00 00       	call   104007 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  103986:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103989:	83 c0 04             	add    $0x4,%eax
  10398c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103993:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103996:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103999:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10399c:	0f a3 10             	bt     %edx,(%eax)
  10399f:	19 c0                	sbb    %eax,%eax
  1039a1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1039a4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1039a8:	0f 95 c0             	setne  %al
  1039ab:	0f b6 c0             	movzbl %al,%eax
  1039ae:	85 c0                	test   %eax,%eax
  1039b0:	74 0b                	je     1039bd <default_check+0x3c2>
  1039b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1039b5:	8b 40 08             	mov    0x8(%eax),%eax
  1039b8:	83 f8 01             	cmp    $0x1,%eax
  1039bb:	74 24                	je     1039e1 <default_check+0x3e6>
  1039bd:	c7 44 24 0c b4 6b 10 	movl   $0x106bb4,0xc(%esp)
  1039c4:	00 
  1039c5:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  1039cc:	00 
  1039cd:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
  1039d4:	00 
  1039d5:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  1039dc:	e8 1e d3 ff ff       	call   100cff <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1039e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1039e4:	83 c0 04             	add    $0x4,%eax
  1039e7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1039ee:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1039f1:	8b 45 90             	mov    -0x70(%ebp),%eax
  1039f4:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1039f7:	0f a3 10             	bt     %edx,(%eax)
  1039fa:	19 c0                	sbb    %eax,%eax
  1039fc:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1039ff:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103a03:	0f 95 c0             	setne  %al
  103a06:	0f b6 c0             	movzbl %al,%eax
  103a09:	85 c0                	test   %eax,%eax
  103a0b:	74 0b                	je     103a18 <default_check+0x41d>
  103a0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103a10:	8b 40 08             	mov    0x8(%eax),%eax
  103a13:	83 f8 03             	cmp    $0x3,%eax
  103a16:	74 24                	je     103a3c <default_check+0x441>
  103a18:	c7 44 24 0c dc 6b 10 	movl   $0x106bdc,0xc(%esp)
  103a1f:	00 
  103a20:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103a27:	00 
  103a28:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
  103a2f:	00 
  103a30:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103a37:	e8 c3 d2 ff ff       	call   100cff <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103a3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103a43:	e8 85 05 00 00       	call   103fcd <alloc_pages>
  103a48:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103a4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103a4e:	83 e8 14             	sub    $0x14,%eax
  103a51:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103a54:	74 24                	je     103a7a <default_check+0x47f>
  103a56:	c7 44 24 0c 02 6c 10 	movl   $0x106c02,0xc(%esp)
  103a5d:	00 
  103a5e:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103a65:	00 
  103a66:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
  103a6d:	00 
  103a6e:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103a75:	e8 85 d2 ff ff       	call   100cff <__panic>
    free_page(p0);
  103a7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103a81:	00 
  103a82:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a85:	89 04 24             	mov    %eax,(%esp)
  103a88:	e8 7a 05 00 00       	call   104007 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103a8d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103a94:	e8 34 05 00 00       	call   103fcd <alloc_pages>
  103a99:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103a9f:	83 c0 14             	add    $0x14,%eax
  103aa2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103aa5:	74 24                	je     103acb <default_check+0x4d0>
  103aa7:	c7 44 24 0c 20 6c 10 	movl   $0x106c20,0xc(%esp)
  103aae:	00 
  103aaf:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103ab6:	00 
  103ab7:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
  103abe:	00 
  103abf:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103ac6:	e8 34 d2 ff ff       	call   100cff <__panic>

    free_pages(p0, 2);
  103acb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103ad2:	00 
  103ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103ad6:	89 04 24             	mov    %eax,(%esp)
  103ad9:	e8 29 05 00 00       	call   104007 <free_pages>
    free_page(p2);
  103ade:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ae5:	00 
  103ae6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103ae9:	89 04 24             	mov    %eax,(%esp)
  103aec:	e8 16 05 00 00       	call   104007 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103af1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103af8:	e8 d0 04 00 00       	call   103fcd <alloc_pages>
  103afd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103b00:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103b04:	75 24                	jne    103b2a <default_check+0x52f>
  103b06:	c7 44 24 0c 40 6c 10 	movl   $0x106c40,0xc(%esp)
  103b0d:	00 
  103b0e:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103b15:	00 
  103b16:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
  103b1d:	00 
  103b1e:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103b25:	e8 d5 d1 ff ff       	call   100cff <__panic>
    assert(alloc_page() == NULL);
  103b2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b31:	e8 97 04 00 00       	call   103fcd <alloc_pages>
  103b36:	85 c0                	test   %eax,%eax
  103b38:	74 24                	je     103b5e <default_check+0x563>
  103b3a:	c7 44 24 0c 9e 6a 10 	movl   $0x106a9e,0xc(%esp)
  103b41:	00 
  103b42:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103b49:	00 
  103b4a:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
  103b51:	00 
  103b52:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103b59:	e8 a1 d1 ff ff       	call   100cff <__panic>

    assert(nr_free == 0);
  103b5e:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  103b63:	85 c0                	test   %eax,%eax
  103b65:	74 24                	je     103b8b <default_check+0x590>
  103b67:	c7 44 24 0c f1 6a 10 	movl   $0x106af1,0xc(%esp)
  103b6e:	00 
  103b6f:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103b76:	00 
  103b77:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
  103b7e:	00 
  103b7f:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103b86:	e8 74 d1 ff ff       	call   100cff <__panic>
    nr_free = nr_free_store;
  103b8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b8e:	a3 88 ce 11 00       	mov    %eax,0x11ce88

    free_list = free_list_store;
  103b93:	8b 45 80             	mov    -0x80(%ebp),%eax
  103b96:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103b99:	a3 80 ce 11 00       	mov    %eax,0x11ce80
  103b9e:	89 15 84 ce 11 00    	mov    %edx,0x11ce84
    free_pages(p0, 5);
  103ba4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103bab:	00 
  103bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103baf:	89 04 24             	mov    %eax,(%esp)
  103bb2:	e8 50 04 00 00       	call   104007 <free_pages>

    le = &free_list;
  103bb7:	c7 45 ec 80 ce 11 00 	movl   $0x11ce80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103bbe:	eb 5a                	jmp    103c1a <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
  103bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103bc3:	8b 40 04             	mov    0x4(%eax),%eax
  103bc6:	8b 00                	mov    (%eax),%eax
  103bc8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103bcb:	75 0d                	jne    103bda <default_check+0x5df>
  103bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103bd0:	8b 00                	mov    (%eax),%eax
  103bd2:	8b 40 04             	mov    0x4(%eax),%eax
  103bd5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103bd8:	74 24                	je     103bfe <default_check+0x603>
  103bda:	c7 44 24 0c 60 6c 10 	movl   $0x106c60,0xc(%esp)
  103be1:	00 
  103be2:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103be9:	00 
  103bea:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
  103bf1:	00 
  103bf2:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103bf9:	e8 01 d1 ff ff       	call   100cff <__panic>
        struct Page *p = le2page(le, page_link);
  103bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c01:	83 e8 0c             	sub    $0xc,%eax
  103c04:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  103c07:	ff 4d f4             	decl   -0xc(%ebp)
  103c0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103c0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103c10:	8b 48 08             	mov    0x8(%eax),%ecx
  103c13:	89 d0                	mov    %edx,%eax
  103c15:	29 c8                	sub    %ecx,%eax
  103c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c1d:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  103c20:	8b 45 88             	mov    -0x78(%ebp),%eax
  103c23:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103c29:	81 7d ec 80 ce 11 00 	cmpl   $0x11ce80,-0x14(%ebp)
  103c30:	75 8e                	jne    103bc0 <default_check+0x5c5>
    }
    assert(count == 0);
  103c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103c36:	74 24                	je     103c5c <default_check+0x661>
  103c38:	c7 44 24 0c 8d 6c 10 	movl   $0x106c8d,0xc(%esp)
  103c3f:	00 
  103c40:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103c47:	00 
  103c48:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
  103c4f:	00 
  103c50:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103c57:	e8 a3 d0 ff ff       	call   100cff <__panic>
    assert(total == 0);
  103c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103c60:	74 24                	je     103c86 <default_check+0x68b>
  103c62:	c7 44 24 0c 98 6c 10 	movl   $0x106c98,0xc(%esp)
  103c69:	00 
  103c6a:	c7 44 24 08 16 69 10 	movl   $0x106916,0x8(%esp)
  103c71:	00 
  103c72:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
  103c79:	00 
  103c7a:	c7 04 24 2b 69 10 00 	movl   $0x10692b,(%esp)
  103c81:	e8 79 d0 ff ff       	call   100cff <__panic>
}
  103c86:	90                   	nop
  103c87:	89 ec                	mov    %ebp,%esp
  103c89:	5d                   	pop    %ebp
  103c8a:	c3                   	ret    

00103c8b <page2ppn>:
page2ppn(struct Page *page) {
  103c8b:	55                   	push   %ebp
  103c8c:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103c8e:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  103c94:	8b 45 08             	mov    0x8(%ebp),%eax
  103c97:	29 d0                	sub    %edx,%eax
  103c99:	c1 f8 02             	sar    $0x2,%eax
  103c9c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103ca2:	5d                   	pop    %ebp
  103ca3:	c3                   	ret    

00103ca4 <page2pa>:
page2pa(struct Page *page) {
  103ca4:	55                   	push   %ebp
  103ca5:	89 e5                	mov    %esp,%ebp
  103ca7:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103caa:	8b 45 08             	mov    0x8(%ebp),%eax
  103cad:	89 04 24             	mov    %eax,(%esp)
  103cb0:	e8 d6 ff ff ff       	call   103c8b <page2ppn>
  103cb5:	c1 e0 0c             	shl    $0xc,%eax
}
  103cb8:	89 ec                	mov    %ebp,%esp
  103cba:	5d                   	pop    %ebp
  103cbb:	c3                   	ret    

00103cbc <pa2page>:
pa2page(uintptr_t pa) {
  103cbc:	55                   	push   %ebp
  103cbd:	89 e5                	mov    %esp,%ebp
  103cbf:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  103cc5:	c1 e8 0c             	shr    $0xc,%eax
  103cc8:	89 c2                	mov    %eax,%edx
  103cca:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  103ccf:	39 c2                	cmp    %eax,%edx
  103cd1:	72 1c                	jb     103cef <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103cd3:	c7 44 24 08 d4 6c 10 	movl   $0x106cd4,0x8(%esp)
  103cda:	00 
  103cdb:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103ce2:	00 
  103ce3:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  103cea:	e8 10 d0 ff ff       	call   100cff <__panic>
    return &pages[PPN(pa)];
  103cef:	8b 0d a0 ce 11 00    	mov    0x11cea0,%ecx
  103cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  103cf8:	c1 e8 0c             	shr    $0xc,%eax
  103cfb:	89 c2                	mov    %eax,%edx
  103cfd:	89 d0                	mov    %edx,%eax
  103cff:	c1 e0 02             	shl    $0x2,%eax
  103d02:	01 d0                	add    %edx,%eax
  103d04:	c1 e0 02             	shl    $0x2,%eax
  103d07:	01 c8                	add    %ecx,%eax
}
  103d09:	89 ec                	mov    %ebp,%esp
  103d0b:	5d                   	pop    %ebp
  103d0c:	c3                   	ret    

00103d0d <page2kva>:
page2kva(struct Page *page) {
  103d0d:	55                   	push   %ebp
  103d0e:	89 e5                	mov    %esp,%ebp
  103d10:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103d13:	8b 45 08             	mov    0x8(%ebp),%eax
  103d16:	89 04 24             	mov    %eax,(%esp)
  103d19:	e8 86 ff ff ff       	call   103ca4 <page2pa>
  103d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d24:	c1 e8 0c             	shr    $0xc,%eax
  103d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d2a:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  103d2f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103d32:	72 23                	jb     103d57 <page2kva+0x4a>
  103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d3b:	c7 44 24 08 04 6d 10 	movl   $0x106d04,0x8(%esp)
  103d42:	00 
  103d43:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103d4a:	00 
  103d4b:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  103d52:	e8 a8 cf ff ff       	call   100cff <__panic>
  103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d5a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103d5f:	89 ec                	mov    %ebp,%esp
  103d61:	5d                   	pop    %ebp
  103d62:	c3                   	ret    

00103d63 <pte2page>:
pte2page(pte_t pte) {
  103d63:	55                   	push   %ebp
  103d64:	89 e5                	mov    %esp,%ebp
  103d66:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103d69:	8b 45 08             	mov    0x8(%ebp),%eax
  103d6c:	83 e0 01             	and    $0x1,%eax
  103d6f:	85 c0                	test   %eax,%eax
  103d71:	75 1c                	jne    103d8f <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103d73:	c7 44 24 08 28 6d 10 	movl   $0x106d28,0x8(%esp)
  103d7a:	00 
  103d7b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103d82:	00 
  103d83:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  103d8a:	e8 70 cf ff ff       	call   100cff <__panic>
    return pa2page(PTE_ADDR(pte));
  103d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  103d92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d97:	89 04 24             	mov    %eax,(%esp)
  103d9a:	e8 1d ff ff ff       	call   103cbc <pa2page>
}
  103d9f:	89 ec                	mov    %ebp,%esp
  103da1:	5d                   	pop    %ebp
  103da2:	c3                   	ret    

00103da3 <pde2page>:
pde2page(pde_t pde) {
  103da3:	55                   	push   %ebp
  103da4:	89 e5                	mov    %esp,%ebp
  103da6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103da9:	8b 45 08             	mov    0x8(%ebp),%eax
  103dac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103db1:	89 04 24             	mov    %eax,(%esp)
  103db4:	e8 03 ff ff ff       	call   103cbc <pa2page>
}
  103db9:	89 ec                	mov    %ebp,%esp
  103dbb:	5d                   	pop    %ebp
  103dbc:	c3                   	ret    

00103dbd <page_ref>:
page_ref(struct Page *page) {
  103dbd:	55                   	push   %ebp
  103dbe:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  103dc3:	8b 00                	mov    (%eax),%eax
}
  103dc5:	5d                   	pop    %ebp
  103dc6:	c3                   	ret    

00103dc7 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  103dc7:	55                   	push   %ebp
  103dc8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103dca:	8b 45 08             	mov    0x8(%ebp),%eax
  103dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  103dd0:	89 10                	mov    %edx,(%eax)
}
  103dd2:	90                   	nop
  103dd3:	5d                   	pop    %ebp
  103dd4:	c3                   	ret    

00103dd5 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103dd5:	55                   	push   %ebp
  103dd6:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  103ddb:	8b 00                	mov    (%eax),%eax
  103ddd:	8d 50 01             	lea    0x1(%eax),%edx
  103de0:	8b 45 08             	mov    0x8(%ebp),%eax
  103de3:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103de5:	8b 45 08             	mov    0x8(%ebp),%eax
  103de8:	8b 00                	mov    (%eax),%eax
}
  103dea:	5d                   	pop    %ebp
  103deb:	c3                   	ret    

00103dec <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103dec:	55                   	push   %ebp
  103ded:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103def:	8b 45 08             	mov    0x8(%ebp),%eax
  103df2:	8b 00                	mov    (%eax),%eax
  103df4:	8d 50 ff             	lea    -0x1(%eax),%edx
  103df7:	8b 45 08             	mov    0x8(%ebp),%eax
  103dfa:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  103dff:	8b 00                	mov    (%eax),%eax
}
  103e01:	5d                   	pop    %ebp
  103e02:	c3                   	ret    

00103e03 <__intr_save>:
__intr_save(void) {
  103e03:	55                   	push   %ebp
  103e04:	89 e5                	mov    %esp,%ebp
  103e06:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103e09:	9c                   	pushf  
  103e0a:	58                   	pop    %eax
  103e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103e11:	25 00 02 00 00       	and    $0x200,%eax
  103e16:	85 c0                	test   %eax,%eax
  103e18:	74 0c                	je     103e26 <__intr_save+0x23>
        intr_disable();
  103e1a:	e8 39 d9 ff ff       	call   101758 <intr_disable>
        return 1;
  103e1f:	b8 01 00 00 00       	mov    $0x1,%eax
  103e24:	eb 05                	jmp    103e2b <__intr_save+0x28>
    return 0;
  103e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103e2b:	89 ec                	mov    %ebp,%esp
  103e2d:	5d                   	pop    %ebp
  103e2e:	c3                   	ret    

00103e2f <__intr_restore>:
__intr_restore(bool flag) {
  103e2f:	55                   	push   %ebp
  103e30:	89 e5                	mov    %esp,%ebp
  103e32:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103e35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103e39:	74 05                	je     103e40 <__intr_restore+0x11>
        intr_enable();
  103e3b:	e8 10 d9 ff ff       	call   101750 <intr_enable>
}
  103e40:	90                   	nop
  103e41:	89 ec                	mov    %ebp,%esp
  103e43:	5d                   	pop    %ebp
  103e44:	c3                   	ret    

00103e45 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103e45:	55                   	push   %ebp
  103e46:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103e48:	8b 45 08             	mov    0x8(%ebp),%eax
  103e4b:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103e4e:	b8 23 00 00 00       	mov    $0x23,%eax
  103e53:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103e55:	b8 23 00 00 00       	mov    $0x23,%eax
  103e5a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103e5c:	b8 10 00 00 00       	mov    $0x10,%eax
  103e61:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103e63:	b8 10 00 00 00       	mov    $0x10,%eax
  103e68:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103e6a:	b8 10 00 00 00       	mov    $0x10,%eax
  103e6f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103e71:	ea 78 3e 10 00 08 00 	ljmp   $0x8,$0x103e78
}
  103e78:	90                   	nop
  103e79:	5d                   	pop    %ebp
  103e7a:	c3                   	ret    

00103e7b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103e7b:	55                   	push   %ebp
  103e7c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  103e81:	a3 c4 ce 11 00       	mov    %eax,0x11cec4
}
  103e86:	90                   	nop
  103e87:	5d                   	pop    %ebp
  103e88:	c3                   	ret    

00103e89 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103e89:	55                   	push   %ebp
  103e8a:	89 e5                	mov    %esp,%ebp
  103e8c:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103e8f:	b8 00 90 11 00       	mov    $0x119000,%eax
  103e94:	89 04 24             	mov    %eax,(%esp)
  103e97:	e8 df ff ff ff       	call   103e7b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103e9c:	66 c7 05 c8 ce 11 00 	movw   $0x10,0x11cec8
  103ea3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103ea5:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  103eac:	68 00 
  103eae:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  103eb3:	0f b7 c0             	movzwl %ax,%eax
  103eb6:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  103ebc:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  103ec1:	c1 e8 10             	shr    $0x10,%eax
  103ec4:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  103ec9:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103ed0:	24 f0                	and    $0xf0,%al
  103ed2:	0c 09                	or     $0x9,%al
  103ed4:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103ed9:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103ee0:	24 ef                	and    $0xef,%al
  103ee2:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103ee7:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103eee:	24 9f                	and    $0x9f,%al
  103ef0:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103ef5:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103efc:	0c 80                	or     $0x80,%al
  103efe:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103f03:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f0a:	24 f0                	and    $0xf0,%al
  103f0c:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f11:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f18:	24 ef                	and    $0xef,%al
  103f1a:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f1f:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f26:	24 df                	and    $0xdf,%al
  103f28:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f2d:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f34:	0c 40                	or     $0x40,%al
  103f36:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f3b:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f42:	24 7f                	and    $0x7f,%al
  103f44:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f49:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  103f4e:	c1 e8 18             	shr    $0x18,%eax
  103f51:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103f56:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  103f5d:	e8 e3 fe ff ff       	call   103e45 <lgdt>
  103f62:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103f68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103f6c:	0f 00 d8             	ltr    %ax
}
  103f6f:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  103f70:	90                   	nop
  103f71:	89 ec                	mov    %ebp,%esp
  103f73:	5d                   	pop    %ebp
  103f74:	c3                   	ret    

00103f75 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103f75:	55                   	push   %ebp
  103f76:	89 e5                	mov    %esp,%ebp
  103f78:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103f7b:	c7 05 ac ce 11 00 b8 	movl   $0x106cb8,0x11ceac
  103f82:	6c 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103f85:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103f8a:	8b 00                	mov    (%eax),%eax
  103f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103f90:	c7 04 24 54 6d 10 00 	movl   $0x106d54,(%esp)
  103f97:	e8 ba c3 ff ff       	call   100356 <cprintf>
    pmm_manager->init();
  103f9c:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103fa1:	8b 40 04             	mov    0x4(%eax),%eax
  103fa4:	ff d0                	call   *%eax
}
  103fa6:	90                   	nop
  103fa7:	89 ec                	mov    %ebp,%esp
  103fa9:	5d                   	pop    %ebp
  103faa:	c3                   	ret    

00103fab <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103fab:	55                   	push   %ebp
  103fac:	89 e5                	mov    %esp,%ebp
  103fae:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103fb1:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103fb6:	8b 40 08             	mov    0x8(%eax),%eax
  103fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  103fbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  103fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  103fc3:	89 14 24             	mov    %edx,(%esp)
  103fc6:	ff d0                	call   *%eax
}
  103fc8:	90                   	nop
  103fc9:	89 ec                	mov    %ebp,%esp
  103fcb:	5d                   	pop    %ebp
  103fcc:	c3                   	ret    

00103fcd <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103fcd:	55                   	push   %ebp
  103fce:	89 e5                	mov    %esp,%ebp
  103fd0:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103fd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103fda:	e8 24 fe ff ff       	call   103e03 <__intr_save>
  103fdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103fe2:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  103fe7:	8b 40 0c             	mov    0xc(%eax),%eax
  103fea:	8b 55 08             	mov    0x8(%ebp),%edx
  103fed:	89 14 24             	mov    %edx,(%esp)
  103ff0:	ff d0                	call   *%eax
  103ff2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ff8:	89 04 24             	mov    %eax,(%esp)
  103ffb:	e8 2f fe ff ff       	call   103e2f <__intr_restore>
    return page;
  104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104003:	89 ec                	mov    %ebp,%esp
  104005:	5d                   	pop    %ebp
  104006:	c3                   	ret    

00104007 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  104007:	55                   	push   %ebp
  104008:	89 e5                	mov    %esp,%ebp
  10400a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10400d:	e8 f1 fd ff ff       	call   103e03 <__intr_save>
  104012:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  104015:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  10401a:	8b 40 10             	mov    0x10(%eax),%eax
  10401d:	8b 55 0c             	mov    0xc(%ebp),%edx
  104020:	89 54 24 04          	mov    %edx,0x4(%esp)
  104024:	8b 55 08             	mov    0x8(%ebp),%edx
  104027:	89 14 24             	mov    %edx,(%esp)
  10402a:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  10402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10402f:	89 04 24             	mov    %eax,(%esp)
  104032:	e8 f8 fd ff ff       	call   103e2f <__intr_restore>
}
  104037:	90                   	nop
  104038:	89 ec                	mov    %ebp,%esp
  10403a:	5d                   	pop    %ebp
  10403b:	c3                   	ret    

0010403c <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  10403c:	55                   	push   %ebp
  10403d:	89 e5                	mov    %esp,%ebp
  10403f:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  104042:	e8 bc fd ff ff       	call   103e03 <__intr_save>
  104047:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  10404a:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  10404f:	8b 40 14             	mov    0x14(%eax),%eax
  104052:	ff d0                	call   *%eax
  104054:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10405a:	89 04 24             	mov    %eax,(%esp)
  10405d:	e8 cd fd ff ff       	call   103e2f <__intr_restore>
    return ret;
  104062:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  104065:	89 ec                	mov    %ebp,%esp
  104067:	5d                   	pop    %ebp
  104068:	c3                   	ret    

00104069 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  104069:	55                   	push   %ebp
  10406a:	89 e5                	mov    %esp,%ebp
  10406c:	57                   	push   %edi
  10406d:	56                   	push   %esi
  10406e:	53                   	push   %ebx
  10406f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  104075:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  10407c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  104083:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  10408a:	c7 04 24 6b 6d 10 00 	movl   $0x106d6b,(%esp)
  104091:	e8 c0 c2 ff ff       	call   100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104096:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10409d:	e9 0c 01 00 00       	jmp    1041ae <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1040a2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040a8:	89 d0                	mov    %edx,%eax
  1040aa:	c1 e0 02             	shl    $0x2,%eax
  1040ad:	01 d0                	add    %edx,%eax
  1040af:	c1 e0 02             	shl    $0x2,%eax
  1040b2:	01 c8                	add    %ecx,%eax
  1040b4:	8b 50 08             	mov    0x8(%eax),%edx
  1040b7:	8b 40 04             	mov    0x4(%eax),%eax
  1040ba:	89 45 a0             	mov    %eax,-0x60(%ebp)
  1040bd:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  1040c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040c6:	89 d0                	mov    %edx,%eax
  1040c8:	c1 e0 02             	shl    $0x2,%eax
  1040cb:	01 d0                	add    %edx,%eax
  1040cd:	c1 e0 02             	shl    $0x2,%eax
  1040d0:	01 c8                	add    %ecx,%eax
  1040d2:	8b 48 0c             	mov    0xc(%eax),%ecx
  1040d5:	8b 58 10             	mov    0x10(%eax),%ebx
  1040d8:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040db:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1040de:	01 c8                	add    %ecx,%eax
  1040e0:	11 da                	adc    %ebx,%edx
  1040e2:	89 45 98             	mov    %eax,-0x68(%ebp)
  1040e5:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  1040e8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040ee:	89 d0                	mov    %edx,%eax
  1040f0:	c1 e0 02             	shl    $0x2,%eax
  1040f3:	01 d0                	add    %edx,%eax
  1040f5:	c1 e0 02             	shl    $0x2,%eax
  1040f8:	01 c8                	add    %ecx,%eax
  1040fa:	83 c0 14             	add    $0x14,%eax
  1040fd:	8b 00                	mov    (%eax),%eax
  1040ff:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104105:	8b 45 98             	mov    -0x68(%ebp),%eax
  104108:	8b 55 9c             	mov    -0x64(%ebp),%edx
  10410b:	83 c0 ff             	add    $0xffffffff,%eax
  10410e:	83 d2 ff             	adc    $0xffffffff,%edx
  104111:	89 c6                	mov    %eax,%esi
  104113:	89 d7                	mov    %edx,%edi
  104115:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104118:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10411b:	89 d0                	mov    %edx,%eax
  10411d:	c1 e0 02             	shl    $0x2,%eax
  104120:	01 d0                	add    %edx,%eax
  104122:	c1 e0 02             	shl    $0x2,%eax
  104125:	01 c8                	add    %ecx,%eax
  104127:	8b 48 0c             	mov    0xc(%eax),%ecx
  10412a:	8b 58 10             	mov    0x10(%eax),%ebx
  10412d:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104133:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  104137:	89 74 24 14          	mov    %esi,0x14(%esp)
  10413b:	89 7c 24 18          	mov    %edi,0x18(%esp)
  10413f:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104142:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104145:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104149:	89 54 24 10          	mov    %edx,0x10(%esp)
  10414d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104151:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104155:	c7 04 24 78 6d 10 00 	movl   $0x106d78,(%esp)
  10415c:	e8 f5 c1 ff ff       	call   100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  104161:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104164:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104167:	89 d0                	mov    %edx,%eax
  104169:	c1 e0 02             	shl    $0x2,%eax
  10416c:	01 d0                	add    %edx,%eax
  10416e:	c1 e0 02             	shl    $0x2,%eax
  104171:	01 c8                	add    %ecx,%eax
  104173:	83 c0 14             	add    $0x14,%eax
  104176:	8b 00                	mov    (%eax),%eax
  104178:	83 f8 01             	cmp    $0x1,%eax
  10417b:	75 2e                	jne    1041ab <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  10417d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104180:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104183:	3b 45 98             	cmp    -0x68(%ebp),%eax
  104186:	89 d0                	mov    %edx,%eax
  104188:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  10418b:	73 1e                	jae    1041ab <page_init+0x142>
  10418d:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  104192:	b8 00 00 00 00       	mov    $0x0,%eax
  104197:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  10419a:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  10419d:	72 0c                	jb     1041ab <page_init+0x142>
                maxpa = end;
  10419f:	8b 45 98             	mov    -0x68(%ebp),%eax
  1041a2:	8b 55 9c             	mov    -0x64(%ebp),%edx
  1041a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1041a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  1041ab:	ff 45 dc             	incl   -0x24(%ebp)
  1041ae:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1041b1:	8b 00                	mov    (%eax),%eax
  1041b3:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1041b6:	0f 8c e6 fe ff ff    	jl     1040a2 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  1041bc:	ba 00 00 00 38       	mov    $0x38000000,%edx
  1041c1:	b8 00 00 00 00       	mov    $0x0,%eax
  1041c6:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  1041c9:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  1041cc:	73 0e                	jae    1041dc <page_init+0x173>
        maxpa = KMEMSIZE;
  1041ce:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  1041d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  1041dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1041df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1041e2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1041e6:	c1 ea 0c             	shr    $0xc,%edx
  1041e9:	a3 a4 ce 11 00       	mov    %eax,0x11cea4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  1041ee:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  1041f5:	b8 2c cf 11 00       	mov    $0x11cf2c,%eax
  1041fa:	8d 50 ff             	lea    -0x1(%eax),%edx
  1041fd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104200:	01 d0                	add    %edx,%eax
  104202:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104205:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104208:	ba 00 00 00 00       	mov    $0x0,%edx
  10420d:	f7 75 c0             	divl   -0x40(%ebp)
  104210:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104213:	29 d0                	sub    %edx,%eax
  104215:	a3 a0 ce 11 00       	mov    %eax,0x11cea0

    for (i = 0; i < npage; i ++) {
  10421a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104221:	eb 2f                	jmp    104252 <page_init+0x1e9>
        SetPageReserved(pages + i);
  104223:	8b 0d a0 ce 11 00    	mov    0x11cea0,%ecx
  104229:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10422c:	89 d0                	mov    %edx,%eax
  10422e:	c1 e0 02             	shl    $0x2,%eax
  104231:	01 d0                	add    %edx,%eax
  104233:	c1 e0 02             	shl    $0x2,%eax
  104236:	01 c8                	add    %ecx,%eax
  104238:	83 c0 04             	add    $0x4,%eax
  10423b:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  104242:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104245:	8b 45 90             	mov    -0x70(%ebp),%eax
  104248:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10424b:	0f ab 10             	bts    %edx,(%eax)
}
  10424e:	90                   	nop
    for (i = 0; i < npage; i ++) {
  10424f:	ff 45 dc             	incl   -0x24(%ebp)
  104252:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104255:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  10425a:	39 c2                	cmp    %eax,%edx
  10425c:	72 c5                	jb     104223 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  10425e:	8b 15 a4 ce 11 00    	mov    0x11cea4,%edx
  104264:	89 d0                	mov    %edx,%eax
  104266:	c1 e0 02             	shl    $0x2,%eax
  104269:	01 d0                	add    %edx,%eax
  10426b:	c1 e0 02             	shl    $0x2,%eax
  10426e:	89 c2                	mov    %eax,%edx
  104270:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  104275:	01 d0                	add    %edx,%eax
  104277:	89 45 b8             	mov    %eax,-0x48(%ebp)
  10427a:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  104281:	77 23                	ja     1042a6 <page_init+0x23d>
  104283:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104286:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10428a:	c7 44 24 08 a8 6d 10 	movl   $0x106da8,0x8(%esp)
  104291:	00 
  104292:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  104299:	00 
  10429a:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1042a1:	e8 59 ca ff ff       	call   100cff <__panic>
  1042a6:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1042a9:	05 00 00 00 40       	add    $0x40000000,%eax
  1042ae:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1042b1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1042b8:	e9 53 01 00 00       	jmp    104410 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1042bd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1042c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042c3:	89 d0                	mov    %edx,%eax
  1042c5:	c1 e0 02             	shl    $0x2,%eax
  1042c8:	01 d0                	add    %edx,%eax
  1042ca:	c1 e0 02             	shl    $0x2,%eax
  1042cd:	01 c8                	add    %ecx,%eax
  1042cf:	8b 50 08             	mov    0x8(%eax),%edx
  1042d2:	8b 40 04             	mov    0x4(%eax),%eax
  1042d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1042d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1042db:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1042de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042e1:	89 d0                	mov    %edx,%eax
  1042e3:	c1 e0 02             	shl    $0x2,%eax
  1042e6:	01 d0                	add    %edx,%eax
  1042e8:	c1 e0 02             	shl    $0x2,%eax
  1042eb:	01 c8                	add    %ecx,%eax
  1042ed:	8b 48 0c             	mov    0xc(%eax),%ecx
  1042f0:	8b 58 10             	mov    0x10(%eax),%ebx
  1042f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1042f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042f9:	01 c8                	add    %ecx,%eax
  1042fb:	11 da                	adc    %ebx,%edx
  1042fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104300:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104303:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104306:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104309:	89 d0                	mov    %edx,%eax
  10430b:	c1 e0 02             	shl    $0x2,%eax
  10430e:	01 d0                	add    %edx,%eax
  104310:	c1 e0 02             	shl    $0x2,%eax
  104313:	01 c8                	add    %ecx,%eax
  104315:	83 c0 14             	add    $0x14,%eax
  104318:	8b 00                	mov    (%eax),%eax
  10431a:	83 f8 01             	cmp    $0x1,%eax
  10431d:	0f 85 ea 00 00 00    	jne    10440d <page_init+0x3a4>
            if (begin < freemem) {
  104323:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104326:	ba 00 00 00 00       	mov    $0x0,%edx
  10432b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10432e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  104331:	19 d1                	sbb    %edx,%ecx
  104333:	73 0d                	jae    104342 <page_init+0x2d9>
                begin = freemem;
  104335:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104338:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10433b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  104342:	ba 00 00 00 38       	mov    $0x38000000,%edx
  104347:	b8 00 00 00 00       	mov    $0x0,%eax
  10434c:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  10434f:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104352:	73 0e                	jae    104362 <page_init+0x2f9>
                end = KMEMSIZE;
  104354:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  10435b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104362:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104365:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104368:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10436b:	89 d0                	mov    %edx,%eax
  10436d:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104370:	0f 83 97 00 00 00    	jae    10440d <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  104376:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  10437d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104380:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104383:	01 d0                	add    %edx,%eax
  104385:	48                   	dec    %eax
  104386:	89 45 ac             	mov    %eax,-0x54(%ebp)
  104389:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10438c:	ba 00 00 00 00       	mov    $0x0,%edx
  104391:	f7 75 b0             	divl   -0x50(%ebp)
  104394:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104397:	29 d0                	sub    %edx,%eax
  104399:	ba 00 00 00 00       	mov    $0x0,%edx
  10439e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1043a1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1043a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1043a7:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1043aa:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1043ad:	ba 00 00 00 00       	mov    $0x0,%edx
  1043b2:	89 c7                	mov    %eax,%edi
  1043b4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  1043ba:	89 7d 80             	mov    %edi,-0x80(%ebp)
  1043bd:	89 d0                	mov    %edx,%eax
  1043bf:	83 e0 00             	and    $0x0,%eax
  1043c2:	89 45 84             	mov    %eax,-0x7c(%ebp)
  1043c5:	8b 45 80             	mov    -0x80(%ebp),%eax
  1043c8:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1043cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1043ce:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  1043d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043d7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1043da:	89 d0                	mov    %edx,%eax
  1043dc:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1043df:	73 2c                	jae    10440d <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1043e1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1043e4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1043e7:	2b 45 d0             	sub    -0x30(%ebp),%eax
  1043ea:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  1043ed:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1043f1:	c1 ea 0c             	shr    $0xc,%edx
  1043f4:	89 c3                	mov    %eax,%ebx
  1043f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043f9:	89 04 24             	mov    %eax,(%esp)
  1043fc:	e8 bb f8 ff ff       	call   103cbc <pa2page>
  104401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104405:	89 04 24             	mov    %eax,(%esp)
  104408:	e8 9e fb ff ff       	call   103fab <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  10440d:	ff 45 dc             	incl   -0x24(%ebp)
  104410:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104413:	8b 00                	mov    (%eax),%eax
  104415:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104418:	0f 8c 9f fe ff ff    	jl     1042bd <page_init+0x254>
                }
            }
        }
    }
}
  10441e:	90                   	nop
  10441f:	90                   	nop
  104420:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104426:	5b                   	pop    %ebx
  104427:	5e                   	pop    %esi
  104428:	5f                   	pop    %edi
  104429:	5d                   	pop    %ebp
  10442a:	c3                   	ret    

0010442b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10442b:	55                   	push   %ebp
  10442c:	89 e5                	mov    %esp,%ebp
  10442e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104431:	8b 45 0c             	mov    0xc(%ebp),%eax
  104434:	33 45 14             	xor    0x14(%ebp),%eax
  104437:	25 ff 0f 00 00       	and    $0xfff,%eax
  10443c:	85 c0                	test   %eax,%eax
  10443e:	74 24                	je     104464 <boot_map_segment+0x39>
  104440:	c7 44 24 0c da 6d 10 	movl   $0x106dda,0xc(%esp)
  104447:	00 
  104448:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10444f:	00 
  104450:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104457:	00 
  104458:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10445f:	e8 9b c8 ff ff       	call   100cff <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104464:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10446b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10446e:	25 ff 0f 00 00       	and    $0xfff,%eax
  104473:	89 c2                	mov    %eax,%edx
  104475:	8b 45 10             	mov    0x10(%ebp),%eax
  104478:	01 c2                	add    %eax,%edx
  10447a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10447d:	01 d0                	add    %edx,%eax
  10447f:	48                   	dec    %eax
  104480:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104483:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104486:	ba 00 00 00 00       	mov    $0x0,%edx
  10448b:	f7 75 f0             	divl   -0x10(%ebp)
  10448e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104491:	29 d0                	sub    %edx,%eax
  104493:	c1 e8 0c             	shr    $0xc,%eax
  104496:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104499:	8b 45 0c             	mov    0xc(%ebp),%eax
  10449c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10449f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1044a7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1044aa:	8b 45 14             	mov    0x14(%ebp),%eax
  1044ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1044b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1044b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1044b8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1044bb:	eb 68                	jmp    104525 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1044bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1044c4:	00 
  1044c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1044cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1044cf:	89 04 24             	mov    %eax,(%esp)
  1044d2:	e8 88 01 00 00       	call   10465f <get_pte>
  1044d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1044da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1044de:	75 24                	jne    104504 <boot_map_segment+0xd9>
  1044e0:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  1044e7:	00 
  1044e8:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  1044ef:	00 
  1044f0:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1044f7:	00 
  1044f8:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1044ff:	e8 fb c7 ff ff       	call   100cff <__panic>
        *ptep = pa | PTE_P | perm;
  104504:	8b 45 14             	mov    0x14(%ebp),%eax
  104507:	0b 45 18             	or     0x18(%ebp),%eax
  10450a:	83 c8 01             	or     $0x1,%eax
  10450d:	89 c2                	mov    %eax,%edx
  10450f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104512:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104514:	ff 4d f4             	decl   -0xc(%ebp)
  104517:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10451e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104525:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104529:	75 92                	jne    1044bd <boot_map_segment+0x92>
    }
}
  10452b:	90                   	nop
  10452c:	90                   	nop
  10452d:	89 ec                	mov    %ebp,%esp
  10452f:	5d                   	pop    %ebp
  104530:	c3                   	ret    

00104531 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104531:	55                   	push   %ebp
  104532:	89 e5                	mov    %esp,%ebp
  104534:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  104537:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10453e:	e8 8a fa ff ff       	call   103fcd <alloc_pages>
  104543:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10454a:	75 1c                	jne    104568 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10454c:	c7 44 24 08 13 6e 10 	movl   $0x106e13,0x8(%esp)
  104553:	00 
  104554:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10455b:	00 
  10455c:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104563:	e8 97 c7 ff ff       	call   100cff <__panic>
    }
    return page2kva(p);
  104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10456b:	89 04 24             	mov    %eax,(%esp)
  10456e:	e8 9a f7 ff ff       	call   103d0d <page2kva>
}
  104573:	89 ec                	mov    %ebp,%esp
  104575:	5d                   	pop    %ebp
  104576:	c3                   	ret    

00104577 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104577:	55                   	push   %ebp
  104578:	89 e5                	mov    %esp,%ebp
  10457a:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10457d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104582:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104585:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10458c:	77 23                	ja     1045b1 <pmm_init+0x3a>
  10458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104591:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104595:	c7 44 24 08 a8 6d 10 	movl   $0x106da8,0x8(%esp)
  10459c:	00 
  10459d:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1045a4:	00 
  1045a5:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1045ac:	e8 4e c7 ff ff       	call   100cff <__panic>
  1045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b4:	05 00 00 00 40       	add    $0x40000000,%eax
  1045b9:	a3 a8 ce 11 00       	mov    %eax,0x11cea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1045be:	e8 b2 f9 ff ff       	call   103f75 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1045c3:	e8 a1 fa ff ff       	call   104069 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1045c8:	e8 51 04 00 00       	call   104a1e <check_alloc_page>

    check_pgdir();
  1045cd:	e8 6d 04 00 00       	call   104a3f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1045d2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1045d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1045da:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1045e1:	77 23                	ja     104606 <pmm_init+0x8f>
  1045e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1045ea:	c7 44 24 08 a8 6d 10 	movl   $0x106da8,0x8(%esp)
  1045f1:	00 
  1045f2:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1045f9:	00 
  1045fa:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104601:	e8 f9 c6 ff ff       	call   100cff <__panic>
  104606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104609:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10460f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104614:	05 ac 0f 00 00       	add    $0xfac,%eax
  104619:	83 ca 03             	or     $0x3,%edx
  10461c:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10461e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104623:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10462a:	00 
  10462b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104632:	00 
  104633:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  10463a:	38 
  10463b:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  104642:	c0 
  104643:	89 04 24             	mov    %eax,(%esp)
  104646:	e8 e0 fd ff ff       	call   10442b <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  10464b:	e8 39 f8 ff ff       	call   103e89 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  104650:	e8 88 0a 00 00       	call   1050dd <check_boot_pgdir>

    print_pgdir();
  104655:	e8 05 0f 00 00       	call   10555f <print_pgdir>

}
  10465a:	90                   	nop
  10465b:	89 ec                	mov    %ebp,%esp
  10465d:	5d                   	pop    %ebp
  10465e:	c3                   	ret    

0010465f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10465f:	55                   	push   %ebp
  104660:	89 e5                	mov    %esp,%ebp
  104662:	83 ec 38             	sub    $0x38,%esp
    }
    return NULL;          // (8) return page table entry
#endif

    
    pde_t *pdep=pgdir+PDX(la);
  104665:	8b 45 0c             	mov    0xc(%ebp),%eax
  104668:	c1 e8 16             	shr    $0x16,%eax
  10466b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104672:	8b 45 08             	mov    0x8(%ebp),%eax
  104675:	01 d0                	add    %edx,%eax
  104677:	89 45 f4             	mov    %eax,-0xc(%ebp)

    pte_t *ptep=((pte_t*)KADDR(*pdep& ~0xfff))+PTX(la);
  10467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10467d:	8b 00                	mov    (%eax),%eax
  10467f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104684:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10468a:	c1 e8 0c             	shr    $0xc,%eax
  10468d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104690:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  104695:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104698:	72 23                	jb     1046bd <get_pte+0x5e>
  10469a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10469d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1046a1:	c7 44 24 08 04 6d 10 	movl   $0x106d04,0x8(%esp)
  1046a8:	00 
  1046a9:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
  1046b0:	00 
  1046b1:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1046b8:	e8 42 c6 ff ff       	call   100cff <__panic>
  1046bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1046c5:	89 c2                	mov    %eax,%edx
  1046c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046ca:	c1 e8 0c             	shr    $0xc,%eax
  1046cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  1046d2:	c1 e0 02             	shl    $0x2,%eax
  1046d5:	01 d0                	add    %edx,%eax
  1046d7:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(*pdep & PTE_P) return ptep;
  1046da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046dd:	8b 00                	mov    (%eax),%eax
  1046df:	83 e0 01             	and    $0x1,%eax
  1046e2:	85 c0                	test   %eax,%eax
  1046e4:	74 08                	je     1046ee <get_pte+0x8f>
  1046e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1046e9:	e9 dd 00 00 00       	jmp    1047cb <get_pte+0x16c>
    
    if (!create) return NULL;
  1046ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1046f2:	75 0a                	jne    1046fe <get_pte+0x9f>
  1046f4:	b8 00 00 00 00       	mov    $0x0,%eax
  1046f9:	e9 cd 00 00 00       	jmp    1047cb <get_pte+0x16c>

   struct Page *p=alloc_page();
  1046fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104705:	e8 c3 f8 ff ff       	call   103fcd <alloc_pages>
  10470a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   if(p==NULL) return NULL;
  10470d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104711:	75 0a                	jne    10471d <get_pte+0xbe>
  104713:	b8 00 00 00 00       	mov    $0x0,%eax
  104718:	e9 ae 00 00 00       	jmp    1047cb <get_pte+0x16c>

   set_page_ref(p,1);
  10471d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104724:	00 
  104725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104728:	89 04 24             	mov    %eax,(%esp)
  10472b:	e8 97 f6 ff ff       	call   103dc7 <set_page_ref>

   ptep= KADDR(page2pa(p));
  104730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104733:	89 04 24             	mov    %eax,(%esp)
  104736:	e8 69 f5 ff ff       	call   103ca4 <page2pa>
  10473b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10473e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104741:	c1 e8 0c             	shr    $0xc,%eax
  104744:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104747:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  10474c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10474f:	72 23                	jb     104774 <get_pte+0x115>
  104751:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104754:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104758:	c7 44 24 08 04 6d 10 	movl   $0x106d04,0x8(%esp)
  10475f:	00 
  104760:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
  104767:	00 
  104768:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10476f:	e8 8b c5 ff ff       	call   100cff <__panic>
  104774:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104777:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10477c:	89 45 e8             	mov    %eax,-0x18(%ebp)

   memset(ptep,0,PGSIZE);
  10477f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104786:	00 
  104787:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10478e:	00 
  10478f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104792:	89 04 24             	mov    %eax,(%esp)
  104795:	e8 ca 18 00 00       	call   106064 <memset>

   //更改原来的页目录项
   *pdep=(page2pa(p)&~0xfff)|PTE_U|PTE_P|PTE_W;
  10479a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10479d:	89 04 24             	mov    %eax,(%esp)
  1047a0:	e8 ff f4 ff ff       	call   103ca4 <page2pa>
  1047a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1047aa:	83 c8 07             	or     $0x7,%eax
  1047ad:	89 c2                	mov    %eax,%edx
  1047af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047b2:	89 10                	mov    %edx,(%eax)

   return ptep+PTX(la);
  1047b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047b7:	c1 e8 0c             	shr    $0xc,%eax
  1047ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  1047bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1047c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1047c9:	01 d0                	add    %edx,%eax
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];*/


}
  1047cb:	89 ec                	mov    %ebp,%esp
  1047cd:	5d                   	pop    %ebp
  1047ce:	c3                   	ret    

001047cf <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1047cf:	55                   	push   %ebp
  1047d0:	89 e5                	mov    %esp,%ebp
  1047d2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1047d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1047dc:	00 
  1047dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1047e7:	89 04 24             	mov    %eax,(%esp)
  1047ea:	e8 70 fe ff ff       	call   10465f <get_pte>
  1047ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1047f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1047f6:	74 08                	je     104800 <get_page+0x31>
        *ptep_store = ptep;
  1047f8:	8b 45 10             	mov    0x10(%ebp),%eax
  1047fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1047fe:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104800:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104804:	74 1b                	je     104821 <get_page+0x52>
  104806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104809:	8b 00                	mov    (%eax),%eax
  10480b:	83 e0 01             	and    $0x1,%eax
  10480e:	85 c0                	test   %eax,%eax
  104810:	74 0f                	je     104821 <get_page+0x52>
        return pte2page(*ptep);
  104812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104815:	8b 00                	mov    (%eax),%eax
  104817:	89 04 24             	mov    %eax,(%esp)
  10481a:	e8 44 f5 ff ff       	call   103d63 <pte2page>
  10481f:	eb 05                	jmp    104826 <get_page+0x57>
    }
    return NULL;
  104821:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104826:	89 ec                	mov    %ebp,%esp
  104828:	5d                   	pop    %ebp
  104829:	c3                   	ret    

0010482a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10482a:	55                   	push   %ebp
  10482b:	89 e5                	mov    %esp,%ebp
  10482d:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    assert(*ptep & PTE_P);
  104830:	8b 45 10             	mov    0x10(%ebp),%eax
  104833:	8b 00                	mov    (%eax),%eax
  104835:	83 e0 01             	and    $0x1,%eax
  104838:	85 c0                	test   %eax,%eax
  10483a:	75 24                	jne    104860 <page_remove_pte+0x36>
  10483c:	c7 44 24 0c 2c 6e 10 	movl   $0x106e2c,0xc(%esp)
  104843:	00 
  104844:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10484b:	00 
  10484c:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
  104853:	00 
  104854:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10485b:	e8 9f c4 ff ff       	call   100cff <__panic>
    struct Page *p=pte2page(*ptep);
  104860:	8b 45 10             	mov    0x10(%ebp),%eax
  104863:	8b 00                	mov    (%eax),%eax
  104865:	89 04 24             	mov    %eax,(%esp)
  104868:	e8 f6 f4 ff ff       	call   103d63 <pte2page>
  10486d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    page_ref_dec(p);
  104870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104873:	89 04 24             	mov    %eax,(%esp)
  104876:	e8 71 f5 ff ff       	call   103dec <page_ref_dec>
    if(p->ref==0)
  10487b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10487e:	8b 00                	mov    (%eax),%eax
  104880:	85 c0                	test   %eax,%eax
  104882:	75 13                	jne    104897 <page_remove_pte+0x6d>
    {
        free_page(p);
  104884:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10488b:	00 
  10488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10488f:	89 04 24             	mov    %eax,(%esp)
  104892:	e8 70 f7 ff ff       	call   104007 <free_pages>
    }
    *ptep&=~(PTE_P);
  104897:	8b 45 10             	mov    0x10(%ebp),%eax
  10489a:	8b 00                	mov    (%eax),%eax
  10489c:	83 e0 fe             	and    $0xfffffffe,%eax
  10489f:	89 c2                	mov    %eax,%edx
  1048a1:	8b 45 10             	mov    0x10(%ebp),%eax
  1048a4:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir,la);
  1048a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1048b0:	89 04 24             	mov    %eax,(%esp)
  1048b3:	e8 07 01 00 00       	call   1049bf <tlb_invalidate>
        *ptep = 0;
        tlb_invalidate(pgdir, la);
    }*/


}
  1048b8:	90                   	nop
  1048b9:	89 ec                	mov    %ebp,%esp
  1048bb:	5d                   	pop    %ebp
  1048bc:	c3                   	ret    

001048bd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1048bd:	55                   	push   %ebp
  1048be:	89 e5                	mov    %esp,%ebp
  1048c0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1048c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048ca:	00 
  1048cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1048d5:	89 04 24             	mov    %eax,(%esp)
  1048d8:	e8 82 fd ff ff       	call   10465f <get_pte>
  1048dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1048e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048e4:	74 19                	je     1048ff <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1048ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1048f7:	89 04 24             	mov    %eax,(%esp)
  1048fa:	e8 2b ff ff ff       	call   10482a <page_remove_pte>
    }
}
  1048ff:	90                   	nop
  104900:	89 ec                	mov    %ebp,%esp
  104902:	5d                   	pop    %ebp
  104903:	c3                   	ret    

00104904 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104904:	55                   	push   %ebp
  104905:	89 e5                	mov    %esp,%ebp
  104907:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10490a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104911:	00 
  104912:	8b 45 10             	mov    0x10(%ebp),%eax
  104915:	89 44 24 04          	mov    %eax,0x4(%esp)
  104919:	8b 45 08             	mov    0x8(%ebp),%eax
  10491c:	89 04 24             	mov    %eax,(%esp)
  10491f:	e8 3b fd ff ff       	call   10465f <get_pte>
  104924:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104927:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10492b:	75 0a                	jne    104937 <page_insert+0x33>
        return -E_NO_MEM;
  10492d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  104932:	e9 84 00 00 00       	jmp    1049bb <page_insert+0xb7>
    }
    page_ref_inc(page);
  104937:	8b 45 0c             	mov    0xc(%ebp),%eax
  10493a:	89 04 24             	mov    %eax,(%esp)
  10493d:	e8 93 f4 ff ff       	call   103dd5 <page_ref_inc>
    if (*ptep & PTE_P) {
  104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104945:	8b 00                	mov    (%eax),%eax
  104947:	83 e0 01             	and    $0x1,%eax
  10494a:	85 c0                	test   %eax,%eax
  10494c:	74 3e                	je     10498c <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10494e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104951:	8b 00                	mov    (%eax),%eax
  104953:	89 04 24             	mov    %eax,(%esp)
  104956:	e8 08 f4 ff ff       	call   103d63 <pte2page>
  10495b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10495e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104961:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104964:	75 0d                	jne    104973 <page_insert+0x6f>
            page_ref_dec(page);
  104966:	8b 45 0c             	mov    0xc(%ebp),%eax
  104969:	89 04 24             	mov    %eax,(%esp)
  10496c:	e8 7b f4 ff ff       	call   103dec <page_ref_dec>
  104971:	eb 19                	jmp    10498c <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104976:	89 44 24 08          	mov    %eax,0x8(%esp)
  10497a:	8b 45 10             	mov    0x10(%ebp),%eax
  10497d:	89 44 24 04          	mov    %eax,0x4(%esp)
  104981:	8b 45 08             	mov    0x8(%ebp),%eax
  104984:	89 04 24             	mov    %eax,(%esp)
  104987:	e8 9e fe ff ff       	call   10482a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  10498c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10498f:	89 04 24             	mov    %eax,(%esp)
  104992:	e8 0d f3 ff ff       	call   103ca4 <page2pa>
  104997:	0b 45 14             	or     0x14(%ebp),%eax
  10499a:	83 c8 01             	or     $0x1,%eax
  10499d:	89 c2                	mov    %eax,%edx
  10499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049a2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1049a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1049a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1049ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1049ae:	89 04 24             	mov    %eax,(%esp)
  1049b1:	e8 09 00 00 00       	call   1049bf <tlb_invalidate>
    return 0;
  1049b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1049bb:	89 ec                	mov    %ebp,%esp
  1049bd:	5d                   	pop    %ebp
  1049be:	c3                   	ret    

001049bf <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1049bf:	55                   	push   %ebp
  1049c0:	89 e5                	mov    %esp,%ebp
  1049c2:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1049c5:	0f 20 d8             	mov    %cr3,%eax
  1049c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1049cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1049ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1049d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1049d4:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1049db:	77 23                	ja     104a00 <tlb_invalidate+0x41>
  1049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1049e4:	c7 44 24 08 a8 6d 10 	movl   $0x106da8,0x8(%esp)
  1049eb:	00 
  1049ec:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  1049f3:	00 
  1049f4:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1049fb:	e8 ff c2 ff ff       	call   100cff <__panic>
  104a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a03:	05 00 00 00 40       	add    $0x40000000,%eax
  104a08:	39 d0                	cmp    %edx,%eax
  104a0a:	75 0d                	jne    104a19 <tlb_invalidate+0x5a>
        invlpg((void *)la);
  104a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  104a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  104a12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a15:	0f 01 38             	invlpg (%eax)
}
  104a18:	90                   	nop
    }
}
  104a19:	90                   	nop
  104a1a:	89 ec                	mov    %ebp,%esp
  104a1c:	5d                   	pop    %ebp
  104a1d:	c3                   	ret    

00104a1e <check_alloc_page>:

static void
check_alloc_page(void) {
  104a1e:	55                   	push   %ebp
  104a1f:	89 e5                	mov    %esp,%ebp
  104a21:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  104a24:	a1 ac ce 11 00       	mov    0x11ceac,%eax
  104a29:	8b 40 18             	mov    0x18(%eax),%eax
  104a2c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104a2e:	c7 04 24 3c 6e 10 00 	movl   $0x106e3c,(%esp)
  104a35:	e8 1c b9 ff ff       	call   100356 <cprintf>
}
  104a3a:	90                   	nop
  104a3b:	89 ec                	mov    %ebp,%esp
  104a3d:	5d                   	pop    %ebp
  104a3e:	c3                   	ret    

00104a3f <check_pgdir>:

static void
check_pgdir(void) {
  104a3f:	55                   	push   %ebp
  104a40:	89 e5                	mov    %esp,%ebp
  104a42:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104a45:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  104a4a:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104a4f:	76 24                	jbe    104a75 <check_pgdir+0x36>
  104a51:	c7 44 24 0c 5b 6e 10 	movl   $0x106e5b,0xc(%esp)
  104a58:	00 
  104a59:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104a60:	00 
  104a61:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104a68:	00 
  104a69:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104a70:	e8 8a c2 ff ff       	call   100cff <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104a75:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104a7a:	85 c0                	test   %eax,%eax
  104a7c:	74 0e                	je     104a8c <check_pgdir+0x4d>
  104a7e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104a83:	25 ff 0f 00 00       	and    $0xfff,%eax
  104a88:	85 c0                	test   %eax,%eax
  104a8a:	74 24                	je     104ab0 <check_pgdir+0x71>
  104a8c:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  104a93:	00 
  104a94:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104a9b:	00 
  104a9c:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  104aa3:	00 
  104aa4:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104aab:	e8 4f c2 ff ff       	call   100cff <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104ab0:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ab5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104abc:	00 
  104abd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104ac4:	00 
  104ac5:	89 04 24             	mov    %eax,(%esp)
  104ac8:	e8 02 fd ff ff       	call   1047cf <get_page>
  104acd:	85 c0                	test   %eax,%eax
  104acf:	74 24                	je     104af5 <check_pgdir+0xb6>
  104ad1:	c7 44 24 0c b0 6e 10 	movl   $0x106eb0,0xc(%esp)
  104ad8:	00 
  104ad9:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104ae0:	00 
  104ae1:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104ae8:	00 
  104ae9:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104af0:	e8 0a c2 ff ff       	call   100cff <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104af5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104afc:	e8 cc f4 ff ff       	call   103fcd <alloc_pages>
  104b01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  104b04:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104b09:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104b10:	00 
  104b11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b18:	00 
  104b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  104b20:	89 04 24             	mov    %eax,(%esp)
  104b23:	e8 dc fd ff ff       	call   104904 <page_insert>
  104b28:	85 c0                	test   %eax,%eax
  104b2a:	74 24                	je     104b50 <check_pgdir+0x111>
  104b2c:	c7 44 24 0c d8 6e 10 	movl   $0x106ed8,0xc(%esp)
  104b33:	00 
  104b34:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104b3b:	00 
  104b3c:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  104b43:	00 
  104b44:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104b4b:	e8 af c1 ff ff       	call   100cff <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104b50:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104b55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b5c:	00 
  104b5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104b64:	00 
  104b65:	89 04 24             	mov    %eax,(%esp)
  104b68:	e8 f2 fa ff ff       	call   10465f <get_pte>
  104b6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b74:	75 24                	jne    104b9a <check_pgdir+0x15b>
  104b76:	c7 44 24 0c 04 6f 10 	movl   $0x106f04,0xc(%esp)
  104b7d:	00 
  104b7e:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104b85:	00 
  104b86:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  104b8d:	00 
  104b8e:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104b95:	e8 65 c1 ff ff       	call   100cff <__panic>
    assert(pte2page(*ptep) == p1);
  104b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b9d:	8b 00                	mov    (%eax),%eax
  104b9f:	89 04 24             	mov    %eax,(%esp)
  104ba2:	e8 bc f1 ff ff       	call   103d63 <pte2page>
  104ba7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104baa:	74 24                	je     104bd0 <check_pgdir+0x191>
  104bac:	c7 44 24 0c 31 6f 10 	movl   $0x106f31,0xc(%esp)
  104bb3:	00 
  104bb4:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104bbb:	00 
  104bbc:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104bc3:	00 
  104bc4:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104bcb:	e8 2f c1 ff ff       	call   100cff <__panic>
    assert(page_ref(p1) == 1);
  104bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bd3:	89 04 24             	mov    %eax,(%esp)
  104bd6:	e8 e2 f1 ff ff       	call   103dbd <page_ref>
  104bdb:	83 f8 01             	cmp    $0x1,%eax
  104bde:	74 24                	je     104c04 <check_pgdir+0x1c5>
  104be0:	c7 44 24 0c 47 6f 10 	movl   $0x106f47,0xc(%esp)
  104be7:	00 
  104be8:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104bef:	00 
  104bf0:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  104bf7:	00 
  104bf8:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104bff:	e8 fb c0 ff ff       	call   100cff <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104c04:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104c09:	8b 00                	mov    (%eax),%eax
  104c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104c10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c16:	c1 e8 0c             	shr    $0xc,%eax
  104c19:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104c1c:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  104c21:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104c24:	72 23                	jb     104c49 <check_pgdir+0x20a>
  104c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104c2d:	c7 44 24 08 04 6d 10 	movl   $0x106d04,0x8(%esp)
  104c34:	00 
  104c35:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  104c3c:	00 
  104c3d:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104c44:	e8 b6 c0 ff ff       	call   100cff <__panic>
  104c49:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c4c:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104c51:	83 c0 04             	add    $0x4,%eax
  104c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104c57:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104c5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c63:	00 
  104c64:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c6b:	00 
  104c6c:	89 04 24             	mov    %eax,(%esp)
  104c6f:	e8 eb f9 ff ff       	call   10465f <get_pte>
  104c74:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104c77:	74 24                	je     104c9d <check_pgdir+0x25e>
  104c79:	c7 44 24 0c 5c 6f 10 	movl   $0x106f5c,0xc(%esp)
  104c80:	00 
  104c81:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104c88:	00 
  104c89:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104c90:	00 
  104c91:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104c98:	e8 62 c0 ff ff       	call   100cff <__panic>

    p2 = alloc_page();
  104c9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ca4:	e8 24 f3 ff ff       	call   103fcd <alloc_pages>
  104ca9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104cac:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104cb1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104cb8:	00 
  104cb9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104cc0:	00 
  104cc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104cc4:	89 54 24 04          	mov    %edx,0x4(%esp)
  104cc8:	89 04 24             	mov    %eax,(%esp)
  104ccb:	e8 34 fc ff ff       	call   104904 <page_insert>
  104cd0:	85 c0                	test   %eax,%eax
  104cd2:	74 24                	je     104cf8 <check_pgdir+0x2b9>
  104cd4:	c7 44 24 0c 84 6f 10 	movl   $0x106f84,0xc(%esp)
  104cdb:	00 
  104cdc:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104ce3:	00 
  104ce4:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  104ceb:	00 
  104cec:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104cf3:	e8 07 c0 ff ff       	call   100cff <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104cf8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104cfd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104d04:	00 
  104d05:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d0c:	00 
  104d0d:	89 04 24             	mov    %eax,(%esp)
  104d10:	e8 4a f9 ff ff       	call   10465f <get_pte>
  104d15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104d1c:	75 24                	jne    104d42 <check_pgdir+0x303>
  104d1e:	c7 44 24 0c bc 6f 10 	movl   $0x106fbc,0xc(%esp)
  104d25:	00 
  104d26:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104d2d:	00 
  104d2e:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104d35:	00 
  104d36:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104d3d:	e8 bd bf ff ff       	call   100cff <__panic>
    assert(*ptep & PTE_U);
  104d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d45:	8b 00                	mov    (%eax),%eax
  104d47:	83 e0 04             	and    $0x4,%eax
  104d4a:	85 c0                	test   %eax,%eax
  104d4c:	75 24                	jne    104d72 <check_pgdir+0x333>
  104d4e:	c7 44 24 0c ec 6f 10 	movl   $0x106fec,0xc(%esp)
  104d55:	00 
  104d56:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104d5d:	00 
  104d5e:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  104d65:	00 
  104d66:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104d6d:	e8 8d bf ff ff       	call   100cff <__panic>
    assert(*ptep & PTE_W);
  104d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d75:	8b 00                	mov    (%eax),%eax
  104d77:	83 e0 02             	and    $0x2,%eax
  104d7a:	85 c0                	test   %eax,%eax
  104d7c:	75 24                	jne    104da2 <check_pgdir+0x363>
  104d7e:	c7 44 24 0c fa 6f 10 	movl   $0x106ffa,0xc(%esp)
  104d85:	00 
  104d86:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104d8d:	00 
  104d8e:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  104d95:	00 
  104d96:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104d9d:	e8 5d bf ff ff       	call   100cff <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104da2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104da7:	8b 00                	mov    (%eax),%eax
  104da9:	83 e0 04             	and    $0x4,%eax
  104dac:	85 c0                	test   %eax,%eax
  104dae:	75 24                	jne    104dd4 <check_pgdir+0x395>
  104db0:	c7 44 24 0c 08 70 10 	movl   $0x107008,0xc(%esp)
  104db7:	00 
  104db8:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104dbf:	00 
  104dc0:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  104dc7:	00 
  104dc8:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104dcf:	e8 2b bf ff ff       	call   100cff <__panic>
    assert(page_ref(p2) == 1);
  104dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dd7:	89 04 24             	mov    %eax,(%esp)
  104dda:	e8 de ef ff ff       	call   103dbd <page_ref>
  104ddf:	83 f8 01             	cmp    $0x1,%eax
  104de2:	74 24                	je     104e08 <check_pgdir+0x3c9>
  104de4:	c7 44 24 0c 1e 70 10 	movl   $0x10701e,0xc(%esp)
  104deb:	00 
  104dec:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104df3:	00 
  104df4:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  104dfb:	00 
  104dfc:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104e03:	e8 f7 be ff ff       	call   100cff <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104e08:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104e0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104e14:	00 
  104e15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104e1c:	00 
  104e1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104e20:	89 54 24 04          	mov    %edx,0x4(%esp)
  104e24:	89 04 24             	mov    %eax,(%esp)
  104e27:	e8 d8 fa ff ff       	call   104904 <page_insert>
  104e2c:	85 c0                	test   %eax,%eax
  104e2e:	74 24                	je     104e54 <check_pgdir+0x415>
  104e30:	c7 44 24 0c 30 70 10 	movl   $0x107030,0xc(%esp)
  104e37:	00 
  104e38:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104e3f:	00 
  104e40:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  104e47:	00 
  104e48:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104e4f:	e8 ab be ff ff       	call   100cff <__panic>
    assert(page_ref(p1) == 2);
  104e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e57:	89 04 24             	mov    %eax,(%esp)
  104e5a:	e8 5e ef ff ff       	call   103dbd <page_ref>
  104e5f:	83 f8 02             	cmp    $0x2,%eax
  104e62:	74 24                	je     104e88 <check_pgdir+0x449>
  104e64:	c7 44 24 0c 5c 70 10 	movl   $0x10705c,0xc(%esp)
  104e6b:	00 
  104e6c:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104e73:	00 
  104e74:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  104e7b:	00 
  104e7c:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104e83:	e8 77 be ff ff       	call   100cff <__panic>
    assert(page_ref(p2) == 0);
  104e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e8b:	89 04 24             	mov    %eax,(%esp)
  104e8e:	e8 2a ef ff ff       	call   103dbd <page_ref>
  104e93:	85 c0                	test   %eax,%eax
  104e95:	74 24                	je     104ebb <check_pgdir+0x47c>
  104e97:	c7 44 24 0c 6e 70 10 	movl   $0x10706e,0xc(%esp)
  104e9e:	00 
  104e9f:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104ea6:	00 
  104ea7:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  104eae:	00 
  104eaf:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104eb6:	e8 44 be ff ff       	call   100cff <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104ebb:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ec0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ec7:	00 
  104ec8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104ecf:	00 
  104ed0:	89 04 24             	mov    %eax,(%esp)
  104ed3:	e8 87 f7 ff ff       	call   10465f <get_pte>
  104ed8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104edb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104edf:	75 24                	jne    104f05 <check_pgdir+0x4c6>
  104ee1:	c7 44 24 0c bc 6f 10 	movl   $0x106fbc,0xc(%esp)
  104ee8:	00 
  104ee9:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104ef0:	00 
  104ef1:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  104ef8:	00 
  104ef9:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104f00:	e8 fa bd ff ff       	call   100cff <__panic>
    assert(pte2page(*ptep) == p1);
  104f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f08:	8b 00                	mov    (%eax),%eax
  104f0a:	89 04 24             	mov    %eax,(%esp)
  104f0d:	e8 51 ee ff ff       	call   103d63 <pte2page>
  104f12:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104f15:	74 24                	je     104f3b <check_pgdir+0x4fc>
  104f17:	c7 44 24 0c 31 6f 10 	movl   $0x106f31,0xc(%esp)
  104f1e:	00 
  104f1f:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104f26:	00 
  104f27:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  104f2e:	00 
  104f2f:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104f36:	e8 c4 bd ff ff       	call   100cff <__panic>
    assert((*ptep & PTE_U) == 0);
  104f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f3e:	8b 00                	mov    (%eax),%eax
  104f40:	83 e0 04             	and    $0x4,%eax
  104f43:	85 c0                	test   %eax,%eax
  104f45:	74 24                	je     104f6b <check_pgdir+0x52c>
  104f47:	c7 44 24 0c 80 70 10 	movl   $0x107080,0xc(%esp)
  104f4e:	00 
  104f4f:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104f56:	00 
  104f57:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  104f5e:	00 
  104f5f:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104f66:	e8 94 bd ff ff       	call   100cff <__panic>

    page_remove(boot_pgdir, 0x0);
  104f6b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104f70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104f77:	00 
  104f78:	89 04 24             	mov    %eax,(%esp)
  104f7b:	e8 3d f9 ff ff       	call   1048bd <page_remove>
    assert(page_ref(p1) == 1);
  104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f83:	89 04 24             	mov    %eax,(%esp)
  104f86:	e8 32 ee ff ff       	call   103dbd <page_ref>
  104f8b:	83 f8 01             	cmp    $0x1,%eax
  104f8e:	74 24                	je     104fb4 <check_pgdir+0x575>
  104f90:	c7 44 24 0c 47 6f 10 	movl   $0x106f47,0xc(%esp)
  104f97:	00 
  104f98:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104f9f:	00 
  104fa0:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  104fa7:	00 
  104fa8:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104faf:	e8 4b bd ff ff       	call   100cff <__panic>
    assert(page_ref(p2) == 0);
  104fb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fb7:	89 04 24             	mov    %eax,(%esp)
  104fba:	e8 fe ed ff ff       	call   103dbd <page_ref>
  104fbf:	85 c0                	test   %eax,%eax
  104fc1:	74 24                	je     104fe7 <check_pgdir+0x5a8>
  104fc3:	c7 44 24 0c 6e 70 10 	movl   $0x10706e,0xc(%esp)
  104fca:	00 
  104fcb:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  104fd2:	00 
  104fd3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  104fda:	00 
  104fdb:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  104fe2:	e8 18 bd ff ff       	call   100cff <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104fe7:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104fec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104ff3:	00 
  104ff4:	89 04 24             	mov    %eax,(%esp)
  104ff7:	e8 c1 f8 ff ff       	call   1048bd <page_remove>
    assert(page_ref(p1) == 0);
  104ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104fff:	89 04 24             	mov    %eax,(%esp)
  105002:	e8 b6 ed ff ff       	call   103dbd <page_ref>
  105007:	85 c0                	test   %eax,%eax
  105009:	74 24                	je     10502f <check_pgdir+0x5f0>
  10500b:	c7 44 24 0c 95 70 10 	movl   $0x107095,0xc(%esp)
  105012:	00 
  105013:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10501a:	00 
  10501b:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  105022:	00 
  105023:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10502a:	e8 d0 bc ff ff       	call   100cff <__panic>
    assert(page_ref(p2) == 0);
  10502f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105032:	89 04 24             	mov    %eax,(%esp)
  105035:	e8 83 ed ff ff       	call   103dbd <page_ref>
  10503a:	85 c0                	test   %eax,%eax
  10503c:	74 24                	je     105062 <check_pgdir+0x623>
  10503e:	c7 44 24 0c 6e 70 10 	movl   $0x10706e,0xc(%esp)
  105045:	00 
  105046:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10504d:	00 
  10504e:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  105055:	00 
  105056:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10505d:	e8 9d bc ff ff       	call   100cff <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  105062:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105067:	8b 00                	mov    (%eax),%eax
  105069:	89 04 24             	mov    %eax,(%esp)
  10506c:	e8 32 ed ff ff       	call   103da3 <pde2page>
  105071:	89 04 24             	mov    %eax,(%esp)
  105074:	e8 44 ed ff ff       	call   103dbd <page_ref>
  105079:	83 f8 01             	cmp    $0x1,%eax
  10507c:	74 24                	je     1050a2 <check_pgdir+0x663>
  10507e:	c7 44 24 0c a8 70 10 	movl   $0x1070a8,0xc(%esp)
  105085:	00 
  105086:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10508d:	00 
  10508e:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  105095:	00 
  105096:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10509d:	e8 5d bc ff ff       	call   100cff <__panic>
    free_page(pde2page(boot_pgdir[0]));
  1050a2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050a7:	8b 00                	mov    (%eax),%eax
  1050a9:	89 04 24             	mov    %eax,(%esp)
  1050ac:	e8 f2 ec ff ff       	call   103da3 <pde2page>
  1050b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050b8:	00 
  1050b9:	89 04 24             	mov    %eax,(%esp)
  1050bc:	e8 46 ef ff ff       	call   104007 <free_pages>
    boot_pgdir[0] = 0;
  1050c1:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  1050cc:	c7 04 24 cf 70 10 00 	movl   $0x1070cf,(%esp)
  1050d3:	e8 7e b2 ff ff       	call   100356 <cprintf>
}
  1050d8:	90                   	nop
  1050d9:	89 ec                	mov    %ebp,%esp
  1050db:	5d                   	pop    %ebp
  1050dc:	c3                   	ret    

001050dd <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  1050dd:	55                   	push   %ebp
  1050de:	89 e5                	mov    %esp,%ebp
  1050e0:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  1050e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1050ea:	e9 ca 00 00 00       	jmp    1051b9 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  1050ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1050f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050f8:	c1 e8 0c             	shr    $0xc,%eax
  1050fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1050fe:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  105103:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105106:	72 23                	jb     10512b <check_boot_pgdir+0x4e>
  105108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10510b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10510f:	c7 44 24 08 04 6d 10 	movl   $0x106d04,0x8(%esp)
  105116:	00 
  105117:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
  10511e:	00 
  10511f:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  105126:	e8 d4 bb ff ff       	call   100cff <__panic>
  10512b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10512e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105133:	89 c2                	mov    %eax,%edx
  105135:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10513a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105141:	00 
  105142:	89 54 24 04          	mov    %edx,0x4(%esp)
  105146:	89 04 24             	mov    %eax,(%esp)
  105149:	e8 11 f5 ff ff       	call   10465f <get_pte>
  10514e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105151:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105155:	75 24                	jne    10517b <check_boot_pgdir+0x9e>
  105157:	c7 44 24 0c ec 70 10 	movl   $0x1070ec,0xc(%esp)
  10515e:	00 
  10515f:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  105166:	00 
  105167:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
  10516e:	00 
  10516f:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  105176:	e8 84 bb ff ff       	call   100cff <__panic>
        assert(PTE_ADDR(*ptep) == i);
  10517b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10517e:	8b 00                	mov    (%eax),%eax
  105180:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105185:	89 c2                	mov    %eax,%edx
  105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10518a:	39 c2                	cmp    %eax,%edx
  10518c:	74 24                	je     1051b2 <check_boot_pgdir+0xd5>
  10518e:	c7 44 24 0c 29 71 10 	movl   $0x107129,0xc(%esp)
  105195:	00 
  105196:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10519d:	00 
  10519e:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
  1051a5:	00 
  1051a6:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1051ad:	e8 4d bb ff ff       	call   100cff <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  1051b2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  1051b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1051bc:	a1 a4 ce 11 00       	mov    0x11cea4,%eax
  1051c1:	39 c2                	cmp    %eax,%edx
  1051c3:	0f 82 26 ff ff ff    	jb     1050ef <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  1051c9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1051ce:	05 ac 0f 00 00       	add    $0xfac,%eax
  1051d3:	8b 00                	mov    (%eax),%eax
  1051d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1051da:	89 c2                	mov    %eax,%edx
  1051dc:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1051e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1051e4:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1051eb:	77 23                	ja     105210 <check_boot_pgdir+0x133>
  1051ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1051f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1051f4:	c7 44 24 08 a8 6d 10 	movl   $0x106da8,0x8(%esp)
  1051fb:	00 
  1051fc:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
  105203:	00 
  105204:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10520b:	e8 ef ba ff ff       	call   100cff <__panic>
  105210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105213:	05 00 00 00 40       	add    $0x40000000,%eax
  105218:	39 d0                	cmp    %edx,%eax
  10521a:	74 24                	je     105240 <check_boot_pgdir+0x163>
  10521c:	c7 44 24 0c 40 71 10 	movl   $0x107140,0xc(%esp)
  105223:	00 
  105224:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10522b:	00 
  10522c:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
  105233:	00 
  105234:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10523b:	e8 bf ba ff ff       	call   100cff <__panic>

    assert(boot_pgdir[0] == 0);
  105240:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105245:	8b 00                	mov    (%eax),%eax
  105247:	85 c0                	test   %eax,%eax
  105249:	74 24                	je     10526f <check_boot_pgdir+0x192>
  10524b:	c7 44 24 0c 74 71 10 	movl   $0x107174,0xc(%esp)
  105252:	00 
  105253:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  10525a:	00 
  10525b:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
  105262:	00 
  105263:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  10526a:	e8 90 ba ff ff       	call   100cff <__panic>

    struct Page *p;
    p = alloc_page();
  10526f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105276:	e8 52 ed ff ff       	call   103fcd <alloc_pages>
  10527b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10527e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105283:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10528a:	00 
  10528b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105292:	00 
  105293:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105296:	89 54 24 04          	mov    %edx,0x4(%esp)
  10529a:	89 04 24             	mov    %eax,(%esp)
  10529d:	e8 62 f6 ff ff       	call   104904 <page_insert>
  1052a2:	85 c0                	test   %eax,%eax
  1052a4:	74 24                	je     1052ca <check_boot_pgdir+0x1ed>
  1052a6:	c7 44 24 0c 88 71 10 	movl   $0x107188,0xc(%esp)
  1052ad:	00 
  1052ae:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  1052b5:	00 
  1052b6:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
  1052bd:	00 
  1052be:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1052c5:	e8 35 ba ff ff       	call   100cff <__panic>
    assert(page_ref(p) == 1);
  1052ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052cd:	89 04 24             	mov    %eax,(%esp)
  1052d0:	e8 e8 ea ff ff       	call   103dbd <page_ref>
  1052d5:	83 f8 01             	cmp    $0x1,%eax
  1052d8:	74 24                	je     1052fe <check_boot_pgdir+0x221>
  1052da:	c7 44 24 0c b6 71 10 	movl   $0x1071b6,0xc(%esp)
  1052e1:	00 
  1052e2:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  1052e9:	00 
  1052ea:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
  1052f1:	00 
  1052f2:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1052f9:	e8 01 ba ff ff       	call   100cff <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1052fe:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105303:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10530a:	00 
  10530b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  105312:	00 
  105313:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105316:	89 54 24 04          	mov    %edx,0x4(%esp)
  10531a:	89 04 24             	mov    %eax,(%esp)
  10531d:	e8 e2 f5 ff ff       	call   104904 <page_insert>
  105322:	85 c0                	test   %eax,%eax
  105324:	74 24                	je     10534a <check_boot_pgdir+0x26d>
  105326:	c7 44 24 0c c8 71 10 	movl   $0x1071c8,0xc(%esp)
  10532d:	00 
  10532e:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  105335:	00 
  105336:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
  10533d:	00 
  10533e:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  105345:	e8 b5 b9 ff ff       	call   100cff <__panic>
    assert(page_ref(p) == 2);
  10534a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10534d:	89 04 24             	mov    %eax,(%esp)
  105350:	e8 68 ea ff ff       	call   103dbd <page_ref>
  105355:	83 f8 02             	cmp    $0x2,%eax
  105358:	74 24                	je     10537e <check_boot_pgdir+0x2a1>
  10535a:	c7 44 24 0c ff 71 10 	movl   $0x1071ff,0xc(%esp)
  105361:	00 
  105362:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  105369:	00 
  10536a:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
  105371:	00 
  105372:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  105379:	e8 81 b9 ff ff       	call   100cff <__panic>

    const char *str = "ucore: Hello world!!";
  10537e:	c7 45 e8 10 72 10 00 	movl   $0x107210,-0x18(%ebp)
    strcpy((void *)0x100, str);
  105385:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105388:	89 44 24 04          	mov    %eax,0x4(%esp)
  10538c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105393:	e8 fc 09 00 00       	call   105d94 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105398:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  10539f:	00 
  1053a0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1053a7:	e8 60 0a 00 00       	call   105e0c <strcmp>
  1053ac:	85 c0                	test   %eax,%eax
  1053ae:	74 24                	je     1053d4 <check_boot_pgdir+0x2f7>
  1053b0:	c7 44 24 0c 28 72 10 	movl   $0x107228,0xc(%esp)
  1053b7:	00 
  1053b8:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  1053bf:	00 
  1053c0:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
  1053c7:	00 
  1053c8:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  1053cf:	e8 2b b9 ff ff       	call   100cff <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1053d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053d7:	89 04 24             	mov    %eax,(%esp)
  1053da:	e8 2e e9 ff ff       	call   103d0d <page2kva>
  1053df:	05 00 01 00 00       	add    $0x100,%eax
  1053e4:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1053e7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1053ee:	e8 47 09 00 00       	call   105d3a <strlen>
  1053f3:	85 c0                	test   %eax,%eax
  1053f5:	74 24                	je     10541b <check_boot_pgdir+0x33e>
  1053f7:	c7 44 24 0c 60 72 10 	movl   $0x107260,0xc(%esp)
  1053fe:	00 
  1053ff:	c7 44 24 08 f1 6d 10 	movl   $0x106df1,0x8(%esp)
  105406:	00 
  105407:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
  10540e:	00 
  10540f:	c7 04 24 cc 6d 10 00 	movl   $0x106dcc,(%esp)
  105416:	e8 e4 b8 ff ff       	call   100cff <__panic>

    free_page(p);
  10541b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105422:	00 
  105423:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105426:	89 04 24             	mov    %eax,(%esp)
  105429:	e8 d9 eb ff ff       	call   104007 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10542e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105433:	8b 00                	mov    (%eax),%eax
  105435:	89 04 24             	mov    %eax,(%esp)
  105438:	e8 66 e9 ff ff       	call   103da3 <pde2page>
  10543d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105444:	00 
  105445:	89 04 24             	mov    %eax,(%esp)
  105448:	e8 ba eb ff ff       	call   104007 <free_pages>
    boot_pgdir[0] = 0;
  10544d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105452:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105458:	c7 04 24 84 72 10 00 	movl   $0x107284,(%esp)
  10545f:	e8 f2 ae ff ff       	call   100356 <cprintf>
}
  105464:	90                   	nop
  105465:	89 ec                	mov    %ebp,%esp
  105467:	5d                   	pop    %ebp
  105468:	c3                   	ret    

00105469 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105469:	55                   	push   %ebp
  10546a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10546c:	8b 45 08             	mov    0x8(%ebp),%eax
  10546f:	83 e0 04             	and    $0x4,%eax
  105472:	85 c0                	test   %eax,%eax
  105474:	74 04                	je     10547a <perm2str+0x11>
  105476:	b0 75                	mov    $0x75,%al
  105478:	eb 02                	jmp    10547c <perm2str+0x13>
  10547a:	b0 2d                	mov    $0x2d,%al
  10547c:	a2 28 cf 11 00       	mov    %al,0x11cf28
    str[1] = 'r';
  105481:	c6 05 29 cf 11 00 72 	movb   $0x72,0x11cf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105488:	8b 45 08             	mov    0x8(%ebp),%eax
  10548b:	83 e0 02             	and    $0x2,%eax
  10548e:	85 c0                	test   %eax,%eax
  105490:	74 04                	je     105496 <perm2str+0x2d>
  105492:	b0 77                	mov    $0x77,%al
  105494:	eb 02                	jmp    105498 <perm2str+0x2f>
  105496:	b0 2d                	mov    $0x2d,%al
  105498:	a2 2a cf 11 00       	mov    %al,0x11cf2a
    str[3] = '\0';
  10549d:	c6 05 2b cf 11 00 00 	movb   $0x0,0x11cf2b
    return str;
  1054a4:	b8 28 cf 11 00       	mov    $0x11cf28,%eax
}
  1054a9:	5d                   	pop    %ebp
  1054aa:	c3                   	ret    

001054ab <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1054ab:	55                   	push   %ebp
  1054ac:	89 e5                	mov    %esp,%ebp
  1054ae:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1054b1:	8b 45 10             	mov    0x10(%ebp),%eax
  1054b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054b7:	72 0d                	jb     1054c6 <get_pgtable_items+0x1b>
        return 0;
  1054b9:	b8 00 00 00 00       	mov    $0x0,%eax
  1054be:	e9 98 00 00 00       	jmp    10555b <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1054c3:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  1054c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1054c9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054cc:	73 18                	jae    1054e6 <get_pgtable_items+0x3b>
  1054ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1054d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1054d8:	8b 45 14             	mov    0x14(%ebp),%eax
  1054db:	01 d0                	add    %edx,%eax
  1054dd:	8b 00                	mov    (%eax),%eax
  1054df:	83 e0 01             	and    $0x1,%eax
  1054e2:	85 c0                	test   %eax,%eax
  1054e4:	74 dd                	je     1054c3 <get_pgtable_items+0x18>
    }
    if (start < right) {
  1054e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1054e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054ec:	73 68                	jae    105556 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1054ee:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1054f2:	74 08                	je     1054fc <get_pgtable_items+0x51>
            *left_store = start;
  1054f4:	8b 45 18             	mov    0x18(%ebp),%eax
  1054f7:	8b 55 10             	mov    0x10(%ebp),%edx
  1054fa:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1054fc:	8b 45 10             	mov    0x10(%ebp),%eax
  1054ff:	8d 50 01             	lea    0x1(%eax),%edx
  105502:	89 55 10             	mov    %edx,0x10(%ebp)
  105505:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10550c:	8b 45 14             	mov    0x14(%ebp),%eax
  10550f:	01 d0                	add    %edx,%eax
  105511:	8b 00                	mov    (%eax),%eax
  105513:	83 e0 07             	and    $0x7,%eax
  105516:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105519:	eb 03                	jmp    10551e <get_pgtable_items+0x73>
            start ++;
  10551b:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10551e:	8b 45 10             	mov    0x10(%ebp),%eax
  105521:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105524:	73 1d                	jae    105543 <get_pgtable_items+0x98>
  105526:	8b 45 10             	mov    0x10(%ebp),%eax
  105529:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105530:	8b 45 14             	mov    0x14(%ebp),%eax
  105533:	01 d0                	add    %edx,%eax
  105535:	8b 00                	mov    (%eax),%eax
  105537:	83 e0 07             	and    $0x7,%eax
  10553a:	89 c2                	mov    %eax,%edx
  10553c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10553f:	39 c2                	cmp    %eax,%edx
  105541:	74 d8                	je     10551b <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  105543:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105547:	74 08                	je     105551 <get_pgtable_items+0xa6>
            *right_store = start;
  105549:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10554c:	8b 55 10             	mov    0x10(%ebp),%edx
  10554f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105551:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105554:	eb 05                	jmp    10555b <get_pgtable_items+0xb0>
    }
    return 0;
  105556:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10555b:	89 ec                	mov    %ebp,%esp
  10555d:	5d                   	pop    %ebp
  10555e:	c3                   	ret    

0010555f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10555f:	55                   	push   %ebp
  105560:	89 e5                	mov    %esp,%ebp
  105562:	57                   	push   %edi
  105563:	56                   	push   %esi
  105564:	53                   	push   %ebx
  105565:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105568:	c7 04 24 a4 72 10 00 	movl   $0x1072a4,(%esp)
  10556f:	e8 e2 ad ff ff       	call   100356 <cprintf>
    size_t left, right = 0, perm;
  105574:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10557b:	e9 f2 00 00 00       	jmp    105672 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105583:	89 04 24             	mov    %eax,(%esp)
  105586:	e8 de fe ff ff       	call   105469 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  10558b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10558e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  105591:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105593:	89 d6                	mov    %edx,%esi
  105595:	c1 e6 16             	shl    $0x16,%esi
  105598:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10559b:	89 d3                	mov    %edx,%ebx
  10559d:	c1 e3 16             	shl    $0x16,%ebx
  1055a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1055a3:	89 d1                	mov    %edx,%ecx
  1055a5:	c1 e1 16             	shl    $0x16,%ecx
  1055a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1055ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  1055ae:	29 fa                	sub    %edi,%edx
  1055b0:	89 44 24 14          	mov    %eax,0x14(%esp)
  1055b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  1055b8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1055bc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1055c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1055c4:	c7 04 24 d5 72 10 00 	movl   $0x1072d5,(%esp)
  1055cb:	e8 86 ad ff ff       	call   100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
  1055d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055d3:	c1 e0 0a             	shl    $0xa,%eax
  1055d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1055d9:	eb 50                	jmp    10562b <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1055db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1055de:	89 04 24             	mov    %eax,(%esp)
  1055e1:	e8 83 fe ff ff       	call   105469 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1055e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1055e9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  1055ec:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1055ee:	89 d6                	mov    %edx,%esi
  1055f0:	c1 e6 0c             	shl    $0xc,%esi
  1055f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1055f6:	89 d3                	mov    %edx,%ebx
  1055f8:	c1 e3 0c             	shl    $0xc,%ebx
  1055fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1055fe:	89 d1                	mov    %edx,%ecx
  105600:	c1 e1 0c             	shl    $0xc,%ecx
  105603:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105606:	8b 7d d8             	mov    -0x28(%ebp),%edi
  105609:	29 fa                	sub    %edi,%edx
  10560b:	89 44 24 14          	mov    %eax,0x14(%esp)
  10560f:	89 74 24 10          	mov    %esi,0x10(%esp)
  105613:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105617:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10561b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10561f:	c7 04 24 f4 72 10 00 	movl   $0x1072f4,(%esp)
  105626:	e8 2b ad ff ff       	call   100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10562b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  105630:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105633:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105636:	89 d3                	mov    %edx,%ebx
  105638:	c1 e3 0a             	shl    $0xa,%ebx
  10563b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10563e:	89 d1                	mov    %edx,%ecx
  105640:	c1 e1 0a             	shl    $0xa,%ecx
  105643:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  105646:	89 54 24 14          	mov    %edx,0x14(%esp)
  10564a:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10564d:	89 54 24 10          	mov    %edx,0x10(%esp)
  105651:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105655:	89 44 24 08          	mov    %eax,0x8(%esp)
  105659:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10565d:	89 0c 24             	mov    %ecx,(%esp)
  105660:	e8 46 fe ff ff       	call   1054ab <get_pgtable_items>
  105665:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105668:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10566c:	0f 85 69 ff ff ff    	jne    1055db <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105672:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  105677:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10567a:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10567d:	89 54 24 14          	mov    %edx,0x14(%esp)
  105681:	8d 55 e0             	lea    -0x20(%ebp),%edx
  105684:	89 54 24 10          	mov    %edx,0x10(%esp)
  105688:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10568c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105690:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  105697:	00 
  105698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10569f:	e8 07 fe ff ff       	call   1054ab <get_pgtable_items>
  1056a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1056a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1056ab:	0f 85 cf fe ff ff    	jne    105580 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1056b1:	c7 04 24 18 73 10 00 	movl   $0x107318,(%esp)
  1056b8:	e8 99 ac ff ff       	call   100356 <cprintf>
}
  1056bd:	90                   	nop
  1056be:	83 c4 4c             	add    $0x4c,%esp
  1056c1:	5b                   	pop    %ebx
  1056c2:	5e                   	pop    %esi
  1056c3:	5f                   	pop    %edi
  1056c4:	5d                   	pop    %ebp
  1056c5:	c3                   	ret    

001056c6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1056c6:	55                   	push   %ebp
  1056c7:	89 e5                	mov    %esp,%ebp
  1056c9:	83 ec 58             	sub    $0x58,%esp
  1056cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1056cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1056d2:	8b 45 14             	mov    0x14(%ebp),%eax
  1056d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1056d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1056db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1056de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1056e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1056e4:	8b 45 18             	mov    0x18(%ebp),%eax
  1056e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1056ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1056f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1056f3:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1056f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105700:	74 1c                	je     10571e <printnum+0x58>
  105702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105705:	ba 00 00 00 00       	mov    $0x0,%edx
  10570a:	f7 75 e4             	divl   -0x1c(%ebp)
  10570d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105713:	ba 00 00 00 00       	mov    $0x0,%edx
  105718:	f7 75 e4             	divl   -0x1c(%ebp)
  10571b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10571e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105721:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105724:	f7 75 e4             	divl   -0x1c(%ebp)
  105727:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10572a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10572d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105730:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105733:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105736:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105739:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10573c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10573f:	8b 45 18             	mov    0x18(%ebp),%eax
  105742:	ba 00 00 00 00       	mov    $0x0,%edx
  105747:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10574a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10574d:	19 d1                	sbb    %edx,%ecx
  10574f:	72 4c                	jb     10579d <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  105751:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105754:	8d 50 ff             	lea    -0x1(%eax),%edx
  105757:	8b 45 20             	mov    0x20(%ebp),%eax
  10575a:	89 44 24 18          	mov    %eax,0x18(%esp)
  10575e:	89 54 24 14          	mov    %edx,0x14(%esp)
  105762:	8b 45 18             	mov    0x18(%ebp),%eax
  105765:	89 44 24 10          	mov    %eax,0x10(%esp)
  105769:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10576c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10576f:	89 44 24 08          	mov    %eax,0x8(%esp)
  105773:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105777:	8b 45 0c             	mov    0xc(%ebp),%eax
  10577a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10577e:	8b 45 08             	mov    0x8(%ebp),%eax
  105781:	89 04 24             	mov    %eax,(%esp)
  105784:	e8 3d ff ff ff       	call   1056c6 <printnum>
  105789:	eb 1b                	jmp    1057a6 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10578b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10578e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105792:	8b 45 20             	mov    0x20(%ebp),%eax
  105795:	89 04 24             	mov    %eax,(%esp)
  105798:	8b 45 08             	mov    0x8(%ebp),%eax
  10579b:	ff d0                	call   *%eax
        while (-- width > 0)
  10579d:	ff 4d 1c             	decl   0x1c(%ebp)
  1057a0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1057a4:	7f e5                	jg     10578b <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1057a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1057a9:	05 cc 73 10 00       	add    $0x1073cc,%eax
  1057ae:	0f b6 00             	movzbl (%eax),%eax
  1057b1:	0f be c0             	movsbl %al,%eax
  1057b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057bb:	89 04 24             	mov    %eax,(%esp)
  1057be:	8b 45 08             	mov    0x8(%ebp),%eax
  1057c1:	ff d0                	call   *%eax
}
  1057c3:	90                   	nop
  1057c4:	89 ec                	mov    %ebp,%esp
  1057c6:	5d                   	pop    %ebp
  1057c7:	c3                   	ret    

001057c8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1057c8:	55                   	push   %ebp
  1057c9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1057cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1057cf:	7e 14                	jle    1057e5 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1057d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d4:	8b 00                	mov    (%eax),%eax
  1057d6:	8d 48 08             	lea    0x8(%eax),%ecx
  1057d9:	8b 55 08             	mov    0x8(%ebp),%edx
  1057dc:	89 0a                	mov    %ecx,(%edx)
  1057de:	8b 50 04             	mov    0x4(%eax),%edx
  1057e1:	8b 00                	mov    (%eax),%eax
  1057e3:	eb 30                	jmp    105815 <getuint+0x4d>
    }
    else if (lflag) {
  1057e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1057e9:	74 16                	je     105801 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1057eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ee:	8b 00                	mov    (%eax),%eax
  1057f0:	8d 48 04             	lea    0x4(%eax),%ecx
  1057f3:	8b 55 08             	mov    0x8(%ebp),%edx
  1057f6:	89 0a                	mov    %ecx,(%edx)
  1057f8:	8b 00                	mov    (%eax),%eax
  1057fa:	ba 00 00 00 00       	mov    $0x0,%edx
  1057ff:	eb 14                	jmp    105815 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105801:	8b 45 08             	mov    0x8(%ebp),%eax
  105804:	8b 00                	mov    (%eax),%eax
  105806:	8d 48 04             	lea    0x4(%eax),%ecx
  105809:	8b 55 08             	mov    0x8(%ebp),%edx
  10580c:	89 0a                	mov    %ecx,(%edx)
  10580e:	8b 00                	mov    (%eax),%eax
  105810:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105815:	5d                   	pop    %ebp
  105816:	c3                   	ret    

00105817 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105817:	55                   	push   %ebp
  105818:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10581a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10581e:	7e 14                	jle    105834 <getint+0x1d>
        return va_arg(*ap, long long);
  105820:	8b 45 08             	mov    0x8(%ebp),%eax
  105823:	8b 00                	mov    (%eax),%eax
  105825:	8d 48 08             	lea    0x8(%eax),%ecx
  105828:	8b 55 08             	mov    0x8(%ebp),%edx
  10582b:	89 0a                	mov    %ecx,(%edx)
  10582d:	8b 50 04             	mov    0x4(%eax),%edx
  105830:	8b 00                	mov    (%eax),%eax
  105832:	eb 28                	jmp    10585c <getint+0x45>
    }
    else if (lflag) {
  105834:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105838:	74 12                	je     10584c <getint+0x35>
        return va_arg(*ap, long);
  10583a:	8b 45 08             	mov    0x8(%ebp),%eax
  10583d:	8b 00                	mov    (%eax),%eax
  10583f:	8d 48 04             	lea    0x4(%eax),%ecx
  105842:	8b 55 08             	mov    0x8(%ebp),%edx
  105845:	89 0a                	mov    %ecx,(%edx)
  105847:	8b 00                	mov    (%eax),%eax
  105849:	99                   	cltd   
  10584a:	eb 10                	jmp    10585c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10584c:	8b 45 08             	mov    0x8(%ebp),%eax
  10584f:	8b 00                	mov    (%eax),%eax
  105851:	8d 48 04             	lea    0x4(%eax),%ecx
  105854:	8b 55 08             	mov    0x8(%ebp),%edx
  105857:	89 0a                	mov    %ecx,(%edx)
  105859:	8b 00                	mov    (%eax),%eax
  10585b:	99                   	cltd   
    }
}
  10585c:	5d                   	pop    %ebp
  10585d:	c3                   	ret    

0010585e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10585e:	55                   	push   %ebp
  10585f:	89 e5                	mov    %esp,%ebp
  105861:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105864:	8d 45 14             	lea    0x14(%ebp),%eax
  105867:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10586a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10586d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105871:	8b 45 10             	mov    0x10(%ebp),%eax
  105874:	89 44 24 08          	mov    %eax,0x8(%esp)
  105878:	8b 45 0c             	mov    0xc(%ebp),%eax
  10587b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10587f:	8b 45 08             	mov    0x8(%ebp),%eax
  105882:	89 04 24             	mov    %eax,(%esp)
  105885:	e8 05 00 00 00       	call   10588f <vprintfmt>
    va_end(ap);
}
  10588a:	90                   	nop
  10588b:	89 ec                	mov    %ebp,%esp
  10588d:	5d                   	pop    %ebp
  10588e:	c3                   	ret    

0010588f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10588f:	55                   	push   %ebp
  105890:	89 e5                	mov    %esp,%ebp
  105892:	56                   	push   %esi
  105893:	53                   	push   %ebx
  105894:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105897:	eb 17                	jmp    1058b0 <vprintfmt+0x21>
            if (ch == '\0') {
  105899:	85 db                	test   %ebx,%ebx
  10589b:	0f 84 bf 03 00 00    	je     105c60 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1058a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058a8:	89 1c 24             	mov    %ebx,(%esp)
  1058ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1058ae:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1058b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1058b3:	8d 50 01             	lea    0x1(%eax),%edx
  1058b6:	89 55 10             	mov    %edx,0x10(%ebp)
  1058b9:	0f b6 00             	movzbl (%eax),%eax
  1058bc:	0f b6 d8             	movzbl %al,%ebx
  1058bf:	83 fb 25             	cmp    $0x25,%ebx
  1058c2:	75 d5                	jne    105899 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1058c4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1058c8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1058cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1058d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1058d5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1058dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1058df:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1058e2:	8b 45 10             	mov    0x10(%ebp),%eax
  1058e5:	8d 50 01             	lea    0x1(%eax),%edx
  1058e8:	89 55 10             	mov    %edx,0x10(%ebp)
  1058eb:	0f b6 00             	movzbl (%eax),%eax
  1058ee:	0f b6 d8             	movzbl %al,%ebx
  1058f1:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1058f4:	83 f8 55             	cmp    $0x55,%eax
  1058f7:	0f 87 37 03 00 00    	ja     105c34 <vprintfmt+0x3a5>
  1058fd:	8b 04 85 f0 73 10 00 	mov    0x1073f0(,%eax,4),%eax
  105904:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105906:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10590a:	eb d6                	jmp    1058e2 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10590c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105910:	eb d0                	jmp    1058e2 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105912:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105919:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10591c:	89 d0                	mov    %edx,%eax
  10591e:	c1 e0 02             	shl    $0x2,%eax
  105921:	01 d0                	add    %edx,%eax
  105923:	01 c0                	add    %eax,%eax
  105925:	01 d8                	add    %ebx,%eax
  105927:	83 e8 30             	sub    $0x30,%eax
  10592a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10592d:	8b 45 10             	mov    0x10(%ebp),%eax
  105930:	0f b6 00             	movzbl (%eax),%eax
  105933:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105936:	83 fb 2f             	cmp    $0x2f,%ebx
  105939:	7e 38                	jle    105973 <vprintfmt+0xe4>
  10593b:	83 fb 39             	cmp    $0x39,%ebx
  10593e:	7f 33                	jg     105973 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105940:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105943:	eb d4                	jmp    105919 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105945:	8b 45 14             	mov    0x14(%ebp),%eax
  105948:	8d 50 04             	lea    0x4(%eax),%edx
  10594b:	89 55 14             	mov    %edx,0x14(%ebp)
  10594e:	8b 00                	mov    (%eax),%eax
  105950:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105953:	eb 1f                	jmp    105974 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105955:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105959:	79 87                	jns    1058e2 <vprintfmt+0x53>
                width = 0;
  10595b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105962:	e9 7b ff ff ff       	jmp    1058e2 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105967:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10596e:	e9 6f ff ff ff       	jmp    1058e2 <vprintfmt+0x53>
            goto process_precision;
  105973:	90                   	nop

        process_precision:
            if (width < 0)
  105974:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105978:	0f 89 64 ff ff ff    	jns    1058e2 <vprintfmt+0x53>
                width = precision, precision = -1;
  10597e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105981:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105984:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10598b:	e9 52 ff ff ff       	jmp    1058e2 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105990:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105993:	e9 4a ff ff ff       	jmp    1058e2 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105998:	8b 45 14             	mov    0x14(%ebp),%eax
  10599b:	8d 50 04             	lea    0x4(%eax),%edx
  10599e:	89 55 14             	mov    %edx,0x14(%ebp)
  1059a1:	8b 00                	mov    (%eax),%eax
  1059a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1059a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1059aa:	89 04 24             	mov    %eax,(%esp)
  1059ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b0:	ff d0                	call   *%eax
            break;
  1059b2:	e9 a4 02 00 00       	jmp    105c5b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1059b7:	8b 45 14             	mov    0x14(%ebp),%eax
  1059ba:	8d 50 04             	lea    0x4(%eax),%edx
  1059bd:	89 55 14             	mov    %edx,0x14(%ebp)
  1059c0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1059c2:	85 db                	test   %ebx,%ebx
  1059c4:	79 02                	jns    1059c8 <vprintfmt+0x139>
                err = -err;
  1059c6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1059c8:	83 fb 06             	cmp    $0x6,%ebx
  1059cb:	7f 0b                	jg     1059d8 <vprintfmt+0x149>
  1059cd:	8b 34 9d b0 73 10 00 	mov    0x1073b0(,%ebx,4),%esi
  1059d4:	85 f6                	test   %esi,%esi
  1059d6:	75 23                	jne    1059fb <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  1059d8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1059dc:	c7 44 24 08 dd 73 10 	movl   $0x1073dd,0x8(%esp)
  1059e3:	00 
  1059e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1059ee:	89 04 24             	mov    %eax,(%esp)
  1059f1:	e8 68 fe ff ff       	call   10585e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1059f6:	e9 60 02 00 00       	jmp    105c5b <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  1059fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1059ff:	c7 44 24 08 e6 73 10 	movl   $0x1073e6,0x8(%esp)
  105a06:	00 
  105a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  105a11:	89 04 24             	mov    %eax,(%esp)
  105a14:	e8 45 fe ff ff       	call   10585e <printfmt>
            break;
  105a19:	e9 3d 02 00 00       	jmp    105c5b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105a1e:	8b 45 14             	mov    0x14(%ebp),%eax
  105a21:	8d 50 04             	lea    0x4(%eax),%edx
  105a24:	89 55 14             	mov    %edx,0x14(%ebp)
  105a27:	8b 30                	mov    (%eax),%esi
  105a29:	85 f6                	test   %esi,%esi
  105a2b:	75 05                	jne    105a32 <vprintfmt+0x1a3>
                p = "(null)";
  105a2d:	be e9 73 10 00       	mov    $0x1073e9,%esi
            }
            if (width > 0 && padc != '-') {
  105a32:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a36:	7e 76                	jle    105aae <vprintfmt+0x21f>
  105a38:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105a3c:	74 70                	je     105aae <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105a3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a41:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a45:	89 34 24             	mov    %esi,(%esp)
  105a48:	e8 16 03 00 00       	call   105d63 <strnlen>
  105a4d:	89 c2                	mov    %eax,%edx
  105a4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a52:	29 d0                	sub    %edx,%eax
  105a54:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a57:	eb 16                	jmp    105a6f <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105a59:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a60:	89 54 24 04          	mov    %edx,0x4(%esp)
  105a64:	89 04 24             	mov    %eax,(%esp)
  105a67:	8b 45 08             	mov    0x8(%ebp),%eax
  105a6a:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105a6c:	ff 4d e8             	decl   -0x18(%ebp)
  105a6f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a73:	7f e4                	jg     105a59 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105a75:	eb 37                	jmp    105aae <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105a77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105a7b:	74 1f                	je     105a9c <vprintfmt+0x20d>
  105a7d:	83 fb 1f             	cmp    $0x1f,%ebx
  105a80:	7e 05                	jle    105a87 <vprintfmt+0x1f8>
  105a82:	83 fb 7e             	cmp    $0x7e,%ebx
  105a85:	7e 15                	jle    105a9c <vprintfmt+0x20d>
                    putch('?', putdat);
  105a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a8e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105a95:	8b 45 08             	mov    0x8(%ebp),%eax
  105a98:	ff d0                	call   *%eax
  105a9a:	eb 0f                	jmp    105aab <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa3:	89 1c 24             	mov    %ebx,(%esp)
  105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105aab:	ff 4d e8             	decl   -0x18(%ebp)
  105aae:	89 f0                	mov    %esi,%eax
  105ab0:	8d 70 01             	lea    0x1(%eax),%esi
  105ab3:	0f b6 00             	movzbl (%eax),%eax
  105ab6:	0f be d8             	movsbl %al,%ebx
  105ab9:	85 db                	test   %ebx,%ebx
  105abb:	74 27                	je     105ae4 <vprintfmt+0x255>
  105abd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105ac1:	78 b4                	js     105a77 <vprintfmt+0x1e8>
  105ac3:	ff 4d e4             	decl   -0x1c(%ebp)
  105ac6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105aca:	79 ab                	jns    105a77 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105acc:	eb 16                	jmp    105ae4 <vprintfmt+0x255>
                putch(' ', putdat);
  105ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ad5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105adc:	8b 45 08             	mov    0x8(%ebp),%eax
  105adf:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105ae1:	ff 4d e8             	decl   -0x18(%ebp)
  105ae4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ae8:	7f e4                	jg     105ace <vprintfmt+0x23f>
            }
            break;
  105aea:	e9 6c 01 00 00       	jmp    105c5b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105aef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  105af6:	8d 45 14             	lea    0x14(%ebp),%eax
  105af9:	89 04 24             	mov    %eax,(%esp)
  105afc:	e8 16 fd ff ff       	call   105817 <getint>
  105b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b04:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b0d:	85 d2                	test   %edx,%edx
  105b0f:	79 26                	jns    105b37 <vprintfmt+0x2a8>
                putch('-', putdat);
  105b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b14:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b18:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b22:	ff d0                	call   *%eax
                num = -(long long)num;
  105b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b2a:	f7 d8                	neg    %eax
  105b2c:	83 d2 00             	adc    $0x0,%edx
  105b2f:	f7 da                	neg    %edx
  105b31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b34:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105b37:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105b3e:	e9 a8 00 00 00       	jmp    105beb <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105b43:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b4a:	8d 45 14             	lea    0x14(%ebp),%eax
  105b4d:	89 04 24             	mov    %eax,(%esp)
  105b50:	e8 73 fc ff ff       	call   1057c8 <getuint>
  105b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b58:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105b5b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105b62:	e9 84 00 00 00       	jmp    105beb <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b6e:	8d 45 14             	lea    0x14(%ebp),%eax
  105b71:	89 04 24             	mov    %eax,(%esp)
  105b74:	e8 4f fc ff ff       	call   1057c8 <getuint>
  105b79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105b7f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105b86:	eb 63                	jmp    105beb <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b8f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105b96:	8b 45 08             	mov    0x8(%ebp),%eax
  105b99:	ff d0                	call   *%eax
            putch('x', putdat);
  105b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ba2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bac:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105bae:	8b 45 14             	mov    0x14(%ebp),%eax
  105bb1:	8d 50 04             	lea    0x4(%eax),%edx
  105bb4:	89 55 14             	mov    %edx,0x14(%ebp)
  105bb7:	8b 00                	mov    (%eax),%eax
  105bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105bc3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105bca:	eb 1f                	jmp    105beb <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105bcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd3:	8d 45 14             	lea    0x14(%ebp),%eax
  105bd6:	89 04 24             	mov    %eax,(%esp)
  105bd9:	e8 ea fb ff ff       	call   1057c8 <getuint>
  105bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105be1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105be4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105beb:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105bf2:	89 54 24 18          	mov    %edx,0x18(%esp)
  105bf6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105bf9:	89 54 24 14          	mov    %edx,0x14(%esp)
  105bfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  105c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c16:	8b 45 08             	mov    0x8(%ebp),%eax
  105c19:	89 04 24             	mov    %eax,(%esp)
  105c1c:	e8 a5 fa ff ff       	call   1056c6 <printnum>
            break;
  105c21:	eb 38                	jmp    105c5b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c2a:	89 1c 24             	mov    %ebx,(%esp)
  105c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c30:	ff d0                	call   *%eax
            break;
  105c32:	eb 27                	jmp    105c5b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c3b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105c42:	8b 45 08             	mov    0x8(%ebp),%eax
  105c45:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105c47:	ff 4d 10             	decl   0x10(%ebp)
  105c4a:	eb 03                	jmp    105c4f <vprintfmt+0x3c0>
  105c4c:	ff 4d 10             	decl   0x10(%ebp)
  105c4f:	8b 45 10             	mov    0x10(%ebp),%eax
  105c52:	48                   	dec    %eax
  105c53:	0f b6 00             	movzbl (%eax),%eax
  105c56:	3c 25                	cmp    $0x25,%al
  105c58:	75 f2                	jne    105c4c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105c5a:	90                   	nop
    while (1) {
  105c5b:	e9 37 fc ff ff       	jmp    105897 <vprintfmt+0x8>
                return;
  105c60:	90                   	nop
        }
    }
}
  105c61:	83 c4 40             	add    $0x40,%esp
  105c64:	5b                   	pop    %ebx
  105c65:	5e                   	pop    %esi
  105c66:	5d                   	pop    %ebp
  105c67:	c3                   	ret    

00105c68 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105c68:	55                   	push   %ebp
  105c69:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c6e:	8b 40 08             	mov    0x8(%eax),%eax
  105c71:	8d 50 01             	lea    0x1(%eax),%edx
  105c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c77:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7d:	8b 10                	mov    (%eax),%edx
  105c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c82:	8b 40 04             	mov    0x4(%eax),%eax
  105c85:	39 c2                	cmp    %eax,%edx
  105c87:	73 12                	jae    105c9b <sprintputch+0x33>
        *b->buf ++ = ch;
  105c89:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c8c:	8b 00                	mov    (%eax),%eax
  105c8e:	8d 48 01             	lea    0x1(%eax),%ecx
  105c91:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c94:	89 0a                	mov    %ecx,(%edx)
  105c96:	8b 55 08             	mov    0x8(%ebp),%edx
  105c99:	88 10                	mov    %dl,(%eax)
    }
}
  105c9b:	90                   	nop
  105c9c:	5d                   	pop    %ebp
  105c9d:	c3                   	ret    

00105c9e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105c9e:	55                   	push   %ebp
  105c9f:	89 e5                	mov    %esp,%ebp
  105ca1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105ca4:	8d 45 14             	lea    0x14(%ebp),%eax
  105ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  105cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  105cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc2:	89 04 24             	mov    %eax,(%esp)
  105cc5:	e8 0a 00 00 00       	call   105cd4 <vsnprintf>
  105cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105cd0:	89 ec                	mov    %ebp,%esp
  105cd2:	5d                   	pop    %ebp
  105cd3:	c3                   	ret    

00105cd4 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105cd4:	55                   	push   %ebp
  105cd5:	89 e5                	mov    %esp,%ebp
  105cd7:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105cda:	8b 45 08             	mov    0x8(%ebp),%eax
  105cdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ce3:	8d 50 ff             	lea    -0x1(%eax),%edx
  105ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce9:	01 d0                	add    %edx,%eax
  105ceb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105cf5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105cf9:	74 0a                	je     105d05 <vsnprintf+0x31>
  105cfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d01:	39 c2                	cmp    %eax,%edx
  105d03:	76 07                	jbe    105d0c <vsnprintf+0x38>
        return -E_INVAL;
  105d05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105d0a:	eb 2a                	jmp    105d36 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105d0c:	8b 45 14             	mov    0x14(%ebp),%eax
  105d0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105d13:	8b 45 10             	mov    0x10(%ebp),%eax
  105d16:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d21:	c7 04 24 68 5c 10 00 	movl   $0x105c68,(%esp)
  105d28:	e8 62 fb ff ff       	call   10588f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d30:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105d36:	89 ec                	mov    %ebp,%esp
  105d38:	5d                   	pop    %ebp
  105d39:	c3                   	ret    

00105d3a <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105d3a:	55                   	push   %ebp
  105d3b:	89 e5                	mov    %esp,%ebp
  105d3d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105d40:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105d47:	eb 03                	jmp    105d4c <strlen+0x12>
        cnt ++;
  105d49:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4f:	8d 50 01             	lea    0x1(%eax),%edx
  105d52:	89 55 08             	mov    %edx,0x8(%ebp)
  105d55:	0f b6 00             	movzbl (%eax),%eax
  105d58:	84 c0                	test   %al,%al
  105d5a:	75 ed                	jne    105d49 <strlen+0xf>
    }
    return cnt;
  105d5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105d5f:	89 ec                	mov    %ebp,%esp
  105d61:	5d                   	pop    %ebp
  105d62:	c3                   	ret    

00105d63 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105d63:	55                   	push   %ebp
  105d64:	89 e5                	mov    %esp,%ebp
  105d66:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105d69:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105d70:	eb 03                	jmp    105d75 <strnlen+0x12>
        cnt ++;
  105d72:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105d75:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d78:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105d7b:	73 10                	jae    105d8d <strnlen+0x2a>
  105d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d80:	8d 50 01             	lea    0x1(%eax),%edx
  105d83:	89 55 08             	mov    %edx,0x8(%ebp)
  105d86:	0f b6 00             	movzbl (%eax),%eax
  105d89:	84 c0                	test   %al,%al
  105d8b:	75 e5                	jne    105d72 <strnlen+0xf>
    }
    return cnt;
  105d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105d90:	89 ec                	mov    %ebp,%esp
  105d92:	5d                   	pop    %ebp
  105d93:	c3                   	ret    

00105d94 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105d94:	55                   	push   %ebp
  105d95:	89 e5                	mov    %esp,%ebp
  105d97:	57                   	push   %edi
  105d98:	56                   	push   %esi
  105d99:	83 ec 20             	sub    $0x20,%esp
  105d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105da8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dae:	89 d1                	mov    %edx,%ecx
  105db0:	89 c2                	mov    %eax,%edx
  105db2:	89 ce                	mov    %ecx,%esi
  105db4:	89 d7                	mov    %edx,%edi
  105db6:	ac                   	lods   %ds:(%esi),%al
  105db7:	aa                   	stos   %al,%es:(%edi)
  105db8:	84 c0                	test   %al,%al
  105dba:	75 fa                	jne    105db6 <strcpy+0x22>
  105dbc:	89 fa                	mov    %edi,%edx
  105dbe:	89 f1                	mov    %esi,%ecx
  105dc0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105dc3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105dc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105dcc:	83 c4 20             	add    $0x20,%esp
  105dcf:	5e                   	pop    %esi
  105dd0:	5f                   	pop    %edi
  105dd1:	5d                   	pop    %ebp
  105dd2:	c3                   	ret    

00105dd3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105dd3:	55                   	push   %ebp
  105dd4:	89 e5                	mov    %esp,%ebp
  105dd6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ddc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105ddf:	eb 1e                	jmp    105dff <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105de4:	0f b6 10             	movzbl (%eax),%edx
  105de7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105dea:	88 10                	mov    %dl,(%eax)
  105dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105def:	0f b6 00             	movzbl (%eax),%eax
  105df2:	84 c0                	test   %al,%al
  105df4:	74 03                	je     105df9 <strncpy+0x26>
            src ++;
  105df6:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105df9:	ff 45 fc             	incl   -0x4(%ebp)
  105dfc:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  105dff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e03:	75 dc                	jne    105de1 <strncpy+0xe>
    }
    return dst;
  105e05:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105e08:	89 ec                	mov    %ebp,%esp
  105e0a:	5d                   	pop    %ebp
  105e0b:	c3                   	ret    

00105e0c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105e0c:	55                   	push   %ebp
  105e0d:	89 e5                	mov    %esp,%ebp
  105e0f:	57                   	push   %edi
  105e10:	56                   	push   %esi
  105e11:	83 ec 20             	sub    $0x20,%esp
  105e14:	8b 45 08             	mov    0x8(%ebp),%eax
  105e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e26:	89 d1                	mov    %edx,%ecx
  105e28:	89 c2                	mov    %eax,%edx
  105e2a:	89 ce                	mov    %ecx,%esi
  105e2c:	89 d7                	mov    %edx,%edi
  105e2e:	ac                   	lods   %ds:(%esi),%al
  105e2f:	ae                   	scas   %es:(%edi),%al
  105e30:	75 08                	jne    105e3a <strcmp+0x2e>
  105e32:	84 c0                	test   %al,%al
  105e34:	75 f8                	jne    105e2e <strcmp+0x22>
  105e36:	31 c0                	xor    %eax,%eax
  105e38:	eb 04                	jmp    105e3e <strcmp+0x32>
  105e3a:	19 c0                	sbb    %eax,%eax
  105e3c:	0c 01                	or     $0x1,%al
  105e3e:	89 fa                	mov    %edi,%edx
  105e40:	89 f1                	mov    %esi,%ecx
  105e42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e45:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105e48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105e4e:	83 c4 20             	add    $0x20,%esp
  105e51:	5e                   	pop    %esi
  105e52:	5f                   	pop    %edi
  105e53:	5d                   	pop    %ebp
  105e54:	c3                   	ret    

00105e55 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105e55:	55                   	push   %ebp
  105e56:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105e58:	eb 09                	jmp    105e63 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105e5a:	ff 4d 10             	decl   0x10(%ebp)
  105e5d:	ff 45 08             	incl   0x8(%ebp)
  105e60:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105e63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e67:	74 1a                	je     105e83 <strncmp+0x2e>
  105e69:	8b 45 08             	mov    0x8(%ebp),%eax
  105e6c:	0f b6 00             	movzbl (%eax),%eax
  105e6f:	84 c0                	test   %al,%al
  105e71:	74 10                	je     105e83 <strncmp+0x2e>
  105e73:	8b 45 08             	mov    0x8(%ebp),%eax
  105e76:	0f b6 10             	movzbl (%eax),%edx
  105e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e7c:	0f b6 00             	movzbl (%eax),%eax
  105e7f:	38 c2                	cmp    %al,%dl
  105e81:	74 d7                	je     105e5a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e87:	74 18                	je     105ea1 <strncmp+0x4c>
  105e89:	8b 45 08             	mov    0x8(%ebp),%eax
  105e8c:	0f b6 00             	movzbl (%eax),%eax
  105e8f:	0f b6 d0             	movzbl %al,%edx
  105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e95:	0f b6 00             	movzbl (%eax),%eax
  105e98:	0f b6 c8             	movzbl %al,%ecx
  105e9b:	89 d0                	mov    %edx,%eax
  105e9d:	29 c8                	sub    %ecx,%eax
  105e9f:	eb 05                	jmp    105ea6 <strncmp+0x51>
  105ea1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105ea6:	5d                   	pop    %ebp
  105ea7:	c3                   	ret    

00105ea8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105ea8:	55                   	push   %ebp
  105ea9:	89 e5                	mov    %esp,%ebp
  105eab:	83 ec 04             	sub    $0x4,%esp
  105eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eb1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105eb4:	eb 13                	jmp    105ec9 <strchr+0x21>
        if (*s == c) {
  105eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  105eb9:	0f b6 00             	movzbl (%eax),%eax
  105ebc:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105ebf:	75 05                	jne    105ec6 <strchr+0x1e>
            return (char *)s;
  105ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec4:	eb 12                	jmp    105ed8 <strchr+0x30>
        }
        s ++;
  105ec6:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ecc:	0f b6 00             	movzbl (%eax),%eax
  105ecf:	84 c0                	test   %al,%al
  105ed1:	75 e3                	jne    105eb6 <strchr+0xe>
    }
    return NULL;
  105ed3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105ed8:	89 ec                	mov    %ebp,%esp
  105eda:	5d                   	pop    %ebp
  105edb:	c3                   	ret    

00105edc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105edc:	55                   	push   %ebp
  105edd:	89 e5                	mov    %esp,%ebp
  105edf:	83 ec 04             	sub    $0x4,%esp
  105ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ee5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ee8:	eb 0e                	jmp    105ef8 <strfind+0x1c>
        if (*s == c) {
  105eea:	8b 45 08             	mov    0x8(%ebp),%eax
  105eed:	0f b6 00             	movzbl (%eax),%eax
  105ef0:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105ef3:	74 0f                	je     105f04 <strfind+0x28>
            break;
        }
        s ++;
  105ef5:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  105efb:	0f b6 00             	movzbl (%eax),%eax
  105efe:	84 c0                	test   %al,%al
  105f00:	75 e8                	jne    105eea <strfind+0xe>
  105f02:	eb 01                	jmp    105f05 <strfind+0x29>
            break;
  105f04:	90                   	nop
    }
    return (char *)s;
  105f05:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105f08:	89 ec                	mov    %ebp,%esp
  105f0a:	5d                   	pop    %ebp
  105f0b:	c3                   	ret    

00105f0c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105f0c:	55                   	push   %ebp
  105f0d:	89 e5                	mov    %esp,%ebp
  105f0f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105f12:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105f19:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105f20:	eb 03                	jmp    105f25 <strtol+0x19>
        s ++;
  105f22:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105f25:	8b 45 08             	mov    0x8(%ebp),%eax
  105f28:	0f b6 00             	movzbl (%eax),%eax
  105f2b:	3c 20                	cmp    $0x20,%al
  105f2d:	74 f3                	je     105f22 <strtol+0x16>
  105f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  105f32:	0f b6 00             	movzbl (%eax),%eax
  105f35:	3c 09                	cmp    $0x9,%al
  105f37:	74 e9                	je     105f22 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105f39:	8b 45 08             	mov    0x8(%ebp),%eax
  105f3c:	0f b6 00             	movzbl (%eax),%eax
  105f3f:	3c 2b                	cmp    $0x2b,%al
  105f41:	75 05                	jne    105f48 <strtol+0x3c>
        s ++;
  105f43:	ff 45 08             	incl   0x8(%ebp)
  105f46:	eb 14                	jmp    105f5c <strtol+0x50>
    }
    else if (*s == '-') {
  105f48:	8b 45 08             	mov    0x8(%ebp),%eax
  105f4b:	0f b6 00             	movzbl (%eax),%eax
  105f4e:	3c 2d                	cmp    $0x2d,%al
  105f50:	75 0a                	jne    105f5c <strtol+0x50>
        s ++, neg = 1;
  105f52:	ff 45 08             	incl   0x8(%ebp)
  105f55:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105f5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105f60:	74 06                	je     105f68 <strtol+0x5c>
  105f62:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105f66:	75 22                	jne    105f8a <strtol+0x7e>
  105f68:	8b 45 08             	mov    0x8(%ebp),%eax
  105f6b:	0f b6 00             	movzbl (%eax),%eax
  105f6e:	3c 30                	cmp    $0x30,%al
  105f70:	75 18                	jne    105f8a <strtol+0x7e>
  105f72:	8b 45 08             	mov    0x8(%ebp),%eax
  105f75:	40                   	inc    %eax
  105f76:	0f b6 00             	movzbl (%eax),%eax
  105f79:	3c 78                	cmp    $0x78,%al
  105f7b:	75 0d                	jne    105f8a <strtol+0x7e>
        s += 2, base = 16;
  105f7d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105f81:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105f88:	eb 29                	jmp    105fb3 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105f8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105f8e:	75 16                	jne    105fa6 <strtol+0x9a>
  105f90:	8b 45 08             	mov    0x8(%ebp),%eax
  105f93:	0f b6 00             	movzbl (%eax),%eax
  105f96:	3c 30                	cmp    $0x30,%al
  105f98:	75 0c                	jne    105fa6 <strtol+0x9a>
        s ++, base = 8;
  105f9a:	ff 45 08             	incl   0x8(%ebp)
  105f9d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105fa4:	eb 0d                	jmp    105fb3 <strtol+0xa7>
    }
    else if (base == 0) {
  105fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105faa:	75 07                	jne    105fb3 <strtol+0xa7>
        base = 10;
  105fac:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  105fb6:	0f b6 00             	movzbl (%eax),%eax
  105fb9:	3c 2f                	cmp    $0x2f,%al
  105fbb:	7e 1b                	jle    105fd8 <strtol+0xcc>
  105fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  105fc0:	0f b6 00             	movzbl (%eax),%eax
  105fc3:	3c 39                	cmp    $0x39,%al
  105fc5:	7f 11                	jg     105fd8 <strtol+0xcc>
            dig = *s - '0';
  105fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  105fca:	0f b6 00             	movzbl (%eax),%eax
  105fcd:	0f be c0             	movsbl %al,%eax
  105fd0:	83 e8 30             	sub    $0x30,%eax
  105fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105fd6:	eb 48                	jmp    106020 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  105fdb:	0f b6 00             	movzbl (%eax),%eax
  105fde:	3c 60                	cmp    $0x60,%al
  105fe0:	7e 1b                	jle    105ffd <strtol+0xf1>
  105fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  105fe5:	0f b6 00             	movzbl (%eax),%eax
  105fe8:	3c 7a                	cmp    $0x7a,%al
  105fea:	7f 11                	jg     105ffd <strtol+0xf1>
            dig = *s - 'a' + 10;
  105fec:	8b 45 08             	mov    0x8(%ebp),%eax
  105fef:	0f b6 00             	movzbl (%eax),%eax
  105ff2:	0f be c0             	movsbl %al,%eax
  105ff5:	83 e8 57             	sub    $0x57,%eax
  105ff8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ffb:	eb 23                	jmp    106020 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  106000:	0f b6 00             	movzbl (%eax),%eax
  106003:	3c 40                	cmp    $0x40,%al
  106005:	7e 3b                	jle    106042 <strtol+0x136>
  106007:	8b 45 08             	mov    0x8(%ebp),%eax
  10600a:	0f b6 00             	movzbl (%eax),%eax
  10600d:	3c 5a                	cmp    $0x5a,%al
  10600f:	7f 31                	jg     106042 <strtol+0x136>
            dig = *s - 'A' + 10;
  106011:	8b 45 08             	mov    0x8(%ebp),%eax
  106014:	0f b6 00             	movzbl (%eax),%eax
  106017:	0f be c0             	movsbl %al,%eax
  10601a:	83 e8 37             	sub    $0x37,%eax
  10601d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  106020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106023:	3b 45 10             	cmp    0x10(%ebp),%eax
  106026:	7d 19                	jge    106041 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106028:	ff 45 08             	incl   0x8(%ebp)
  10602b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10602e:	0f af 45 10          	imul   0x10(%ebp),%eax
  106032:	89 c2                	mov    %eax,%edx
  106034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106037:	01 d0                	add    %edx,%eax
  106039:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  10603c:	e9 72 ff ff ff       	jmp    105fb3 <strtol+0xa7>
            break;
  106041:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  106042:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106046:	74 08                	je     106050 <strtol+0x144>
        *endptr = (char *) s;
  106048:	8b 45 0c             	mov    0xc(%ebp),%eax
  10604b:	8b 55 08             	mov    0x8(%ebp),%edx
  10604e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106050:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106054:	74 07                	je     10605d <strtol+0x151>
  106056:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106059:	f7 d8                	neg    %eax
  10605b:	eb 03                	jmp    106060 <strtol+0x154>
  10605d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106060:	89 ec                	mov    %ebp,%esp
  106062:	5d                   	pop    %ebp
  106063:	c3                   	ret    

00106064 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  106064:	55                   	push   %ebp
  106065:	89 e5                	mov    %esp,%ebp
  106067:	83 ec 28             	sub    $0x28,%esp
  10606a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  10606d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106070:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106073:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  106077:	8b 45 08             	mov    0x8(%ebp),%eax
  10607a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10607d:	88 55 f7             	mov    %dl,-0x9(%ebp)
  106080:	8b 45 10             	mov    0x10(%ebp),%eax
  106083:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  106086:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  106089:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10608d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106090:	89 d7                	mov    %edx,%edi
  106092:	f3 aa                	rep stos %al,%es:(%edi)
  106094:	89 fa                	mov    %edi,%edx
  106096:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  106099:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  10609c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  10609f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1060a2:	89 ec                	mov    %ebp,%esp
  1060a4:	5d                   	pop    %ebp
  1060a5:	c3                   	ret    

001060a6 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1060a6:	55                   	push   %ebp
  1060a7:	89 e5                	mov    %esp,%ebp
  1060a9:	57                   	push   %edi
  1060aa:	56                   	push   %esi
  1060ab:	53                   	push   %ebx
  1060ac:	83 ec 30             	sub    $0x30,%esp
  1060af:	8b 45 08             	mov    0x8(%ebp),%eax
  1060b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1060b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1060bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1060be:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1060c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060c4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1060c7:	73 42                	jae    10610b <memmove+0x65>
  1060c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1060cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1060d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1060d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1060db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1060de:	c1 e8 02             	shr    $0x2,%eax
  1060e1:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1060e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1060e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1060e9:	89 d7                	mov    %edx,%edi
  1060eb:	89 c6                	mov    %eax,%esi
  1060ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1060ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1060f2:	83 e1 03             	and    $0x3,%ecx
  1060f5:	74 02                	je     1060f9 <memmove+0x53>
  1060f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1060f9:	89 f0                	mov    %esi,%eax
  1060fb:	89 fa                	mov    %edi,%edx
  1060fd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106100:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  106103:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  106106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  106109:	eb 36                	jmp    106141 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10610b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10610e:	8d 50 ff             	lea    -0x1(%eax),%edx
  106111:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106114:	01 c2                	add    %eax,%edx
  106116:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106119:	8d 48 ff             	lea    -0x1(%eax),%ecx
  10611c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10611f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  106122:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106125:	89 c1                	mov    %eax,%ecx
  106127:	89 d8                	mov    %ebx,%eax
  106129:	89 d6                	mov    %edx,%esi
  10612b:	89 c7                	mov    %eax,%edi
  10612d:	fd                   	std    
  10612e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106130:	fc                   	cld    
  106131:	89 f8                	mov    %edi,%eax
  106133:	89 f2                	mov    %esi,%edx
  106135:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106138:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10613b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10613e:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106141:	83 c4 30             	add    $0x30,%esp
  106144:	5b                   	pop    %ebx
  106145:	5e                   	pop    %esi
  106146:	5f                   	pop    %edi
  106147:	5d                   	pop    %ebp
  106148:	c3                   	ret    

00106149 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106149:	55                   	push   %ebp
  10614a:	89 e5                	mov    %esp,%ebp
  10614c:	57                   	push   %edi
  10614d:	56                   	push   %esi
  10614e:	83 ec 20             	sub    $0x20,%esp
  106151:	8b 45 08             	mov    0x8(%ebp),%eax
  106154:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106157:	8b 45 0c             	mov    0xc(%ebp),%eax
  10615a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10615d:	8b 45 10             	mov    0x10(%ebp),%eax
  106160:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106163:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106166:	c1 e8 02             	shr    $0x2,%eax
  106169:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10616b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106171:	89 d7                	mov    %edx,%edi
  106173:	89 c6                	mov    %eax,%esi
  106175:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106177:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10617a:	83 e1 03             	and    $0x3,%ecx
  10617d:	74 02                	je     106181 <memcpy+0x38>
  10617f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106181:	89 f0                	mov    %esi,%eax
  106183:	89 fa                	mov    %edi,%edx
  106185:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106188:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10618b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  10618e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106191:	83 c4 20             	add    $0x20,%esp
  106194:	5e                   	pop    %esi
  106195:	5f                   	pop    %edi
  106196:	5d                   	pop    %ebp
  106197:	c3                   	ret    

00106198 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  106198:	55                   	push   %ebp
  106199:	89 e5                	mov    %esp,%ebp
  10619b:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  10619e:	8b 45 08             	mov    0x8(%ebp),%eax
  1061a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1061a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1061aa:	eb 2e                	jmp    1061da <memcmp+0x42>
        if (*s1 != *s2) {
  1061ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061af:	0f b6 10             	movzbl (%eax),%edx
  1061b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1061b5:	0f b6 00             	movzbl (%eax),%eax
  1061b8:	38 c2                	cmp    %al,%dl
  1061ba:	74 18                	je     1061d4 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1061bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061bf:	0f b6 00             	movzbl (%eax),%eax
  1061c2:	0f b6 d0             	movzbl %al,%edx
  1061c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1061c8:	0f b6 00             	movzbl (%eax),%eax
  1061cb:	0f b6 c8             	movzbl %al,%ecx
  1061ce:	89 d0                	mov    %edx,%eax
  1061d0:	29 c8                	sub    %ecx,%eax
  1061d2:	eb 18                	jmp    1061ec <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1061d4:	ff 45 fc             	incl   -0x4(%ebp)
  1061d7:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  1061da:	8b 45 10             	mov    0x10(%ebp),%eax
  1061dd:	8d 50 ff             	lea    -0x1(%eax),%edx
  1061e0:	89 55 10             	mov    %edx,0x10(%ebp)
  1061e3:	85 c0                	test   %eax,%eax
  1061e5:	75 c5                	jne    1061ac <memcmp+0x14>
    }
    return 0;
  1061e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1061ec:	89 ec                	mov    %ebp,%esp
  1061ee:	5d                   	pop    %ebp
  1061ef:	c3                   	ret    
