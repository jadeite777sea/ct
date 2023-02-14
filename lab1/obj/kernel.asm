
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	b8 08 0d 11 00       	mov    $0x110d08,%eax
  10000b:	2d 16 fa 10 00       	sub    $0x10fa16,%eax
  100010:	89 44 24 08          	mov    %eax,0x8(%esp)
  100014:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001b:	00 
  10001c:	c7 04 24 16 fa 10 00 	movl   $0x10fa16,(%esp)
  100023:	e8 9d 33 00 00       	call   1033c5 <memset>

    cons_init();                // init the console
  100028:	e8 cc 15 00 00       	call   1015f9 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002d:	c7 45 f4 60 35 10 00 	movl   $0x103560,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100037:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003b:	c7 04 24 7c 35 10 00 	movl   $0x10357c,(%esp)
  100042:	e8 d9 02 00 00       	call   100320 <cprintf>

    print_kerninfo();
  100047:	e8 f7 07 00 00       	call   100843 <print_kerninfo>

    grade_backtrace();
  10004c:	e8 90 00 00 00       	call   1000e1 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100051:	e8 c6 29 00 00       	call   102a1c <pmm_init>

    pic_init();                 // init interrupt controller
  100056:	e8 f9 16 00 00       	call   101754 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005b:	e8 80 18 00 00       	call   1018e0 <idt_init>

    clock_init();               // init clock interrupt
  100060:	e8 35 0d 00 00       	call   100d9a <clock_init>
    intr_enable();              // enable irq interrupt
  100065:	e8 48 16 00 00       	call   1016b2 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  10006a:	eb fe                	jmp    10006a <kern_init+0x6a>

0010006c <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  10006c:	55                   	push   %ebp
  10006d:	89 e5                	mov    %esp,%ebp
  10006f:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  100072:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100079:	00 
  10007a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100081:	00 
  100082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100089:	e8 27 0c 00 00       	call   100cb5 <mon_backtrace>
}
  10008e:	90                   	nop
  10008f:	89 ec                	mov    %ebp,%esp
  100091:	5d                   	pop    %ebp
  100092:	c3                   	ret    

00100093 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100093:	55                   	push   %ebp
  100094:	89 e5                	mov    %esp,%ebp
  100096:	83 ec 18             	sub    $0x18,%esp
  100099:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  10009c:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  10009f:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000a2:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1000a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000ac:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000b4:	89 04 24             	mov    %eax,(%esp)
  1000b7:	e8 b0 ff ff ff       	call   10006c <grade_backtrace2>
}
  1000bc:	90                   	nop
  1000bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000c0:	89 ec                	mov    %ebp,%esp
  1000c2:	5d                   	pop    %ebp
  1000c3:	c3                   	ret    

001000c4 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c4:	55                   	push   %ebp
  1000c5:	89 e5                	mov    %esp,%ebp
  1000c7:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ca:	8b 45 10             	mov    0x10(%ebp),%eax
  1000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d4:	89 04 24             	mov    %eax,(%esp)
  1000d7:	e8 b7 ff ff ff       	call   100093 <grade_backtrace1>
}
  1000dc:	90                   	nop
  1000dd:	89 ec                	mov    %ebp,%esp
  1000df:	5d                   	pop    %ebp
  1000e0:	c3                   	ret    

001000e1 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e1:	55                   	push   %ebp
  1000e2:	89 e5                	mov    %esp,%ebp
  1000e4:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e7:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000ec:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f3:	ff 
  1000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000ff:	e8 c0 ff ff ff       	call   1000c4 <grade_backtrace0>
}
  100104:	90                   	nop
  100105:	89 ec                	mov    %ebp,%esp
  100107:	5d                   	pop    %ebp
  100108:	c3                   	ret    

00100109 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100109:	55                   	push   %ebp
  10010a:	89 e5                	mov    %esp,%ebp
  10010c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100112:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100115:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100118:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10011b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011f:	83 e0 03             	and    $0x3,%eax
  100122:	89 c2                	mov    %eax,%edx
  100124:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100129:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100131:	c7 04 24 81 35 10 00 	movl   $0x103581,(%esp)
  100138:	e8 e3 01 00 00       	call   100320 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100141:	89 c2                	mov    %eax,%edx
  100143:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 8f 35 10 00 	movl   $0x10358f,(%esp)
  100157:	e8 c4 01 00 00       	call   100320 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	89 c2                	mov    %eax,%edx
  100162:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100167:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016f:	c7 04 24 9d 35 10 00 	movl   $0x10359d,(%esp)
  100176:	e8 a5 01 00 00       	call   100320 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017f:	89 c2                	mov    %eax,%edx
  100181:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100186:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018e:	c7 04 24 ab 35 10 00 	movl   $0x1035ab,(%esp)
  100195:	e8 86 01 00 00       	call   100320 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019e:	89 c2                	mov    %eax,%edx
  1001a0:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ad:	c7 04 24 b9 35 10 00 	movl   $0x1035b9,(%esp)
  1001b4:	e8 67 01 00 00       	call   100320 <cprintf>
    round ++;
  1001b9:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001be:	40                   	inc    %eax
  1001bf:	a3 20 fa 10 00       	mov    %eax,0x10fa20
}
  1001c4:	90                   	nop
  1001c5:	89 ec                	mov    %ebp,%esp
  1001c7:	5d                   	pop    %ebp
  1001c8:	c3                   	ret    

001001c9 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c9:	55                   	push   %ebp
  1001ca:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001cc:	90                   	nop
  1001cd:	5d                   	pop    %ebp
  1001ce:	c3                   	ret    

001001cf <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001cf:	55                   	push   %ebp
  1001d0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  1001d2:	90                   	nop
  1001d3:	5d                   	pop    %ebp
  1001d4:	c3                   	ret    

001001d5 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001d5:	55                   	push   %ebp
  1001d6:	89 e5                	mov    %esp,%ebp
  1001d8:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001db:	e8 29 ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001e0:	c7 04 24 c8 35 10 00 	movl   $0x1035c8,(%esp)
  1001e7:	e8 34 01 00 00       	call   100320 <cprintf>
    lab1_switch_to_user();
  1001ec:	e8 d8 ff ff ff       	call   1001c9 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001f1:	e8 13 ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001f6:	c7 04 24 e8 35 10 00 	movl   $0x1035e8,(%esp)
  1001fd:	e8 1e 01 00 00       	call   100320 <cprintf>
    lab1_switch_to_kernel();
  100202:	e8 c8 ff ff ff       	call   1001cf <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100207:	e8 fd fe ff ff       	call   100109 <lab1_print_cur_status>
}
  10020c:	90                   	nop
  10020d:	89 ec                	mov    %ebp,%esp
  10020f:	5d                   	pop    %ebp
  100210:	c3                   	ret    

00100211 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100211:	55                   	push   %ebp
  100212:	89 e5                	mov    %esp,%ebp
  100214:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100217:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10021b:	74 13                	je     100230 <readline+0x1f>
        cprintf("%s", prompt);
  10021d:	8b 45 08             	mov    0x8(%ebp),%eax
  100220:	89 44 24 04          	mov    %eax,0x4(%esp)
  100224:	c7 04 24 07 36 10 00 	movl   $0x103607,(%esp)
  10022b:	e8 f0 00 00 00       	call   100320 <cprintf>
    }
    int i = 0, c;
  100230:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100237:	e8 73 01 00 00       	call   1003af <getchar>
  10023c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10023f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100243:	79 07                	jns    10024c <readline+0x3b>
            return NULL;
  100245:	b8 00 00 00 00       	mov    $0x0,%eax
  10024a:	eb 78                	jmp    1002c4 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10024c:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100250:	7e 28                	jle    10027a <readline+0x69>
  100252:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100259:	7f 1f                	jg     10027a <readline+0x69>
            cputchar(c);
  10025b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10025e:	89 04 24             	mov    %eax,(%esp)
  100261:	e8 e2 00 00 00       	call   100348 <cputchar>
            buf[i ++] = c;
  100266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100269:	8d 50 01             	lea    0x1(%eax),%edx
  10026c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10026f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100272:	88 90 40 fa 10 00    	mov    %dl,0x10fa40(%eax)
  100278:	eb 45                	jmp    1002bf <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  10027a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10027e:	75 16                	jne    100296 <readline+0x85>
  100280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100284:	7e 10                	jle    100296 <readline+0x85>
            cputchar(c);
  100286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100289:	89 04 24             	mov    %eax,(%esp)
  10028c:	e8 b7 00 00 00       	call   100348 <cputchar>
            i --;
  100291:	ff 4d f4             	decl   -0xc(%ebp)
  100294:	eb 29                	jmp    1002bf <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  100296:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  10029a:	74 06                	je     1002a2 <readline+0x91>
  10029c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002a0:	75 95                	jne    100237 <readline+0x26>
            cputchar(c);
  1002a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a5:	89 04 24             	mov    %eax,(%esp)
  1002a8:	e8 9b 00 00 00       	call   100348 <cputchar>
            buf[i] = '\0';
  1002ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002b0:	05 40 fa 10 00       	add    $0x10fa40,%eax
  1002b5:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002b8:	b8 40 fa 10 00       	mov    $0x10fa40,%eax
  1002bd:	eb 05                	jmp    1002c4 <readline+0xb3>
        c = getchar();
  1002bf:	e9 73 ff ff ff       	jmp    100237 <readline+0x26>
        }
    }
}
  1002c4:	89 ec                	mov    %ebp,%esp
  1002c6:	5d                   	pop    %ebp
  1002c7:	c3                   	ret    

001002c8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002c8:	55                   	push   %ebp
  1002c9:	89 e5                	mov    %esp,%ebp
  1002cb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d1:	89 04 24             	mov    %eax,(%esp)
  1002d4:	e8 4f 13 00 00       	call   101628 <cons_putc>
    (*cnt) ++;
  1002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002dc:	8b 00                	mov    (%eax),%eax
  1002de:	8d 50 01             	lea    0x1(%eax),%edx
  1002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002e4:	89 10                	mov    %edx,(%eax)
}
  1002e6:	90                   	nop
  1002e7:	89 ec                	mov    %ebp,%esp
  1002e9:	5d                   	pop    %ebp
  1002ea:	c3                   	ret    

001002eb <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  1002eb:	55                   	push   %ebp
  1002ec:	89 e5                	mov    %esp,%ebp
  1002ee:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  100302:	89 44 24 08          	mov    %eax,0x8(%esp)
  100306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100309:	89 44 24 04          	mov    %eax,0x4(%esp)
  10030d:	c7 04 24 c8 02 10 00 	movl   $0x1002c8,(%esp)
  100314:	e8 d7 28 00 00       	call   102bf0 <vprintfmt>
    return cnt;
  100319:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10031c:	89 ec                	mov    %ebp,%esp
  10031e:	5d                   	pop    %ebp
  10031f:	c3                   	ret    

00100320 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100320:	55                   	push   %ebp
  100321:	89 e5                	mov    %esp,%ebp
  100323:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100326:	8d 45 0c             	lea    0xc(%ebp),%eax
  100329:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10032c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10032f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100333:	8b 45 08             	mov    0x8(%ebp),%eax
  100336:	89 04 24             	mov    %eax,(%esp)
  100339:	e8 ad ff ff ff       	call   1002eb <vcprintf>
  10033e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100341:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100344:	89 ec                	mov    %ebp,%esp
  100346:	5d                   	pop    %ebp
  100347:	c3                   	ret    

00100348 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10034e:	8b 45 08             	mov    0x8(%ebp),%eax
  100351:	89 04 24             	mov    %eax,(%esp)
  100354:	e8 cf 12 00 00       	call   101628 <cons_putc>
}
  100359:	90                   	nop
  10035a:	89 ec                	mov    %ebp,%esp
  10035c:	5d                   	pop    %ebp
  10035d:	c3                   	ret    

0010035e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10035e:	55                   	push   %ebp
  10035f:	89 e5                	mov    %esp,%ebp
  100361:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100364:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10036b:	eb 13                	jmp    100380 <cputs+0x22>
        cputch(c, &cnt);
  10036d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100371:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100374:	89 54 24 04          	mov    %edx,0x4(%esp)
  100378:	89 04 24             	mov    %eax,(%esp)
  10037b:	e8 48 ff ff ff       	call   1002c8 <cputch>
    while ((c = *str ++) != '\0') {
  100380:	8b 45 08             	mov    0x8(%ebp),%eax
  100383:	8d 50 01             	lea    0x1(%eax),%edx
  100386:	89 55 08             	mov    %edx,0x8(%ebp)
  100389:	0f b6 00             	movzbl (%eax),%eax
  10038c:	88 45 f7             	mov    %al,-0x9(%ebp)
  10038f:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100393:	75 d8                	jne    10036d <cputs+0xf>
    }
    cputch('\n', &cnt);
  100395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100398:	89 44 24 04          	mov    %eax,0x4(%esp)
  10039c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003a3:	e8 20 ff ff ff       	call   1002c8 <cputch>
    return cnt;
  1003a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003ab:	89 ec                	mov    %ebp,%esp
  1003ad:	5d                   	pop    %ebp
  1003ae:	c3                   	ret    

001003af <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003af:	55                   	push   %ebp
  1003b0:	89 e5                	mov    %esp,%ebp
  1003b2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003b5:	90                   	nop
  1003b6:	e8 99 12 00 00       	call   101654 <cons_getc>
  1003bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003c2:	74 f2                	je     1003b6 <getchar+0x7>
        /* do nothing */;
    return c;
  1003c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003c7:	89 ec                	mov    %ebp,%esp
  1003c9:	5d                   	pop    %ebp
  1003ca:	c3                   	ret    

001003cb <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003cb:	55                   	push   %ebp
  1003cc:	89 e5                	mov    %esp,%ebp
  1003ce:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003d4:	8b 00                	mov    (%eax),%eax
  1003d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1003dc:	8b 00                	mov    (%eax),%eax
  1003de:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1003e8:	e9 ca 00 00 00       	jmp    1004b7 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1003ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1003f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1003f3:	01 d0                	add    %edx,%eax
  1003f5:	89 c2                	mov    %eax,%edx
  1003f7:	c1 ea 1f             	shr    $0x1f,%edx
  1003fa:	01 d0                	add    %edx,%eax
  1003fc:	d1 f8                	sar    %eax
  1003fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100401:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100404:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100407:	eb 03                	jmp    10040c <stab_binsearch+0x41>
            m --;
  100409:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  10040c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10040f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100412:	7c 1f                	jl     100433 <stab_binsearch+0x68>
  100414:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100417:	89 d0                	mov    %edx,%eax
  100419:	01 c0                	add    %eax,%eax
  10041b:	01 d0                	add    %edx,%eax
  10041d:	c1 e0 02             	shl    $0x2,%eax
  100420:	89 c2                	mov    %eax,%edx
  100422:	8b 45 08             	mov    0x8(%ebp),%eax
  100425:	01 d0                	add    %edx,%eax
  100427:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10042b:	0f b6 c0             	movzbl %al,%eax
  10042e:	39 45 14             	cmp    %eax,0x14(%ebp)
  100431:	75 d6                	jne    100409 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100436:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100439:	7d 09                	jge    100444 <stab_binsearch+0x79>
            l = true_m + 1;
  10043b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10043e:	40                   	inc    %eax
  10043f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100442:	eb 73                	jmp    1004b7 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100444:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10044b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10044e:	89 d0                	mov    %edx,%eax
  100450:	01 c0                	add    %eax,%eax
  100452:	01 d0                	add    %edx,%eax
  100454:	c1 e0 02             	shl    $0x2,%eax
  100457:	89 c2                	mov    %eax,%edx
  100459:	8b 45 08             	mov    0x8(%ebp),%eax
  10045c:	01 d0                	add    %edx,%eax
  10045e:	8b 40 08             	mov    0x8(%eax),%eax
  100461:	39 45 18             	cmp    %eax,0x18(%ebp)
  100464:	76 11                	jbe    100477 <stab_binsearch+0xac>
            *region_left = m;
  100466:	8b 45 0c             	mov    0xc(%ebp),%eax
  100469:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10046c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10046e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100471:	40                   	inc    %eax
  100472:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100475:	eb 40                	jmp    1004b7 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10047a:	89 d0                	mov    %edx,%eax
  10047c:	01 c0                	add    %eax,%eax
  10047e:	01 d0                	add    %edx,%eax
  100480:	c1 e0 02             	shl    $0x2,%eax
  100483:	89 c2                	mov    %eax,%edx
  100485:	8b 45 08             	mov    0x8(%ebp),%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	8b 40 08             	mov    0x8(%eax),%eax
  10048d:	39 45 18             	cmp    %eax,0x18(%ebp)
  100490:	73 14                	jae    1004a6 <stab_binsearch+0xdb>
            *region_right = m - 1;
  100492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100495:	8d 50 ff             	lea    -0x1(%eax),%edx
  100498:	8b 45 10             	mov    0x10(%ebp),%eax
  10049b:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10049d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004a0:	48                   	dec    %eax
  1004a1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a4:	eb 11                	jmp    1004b7 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004ac:	89 10                	mov    %edx,(%eax)
            l = m;
  1004ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004b4:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004bd:	0f 8e 2a ff ff ff    	jle    1003ed <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1004c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004c7:	75 0f                	jne    1004d8 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cc:	8b 00                	mov    (%eax),%eax
  1004ce:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d4:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1004d6:	eb 3e                	jmp    100516 <stab_binsearch+0x14b>
        l = *region_right;
  1004d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1004db:	8b 00                	mov    (%eax),%eax
  1004dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1004e0:	eb 03                	jmp    1004e5 <stab_binsearch+0x11a>
  1004e2:	ff 4d fc             	decl   -0x4(%ebp)
  1004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e8:	8b 00                	mov    (%eax),%eax
  1004ea:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1004ed:	7e 1f                	jle    10050e <stab_binsearch+0x143>
  1004ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004f2:	89 d0                	mov    %edx,%eax
  1004f4:	01 c0                	add    %eax,%eax
  1004f6:	01 d0                	add    %edx,%eax
  1004f8:	c1 e0 02             	shl    $0x2,%eax
  1004fb:	89 c2                	mov    %eax,%edx
  1004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  100500:	01 d0                	add    %edx,%eax
  100502:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100506:	0f b6 c0             	movzbl %al,%eax
  100509:	39 45 14             	cmp    %eax,0x14(%ebp)
  10050c:	75 d4                	jne    1004e2 <stab_binsearch+0x117>
        *region_left = l;
  10050e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100511:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100514:	89 10                	mov    %edx,(%eax)
}
  100516:	90                   	nop
  100517:	89 ec                	mov    %ebp,%esp
  100519:	5d                   	pop    %ebp
  10051a:	c3                   	ret    

0010051b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10051b:	55                   	push   %ebp
  10051c:	89 e5                	mov    %esp,%ebp
  10051e:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100521:	8b 45 0c             	mov    0xc(%ebp),%eax
  100524:	c7 00 0c 36 10 00    	movl   $0x10360c,(%eax)
    info->eip_line = 0;
  10052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100534:	8b 45 0c             	mov    0xc(%ebp),%eax
  100537:	c7 40 08 0c 36 10 00 	movl   $0x10360c,0x8(%eax)
    info->eip_fn_namelen = 9;
  10053e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100541:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100548:	8b 45 0c             	mov    0xc(%ebp),%eax
  10054b:	8b 55 08             	mov    0x8(%ebp),%edx
  10054e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100551:	8b 45 0c             	mov    0xc(%ebp),%eax
  100554:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10055b:	c7 45 f4 6c 3e 10 00 	movl   $0x103e6c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100562:	c7 45 f0 a0 bb 10 00 	movl   $0x10bba0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100569:	c7 45 ec a1 bb 10 00 	movl   $0x10bba1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100570:	c7 45 e8 10 e5 10 00 	movl   $0x10e510,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100577:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10057a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10057d:	76 0b                	jbe    10058a <debuginfo_eip+0x6f>
  10057f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100582:	48                   	dec    %eax
  100583:	0f b6 00             	movzbl (%eax),%eax
  100586:	84 c0                	test   %al,%al
  100588:	74 0a                	je     100594 <debuginfo_eip+0x79>
        return -1;
  10058a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10058f:	e9 ab 02 00 00       	jmp    10083f <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100594:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059e:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005a1:	c1 f8 02             	sar    $0x2,%eax
  1005a4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005aa:	48                   	dec    %eax
  1005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1005b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005b5:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005bc:	00 
  1005bd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005ce:	89 04 24             	mov    %eax,(%esp)
  1005d1:	e8 f5 fd ff ff       	call   1003cb <stab_binsearch>
    if (lfile == 0)
  1005d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005d9:	85 c0                	test   %eax,%eax
  1005db:	75 0a                	jne    1005e7 <debuginfo_eip+0xcc>
        return -1;
  1005dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005e2:	e9 58 02 00 00       	jmp    10083f <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1005e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1005ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1005f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1005f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1005f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005fa:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100601:	00 
  100602:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100605:	89 44 24 08          	mov    %eax,0x8(%esp)
  100609:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100613:	89 04 24             	mov    %eax,(%esp)
  100616:	e8 b0 fd ff ff       	call   1003cb <stab_binsearch>

    if (lfun <= rfun) {
  10061b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10061e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100621:	39 c2                	cmp    %eax,%edx
  100623:	7f 78                	jg     10069d <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100625:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100628:	89 c2                	mov    %eax,%edx
  10062a:	89 d0                	mov    %edx,%eax
  10062c:	01 c0                	add    %eax,%eax
  10062e:	01 d0                	add    %edx,%eax
  100630:	c1 e0 02             	shl    $0x2,%eax
  100633:	89 c2                	mov    %eax,%edx
  100635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100638:	01 d0                	add    %edx,%eax
  10063a:	8b 10                	mov    (%eax),%edx
  10063c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100642:	39 c2                	cmp    %eax,%edx
  100644:	73 22                	jae    100668 <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100646:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100649:	89 c2                	mov    %eax,%edx
  10064b:	89 d0                	mov    %edx,%eax
  10064d:	01 c0                	add    %eax,%eax
  10064f:	01 d0                	add    %edx,%eax
  100651:	c1 e0 02             	shl    $0x2,%eax
  100654:	89 c2                	mov    %eax,%edx
  100656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100659:	01 d0                	add    %edx,%eax
  10065b:	8b 10                	mov    (%eax),%edx
  10065d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100660:	01 c2                	add    %eax,%edx
  100662:	8b 45 0c             	mov    0xc(%ebp),%eax
  100665:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100668:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10066b:	89 c2                	mov    %eax,%edx
  10066d:	89 d0                	mov    %edx,%eax
  10066f:	01 c0                	add    %eax,%eax
  100671:	01 d0                	add    %edx,%eax
  100673:	c1 e0 02             	shl    $0x2,%eax
  100676:	89 c2                	mov    %eax,%edx
  100678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10067b:	01 d0                	add    %edx,%eax
  10067d:	8b 50 08             	mov    0x8(%eax),%edx
  100680:	8b 45 0c             	mov    0xc(%ebp),%eax
  100683:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100686:	8b 45 0c             	mov    0xc(%ebp),%eax
  100689:	8b 40 10             	mov    0x10(%eax),%eax
  10068c:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10068f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100692:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100695:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100698:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10069b:	eb 15                	jmp    1006b2 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10069d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006a0:	8b 55 08             	mov    0x8(%ebp),%edx
  1006a3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006af:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b5:	8b 40 08             	mov    0x8(%eax),%eax
  1006b8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006bf:	00 
  1006c0:	89 04 24             	mov    %eax,(%esp)
  1006c3:	e8 75 2b 00 00       	call   10323d <strfind>
  1006c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1006cb:	8b 4a 08             	mov    0x8(%edx),%ecx
  1006ce:	29 c8                	sub    %ecx,%eax
  1006d0:	89 c2                	mov    %eax,%edx
  1006d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d5:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1006db:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006df:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1006e6:	00 
  1006e7:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1006ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006ee:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1006f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006f8:	89 04 24             	mov    %eax,(%esp)
  1006fb:	e8 cb fc ff ff       	call   1003cb <stab_binsearch>
    if (lline <= rline) {
  100700:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100703:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100706:	39 c2                	cmp    %eax,%edx
  100708:	7f 23                	jg     10072d <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  10070a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10070d:	89 c2                	mov    %eax,%edx
  10070f:	89 d0                	mov    %edx,%eax
  100711:	01 c0                	add    %eax,%eax
  100713:	01 d0                	add    %edx,%eax
  100715:	c1 e0 02             	shl    $0x2,%eax
  100718:	89 c2                	mov    %eax,%edx
  10071a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100723:	89 c2                	mov    %eax,%edx
  100725:	8b 45 0c             	mov    0xc(%ebp),%eax
  100728:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10072b:	eb 11                	jmp    10073e <debuginfo_eip+0x223>
        return -1;
  10072d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100732:	e9 08 01 00 00       	jmp    10083f <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100737:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10073a:	48                   	dec    %eax
  10073b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10073e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100741:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100744:	39 c2                	cmp    %eax,%edx
  100746:	7c 56                	jl     10079e <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  100748:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10074b:	89 c2                	mov    %eax,%edx
  10074d:	89 d0                	mov    %edx,%eax
  10074f:	01 c0                	add    %eax,%eax
  100751:	01 d0                	add    %edx,%eax
  100753:	c1 e0 02             	shl    $0x2,%eax
  100756:	89 c2                	mov    %eax,%edx
  100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075b:	01 d0                	add    %edx,%eax
  10075d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100761:	3c 84                	cmp    $0x84,%al
  100763:	74 39                	je     10079e <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100765:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100768:	89 c2                	mov    %eax,%edx
  10076a:	89 d0                	mov    %edx,%eax
  10076c:	01 c0                	add    %eax,%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	c1 e0 02             	shl    $0x2,%eax
  100773:	89 c2                	mov    %eax,%edx
  100775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100778:	01 d0                	add    %edx,%eax
  10077a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10077e:	3c 64                	cmp    $0x64,%al
  100780:	75 b5                	jne    100737 <debuginfo_eip+0x21c>
  100782:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100785:	89 c2                	mov    %eax,%edx
  100787:	89 d0                	mov    %edx,%eax
  100789:	01 c0                	add    %eax,%eax
  10078b:	01 d0                	add    %edx,%eax
  10078d:	c1 e0 02             	shl    $0x2,%eax
  100790:	89 c2                	mov    %eax,%edx
  100792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100795:	01 d0                	add    %edx,%eax
  100797:	8b 40 08             	mov    0x8(%eax),%eax
  10079a:	85 c0                	test   %eax,%eax
  10079c:	74 99                	je     100737 <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10079e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007a4:	39 c2                	cmp    %eax,%edx
  1007a6:	7c 42                	jl     1007ea <debuginfo_eip+0x2cf>
  1007a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ab:	89 c2                	mov    %eax,%edx
  1007ad:	89 d0                	mov    %edx,%eax
  1007af:	01 c0                	add    %eax,%eax
  1007b1:	01 d0                	add    %edx,%eax
  1007b3:	c1 e0 02             	shl    $0x2,%eax
  1007b6:	89 c2                	mov    %eax,%edx
  1007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007bb:	01 d0                	add    %edx,%eax
  1007bd:	8b 10                	mov    (%eax),%edx
  1007bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007c2:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007c5:	39 c2                	cmp    %eax,%edx
  1007c7:	73 21                	jae    1007ea <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007cc:	89 c2                	mov    %eax,%edx
  1007ce:	89 d0                	mov    %edx,%eax
  1007d0:	01 c0                	add    %eax,%eax
  1007d2:	01 d0                	add    %edx,%eax
  1007d4:	c1 e0 02             	shl    $0x2,%eax
  1007d7:	89 c2                	mov    %eax,%edx
  1007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007dc:	01 d0                	add    %edx,%eax
  1007de:	8b 10                	mov    (%eax),%edx
  1007e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007e3:	01 c2                	add    %eax,%edx
  1007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007e8:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1007ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1007ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007f0:	39 c2                	cmp    %eax,%edx
  1007f2:	7d 46                	jge    10083a <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  1007f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007f7:	40                   	inc    %eax
  1007f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1007fb:	eb 16                	jmp    100813 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100800:	8b 40 14             	mov    0x14(%eax),%eax
  100803:	8d 50 01             	lea    0x1(%eax),%edx
  100806:	8b 45 0c             	mov    0xc(%ebp),%eax
  100809:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  10080c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10080f:	40                   	inc    %eax
  100810:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100813:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100819:	39 c2                	cmp    %eax,%edx
  10081b:	7d 1d                	jge    10083a <debuginfo_eip+0x31f>
  10081d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100820:	89 c2                	mov    %eax,%edx
  100822:	89 d0                	mov    %edx,%eax
  100824:	01 c0                	add    %eax,%eax
  100826:	01 d0                	add    %edx,%eax
  100828:	c1 e0 02             	shl    $0x2,%eax
  10082b:	89 c2                	mov    %eax,%edx
  10082d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100830:	01 d0                	add    %edx,%eax
  100832:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100836:	3c a0                	cmp    $0xa0,%al
  100838:	74 c3                	je     1007fd <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  10083a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10083f:	89 ec                	mov    %ebp,%esp
  100841:	5d                   	pop    %ebp
  100842:	c3                   	ret    

00100843 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100843:	55                   	push   %ebp
  100844:	89 e5                	mov    %esp,%ebp
  100846:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100849:	c7 04 24 16 36 10 00 	movl   $0x103616,(%esp)
  100850:	e8 cb fa ff ff       	call   100320 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100855:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10085c:	00 
  10085d:	c7 04 24 2f 36 10 00 	movl   $0x10362f,(%esp)
  100864:	e8 b7 fa ff ff       	call   100320 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100869:	c7 44 24 04 51 35 10 	movl   $0x103551,0x4(%esp)
  100870:	00 
  100871:	c7 04 24 47 36 10 00 	movl   $0x103647,(%esp)
  100878:	e8 a3 fa ff ff       	call   100320 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10087d:	c7 44 24 04 16 fa 10 	movl   $0x10fa16,0x4(%esp)
  100884:	00 
  100885:	c7 04 24 5f 36 10 00 	movl   $0x10365f,(%esp)
  10088c:	e8 8f fa ff ff       	call   100320 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100891:	c7 44 24 04 08 0d 11 	movl   $0x110d08,0x4(%esp)
  100898:	00 
  100899:	c7 04 24 77 36 10 00 	movl   $0x103677,(%esp)
  1008a0:	e8 7b fa ff ff       	call   100320 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008a5:	b8 08 0d 11 00       	mov    $0x110d08,%eax
  1008aa:	2d 00 00 10 00       	sub    $0x100000,%eax
  1008af:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008b4:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008ba:	85 c0                	test   %eax,%eax
  1008bc:	0f 48 c2             	cmovs  %edx,%eax
  1008bf:	c1 f8 0a             	sar    $0xa,%eax
  1008c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008c6:	c7 04 24 90 36 10 00 	movl   $0x103690,(%esp)
  1008cd:	e8 4e fa ff ff       	call   100320 <cprintf>
}
  1008d2:	90                   	nop
  1008d3:	89 ec                	mov    %ebp,%esp
  1008d5:	5d                   	pop    %ebp
  1008d6:	c3                   	ret    

001008d7 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1008d7:	55                   	push   %ebp
  1008d8:	89 e5                	mov    %esp,%ebp
  1008da:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1008e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1008ea:	89 04 24             	mov    %eax,(%esp)
  1008ed:	e8 29 fc ff ff       	call   10051b <debuginfo_eip>
  1008f2:	85 c0                	test   %eax,%eax
  1008f4:	74 15                	je     10090b <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1008f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fd:	c7 04 24 ba 36 10 00 	movl   $0x1036ba,(%esp)
  100904:	e8 17 fa ff ff       	call   100320 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100909:	eb 6c                	jmp    100977 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  10090b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100912:	eb 1b                	jmp    10092f <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100914:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10091a:	01 d0                	add    %edx,%eax
  10091c:	0f b6 10             	movzbl (%eax),%edx
  10091f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100928:	01 c8                	add    %ecx,%eax
  10092a:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  10092c:	ff 45 f4             	incl   -0xc(%ebp)
  10092f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100932:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100935:	7c dd                	jl     100914 <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100937:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  10093d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100940:	01 d0                	add    %edx,%eax
  100942:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100945:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100948:	8b 45 08             	mov    0x8(%ebp),%eax
  10094b:	29 d0                	sub    %edx,%eax
  10094d:	89 c1                	mov    %eax,%ecx
  10094f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100952:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100955:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100959:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100963:	89 54 24 08          	mov    %edx,0x8(%esp)
  100967:	89 44 24 04          	mov    %eax,0x4(%esp)
  10096b:	c7 04 24 d6 36 10 00 	movl   $0x1036d6,(%esp)
  100972:	e8 a9 f9 ff ff       	call   100320 <cprintf>
}
  100977:	90                   	nop
  100978:	89 ec                	mov    %ebp,%esp
  10097a:	5d                   	pop    %ebp
  10097b:	c3                   	ret    

0010097c <read_eip>:

static __noinline uint32_t
read_eip(void) {
  10097c:	55                   	push   %ebp
  10097d:	89 e5                	mov    %esp,%ebp
  10097f:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100982:	8b 45 04             	mov    0x4(%ebp),%eax
  100985:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100988:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10098b:	89 ec                	mov    %ebp,%esp
  10098d:	5d                   	pop    %ebp
  10098e:	c3                   	ret    

0010098f <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  10098f:	55                   	push   %ebp
  100990:	89 e5                	mov    %esp,%ebp
  100992:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100995:	89 e8                	mov    %ebp,%eax
  100997:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  10099a:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
  10099d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
  1009a0:	e8 d7 ff ff ff       	call   10097c <read_eip>
  1009a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i,j;
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
  1009a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009af:	e9 a8 00 00 00       	jmp    100a5c <print_stackframe+0xcd>
      {
        cprintf("%08x",ebp);
  1009b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009bb:	c7 04 24 e8 36 10 00 	movl   $0x1036e8,(%esp)
  1009c2:	e8 59 f9 ff ff       	call   100320 <cprintf>
        cprintf(" ");
  1009c7:	c7 04 24 ed 36 10 00 	movl   $0x1036ed,(%esp)
  1009ce:	e8 4d f9 ff ff       	call   100320 <cprintf>
        cprintf("%08x",eip);
  1009d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009da:	c7 04 24 e8 36 10 00 	movl   $0x1036e8,(%esp)
  1009e1:	e8 3a f9 ff ff       	call   100320 <cprintf>
        uint32_t* a=(uint32_t*)ebp+2;
  1009e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009e9:	83 c0 08             	add    $0x8,%eax
  1009ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j=0;j<4;j++)
  1009ef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  1009f6:	eb 30                	jmp    100a28 <print_stackframe+0x99>
        {
            cprintf(" ");
  1009f8:	c7 04 24 ed 36 10 00 	movl   $0x1036ed,(%esp)
  1009ff:	e8 1c f9 ff ff       	call   100320 <cprintf>
            cprintf("%08x",a[j]);
  100a04:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a11:	01 d0                	add    %edx,%eax
  100a13:	8b 00                	mov    (%eax),%eax
  100a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a19:	c7 04 24 e8 36 10 00 	movl   $0x1036e8,(%esp)
  100a20:	e8 fb f8 ff ff       	call   100320 <cprintf>
        for(j=0;j<4;j++)
  100a25:	ff 45 e8             	incl   -0x18(%ebp)
  100a28:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a2c:	7e ca                	jle    1009f8 <print_stackframe+0x69>
        }
        cprintf("\n");
  100a2e:	c7 04 24 ef 36 10 00 	movl   $0x1036ef,(%esp)
  100a35:	e8 e6 f8 ff ff       	call   100320 <cprintf>

        print_debuginfo(eip-1);
  100a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a3d:	48                   	dec    %eax
  100a3e:	89 04 24             	mov    %eax,(%esp)
  100a41:	e8 91 fe ff ff       	call   1008d7 <print_debuginfo>

        eip=((uint32_t*)ebp)[1];
  100a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a49:	83 c0 04             	add    $0x4,%eax
  100a4c:	8b 00                	mov    (%eax),%eax
  100a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp=((uint32_t*)ebp)[0];
  100a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a54:	8b 00                	mov    (%eax),%eax
  100a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
  100a59:	ff 45 ec             	incl   -0x14(%ebp)
  100a5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a60:	74 0a                	je     100a6c <print_stackframe+0xdd>
  100a62:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a66:	0f 8e 48 ff ff ff    	jle    1009b4 <print_stackframe+0x25>


      }
}
  100a6c:	90                   	nop
  100a6d:	89 ec                	mov    %ebp,%esp
  100a6f:	5d                   	pop    %ebp
  100a70:	c3                   	ret    

00100a71 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a71:	55                   	push   %ebp
  100a72:	89 e5                	mov    %esp,%ebp
  100a74:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a7e:	eb 0c                	jmp    100a8c <parse+0x1b>
            *buf ++ = '\0';
  100a80:	8b 45 08             	mov    0x8(%ebp),%eax
  100a83:	8d 50 01             	lea    0x1(%eax),%edx
  100a86:	89 55 08             	mov    %edx,0x8(%ebp)
  100a89:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  100a8f:	0f b6 00             	movzbl (%eax),%eax
  100a92:	84 c0                	test   %al,%al
  100a94:	74 1d                	je     100ab3 <parse+0x42>
  100a96:	8b 45 08             	mov    0x8(%ebp),%eax
  100a99:	0f b6 00             	movzbl (%eax),%eax
  100a9c:	0f be c0             	movsbl %al,%eax
  100a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aa3:	c7 04 24 74 37 10 00 	movl   $0x103774,(%esp)
  100aaa:	e8 5a 27 00 00       	call   103209 <strchr>
  100aaf:	85 c0                	test   %eax,%eax
  100ab1:	75 cd                	jne    100a80 <parse+0xf>
        }
        if (*buf == '\0') {
  100ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab6:	0f b6 00             	movzbl (%eax),%eax
  100ab9:	84 c0                	test   %al,%al
  100abb:	74 65                	je     100b22 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100abd:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ac1:	75 14                	jne    100ad7 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ac3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100aca:	00 
  100acb:	c7 04 24 79 37 10 00 	movl   $0x103779,(%esp)
  100ad2:	e8 49 f8 ff ff       	call   100320 <cprintf>
        }
        argv[argc ++] = buf;
  100ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ada:	8d 50 01             	lea    0x1(%eax),%edx
  100add:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ae0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  100aea:	01 c2                	add    %eax,%edx
  100aec:	8b 45 08             	mov    0x8(%ebp),%eax
  100aef:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100af1:	eb 03                	jmp    100af6 <parse+0x85>
            buf ++;
  100af3:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100af6:	8b 45 08             	mov    0x8(%ebp),%eax
  100af9:	0f b6 00             	movzbl (%eax),%eax
  100afc:	84 c0                	test   %al,%al
  100afe:	74 8c                	je     100a8c <parse+0x1b>
  100b00:	8b 45 08             	mov    0x8(%ebp),%eax
  100b03:	0f b6 00             	movzbl (%eax),%eax
  100b06:	0f be c0             	movsbl %al,%eax
  100b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b0d:	c7 04 24 74 37 10 00 	movl   $0x103774,(%esp)
  100b14:	e8 f0 26 00 00       	call   103209 <strchr>
  100b19:	85 c0                	test   %eax,%eax
  100b1b:	74 d6                	je     100af3 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b1d:	e9 6a ff ff ff       	jmp    100a8c <parse+0x1b>
            break;
  100b22:	90                   	nop
        }
    }
    return argc;
  100b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b26:	89 ec                	mov    %ebp,%esp
  100b28:	5d                   	pop    %ebp
  100b29:	c3                   	ret    

00100b2a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b2a:	55                   	push   %ebp
  100b2b:	89 e5                	mov    %esp,%ebp
  100b2d:	83 ec 68             	sub    $0x68,%esp
  100b30:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b33:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b3d:	89 04 24             	mov    %eax,(%esp)
  100b40:	e8 2c ff ff ff       	call   100a71 <parse>
  100b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b4c:	75 0a                	jne    100b58 <runcmd+0x2e>
        return 0;
  100b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  100b53:	e9 83 00 00 00       	jmp    100bdb <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b5f:	eb 5a                	jmp    100bbb <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b61:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b64:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b67:	89 c8                	mov    %ecx,%eax
  100b69:	01 c0                	add    %eax,%eax
  100b6b:	01 c8                	add    %ecx,%eax
  100b6d:	c1 e0 02             	shl    $0x2,%eax
  100b70:	05 00 f0 10 00       	add    $0x10f000,%eax
  100b75:	8b 00                	mov    (%eax),%eax
  100b77:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b7b:	89 04 24             	mov    %eax,(%esp)
  100b7e:	e8 ea 25 00 00       	call   10316d <strcmp>
  100b83:	85 c0                	test   %eax,%eax
  100b85:	75 31                	jne    100bb8 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b87:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b8a:	89 d0                	mov    %edx,%eax
  100b8c:	01 c0                	add    %eax,%eax
  100b8e:	01 d0                	add    %edx,%eax
  100b90:	c1 e0 02             	shl    $0x2,%eax
  100b93:	05 08 f0 10 00       	add    $0x10f008,%eax
  100b98:	8b 10                	mov    (%eax),%edx
  100b9a:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b9d:	83 c0 04             	add    $0x4,%eax
  100ba0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100ba3:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100ba9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bb1:	89 1c 24             	mov    %ebx,(%esp)
  100bb4:	ff d2                	call   *%edx
  100bb6:	eb 23                	jmp    100bdb <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bb8:	ff 45 f4             	incl   -0xc(%ebp)
  100bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bbe:	83 f8 02             	cmp    $0x2,%eax
  100bc1:	76 9e                	jbe    100b61 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bc3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bca:	c7 04 24 97 37 10 00 	movl   $0x103797,(%esp)
  100bd1:	e8 4a f7 ff ff       	call   100320 <cprintf>
    return 0;
  100bd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100bde:	89 ec                	mov    %ebp,%esp
  100be0:	5d                   	pop    %ebp
  100be1:	c3                   	ret    

00100be2 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100be2:	55                   	push   %ebp
  100be3:	89 e5                	mov    %esp,%ebp
  100be5:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100be8:	c7 04 24 b0 37 10 00 	movl   $0x1037b0,(%esp)
  100bef:	e8 2c f7 ff ff       	call   100320 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100bf4:	c7 04 24 d8 37 10 00 	movl   $0x1037d8,(%esp)
  100bfb:	e8 20 f7 ff ff       	call   100320 <cprintf>

    if (tf != NULL) {
  100c00:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c04:	74 0b                	je     100c11 <kmonitor+0x2f>
        print_trapframe(tf);
  100c06:	8b 45 08             	mov    0x8(%ebp),%eax
  100c09:	89 04 24             	mov    %eax,(%esp)
  100c0c:	e8 89 0e 00 00       	call   101a9a <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c11:	c7 04 24 fd 37 10 00 	movl   $0x1037fd,(%esp)
  100c18:	e8 f4 f5 ff ff       	call   100211 <readline>
  100c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c24:	74 eb                	je     100c11 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c26:	8b 45 08             	mov    0x8(%ebp),%eax
  100c29:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c30:	89 04 24             	mov    %eax,(%esp)
  100c33:	e8 f2 fe ff ff       	call   100b2a <runcmd>
  100c38:	85 c0                	test   %eax,%eax
  100c3a:	78 02                	js     100c3e <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c3c:	eb d3                	jmp    100c11 <kmonitor+0x2f>
                break;
  100c3e:	90                   	nop
            }
        }
    }
}
  100c3f:	90                   	nop
  100c40:	89 ec                	mov    %ebp,%esp
  100c42:	5d                   	pop    %ebp
  100c43:	c3                   	ret    

00100c44 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c44:	55                   	push   %ebp
  100c45:	89 e5                	mov    %esp,%ebp
  100c47:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c51:	eb 3d                	jmp    100c90 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c56:	89 d0                	mov    %edx,%eax
  100c58:	01 c0                	add    %eax,%eax
  100c5a:	01 d0                	add    %edx,%eax
  100c5c:	c1 e0 02             	shl    $0x2,%eax
  100c5f:	05 04 f0 10 00       	add    $0x10f004,%eax
  100c64:	8b 10                	mov    (%eax),%edx
  100c66:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c69:	89 c8                	mov    %ecx,%eax
  100c6b:	01 c0                	add    %eax,%eax
  100c6d:	01 c8                	add    %ecx,%eax
  100c6f:	c1 e0 02             	shl    $0x2,%eax
  100c72:	05 00 f0 10 00       	add    $0x10f000,%eax
  100c77:	8b 00                	mov    (%eax),%eax
  100c79:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c81:	c7 04 24 01 38 10 00 	movl   $0x103801,(%esp)
  100c88:	e8 93 f6 ff ff       	call   100320 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c8d:	ff 45 f4             	incl   -0xc(%ebp)
  100c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c93:	83 f8 02             	cmp    $0x2,%eax
  100c96:	76 bb                	jbe    100c53 <mon_help+0xf>
    }
    return 0;
  100c98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c9d:	89 ec                	mov    %ebp,%esp
  100c9f:	5d                   	pop    %ebp
  100ca0:	c3                   	ret    

00100ca1 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100ca1:	55                   	push   %ebp
  100ca2:	89 e5                	mov    %esp,%ebp
  100ca4:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100ca7:	e8 97 fb ff ff       	call   100843 <print_kerninfo>
    return 0;
  100cac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cb1:	89 ec                	mov    %ebp,%esp
  100cb3:	5d                   	pop    %ebp
  100cb4:	c3                   	ret    

00100cb5 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cb5:	55                   	push   %ebp
  100cb6:	89 e5                	mov    %esp,%ebp
  100cb8:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cbb:	e8 cf fc ff ff       	call   10098f <print_stackframe>
    return 0;
  100cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc5:	89 ec                	mov    %ebp,%esp
  100cc7:	5d                   	pop    %ebp
  100cc8:	c3                   	ret    

00100cc9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cc9:	55                   	push   %ebp
  100cca:	89 e5                	mov    %esp,%ebp
  100ccc:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ccf:	a1 40 fe 10 00       	mov    0x10fe40,%eax
  100cd4:	85 c0                	test   %eax,%eax
  100cd6:	75 5b                	jne    100d33 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cd8:	c7 05 40 fe 10 00 01 	movl   $0x1,0x10fe40
  100cdf:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ce2:	8d 45 14             	lea    0x14(%ebp),%eax
  100ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cef:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cf6:	c7 04 24 0a 38 10 00 	movl   $0x10380a,(%esp)
  100cfd:	e8 1e f6 ff ff       	call   100320 <cprintf>
    vcprintf(fmt, ap);
  100d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d09:	8b 45 10             	mov    0x10(%ebp),%eax
  100d0c:	89 04 24             	mov    %eax,(%esp)
  100d0f:	e8 d7 f5 ff ff       	call   1002eb <vcprintf>
    cprintf("\n");
  100d14:	c7 04 24 26 38 10 00 	movl   $0x103826,(%esp)
  100d1b:	e8 00 f6 ff ff       	call   100320 <cprintf>
    
    cprintf("stack trackback:\n");
  100d20:	c7 04 24 28 38 10 00 	movl   $0x103828,(%esp)
  100d27:	e8 f4 f5 ff ff       	call   100320 <cprintf>
    print_stackframe();
  100d2c:	e8 5e fc ff ff       	call   10098f <print_stackframe>
  100d31:	eb 01                	jmp    100d34 <__panic+0x6b>
        goto panic_dead;
  100d33:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d34:	e8 81 09 00 00       	call   1016ba <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d40:	e8 9d fe ff ff       	call   100be2 <kmonitor>
  100d45:	eb f2                	jmp    100d39 <__panic+0x70>

00100d47 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d47:	55                   	push   %ebp
  100d48:	89 e5                	mov    %esp,%ebp
  100d4a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d4d:	8d 45 14             	lea    0x14(%ebp),%eax
  100d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d53:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d56:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  100d5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d61:	c7 04 24 3a 38 10 00 	movl   $0x10383a,(%esp)
  100d68:	e8 b3 f5 ff ff       	call   100320 <cprintf>
    vcprintf(fmt, ap);
  100d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d74:	8b 45 10             	mov    0x10(%ebp),%eax
  100d77:	89 04 24             	mov    %eax,(%esp)
  100d7a:	e8 6c f5 ff ff       	call   1002eb <vcprintf>
    cprintf("\n");
  100d7f:	c7 04 24 26 38 10 00 	movl   $0x103826,(%esp)
  100d86:	e8 95 f5 ff ff       	call   100320 <cprintf>
    va_end(ap);
}
  100d8b:	90                   	nop
  100d8c:	89 ec                	mov    %ebp,%esp
  100d8e:	5d                   	pop    %ebp
  100d8f:	c3                   	ret    

00100d90 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d90:	55                   	push   %ebp
  100d91:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d93:	a1 40 fe 10 00       	mov    0x10fe40,%eax
}
  100d98:	5d                   	pop    %ebp
  100d99:	c3                   	ret    

00100d9a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9a:	55                   	push   %ebp
  100d9b:	89 e5                	mov    %esp,%ebp
  100d9d:	83 ec 28             	sub    $0x28,%esp
  100da0:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100da6:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100daa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dae:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100db2:	ee                   	out    %al,(%dx)
}
  100db3:	90                   	nop
  100db4:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dba:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dbe:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dc6:	ee                   	out    %al,(%dx)
}
  100dc7:	90                   	nop
  100dc8:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dce:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dd2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dd6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dda:	ee                   	out    %al,(%dx)
}
  100ddb:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100ddc:	c7 05 44 fe 10 00 00 	movl   $0x0,0x10fe44
  100de3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100de6:	c7 04 24 58 38 10 00 	movl   $0x103858,(%esp)
  100ded:	e8 2e f5 ff ff       	call   100320 <cprintf>
    pic_enable(IRQ_TIMER);
  100df2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100df9:	e8 21 09 00 00       	call   10171f <pic_enable>
}
  100dfe:	90                   	nop
  100dff:	89 ec                	mov    %ebp,%esp
  100e01:	5d                   	pop    %ebp
  100e02:	c3                   	ret    

00100e03 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e03:	55                   	push   %ebp
  100e04:	89 e5                	mov    %esp,%ebp
  100e06:	83 ec 10             	sub    $0x10,%esp
  100e09:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e0f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e13:	89 c2                	mov    %eax,%edx
  100e15:	ec                   	in     (%dx),%al
  100e16:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e19:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e1f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e23:	89 c2                	mov    %eax,%edx
  100e25:	ec                   	in     (%dx),%al
  100e26:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e29:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e2f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e33:	89 c2                	mov    %eax,%edx
  100e35:	ec                   	in     (%dx),%al
  100e36:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e39:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e3f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e43:	89 c2                	mov    %eax,%edx
  100e45:	ec                   	in     (%dx),%al
  100e46:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e49:	90                   	nop
  100e4a:	89 ec                	mov    %ebp,%esp
  100e4c:	5d                   	pop    %ebp
  100e4d:	c3                   	ret    

00100e4e <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e4e:	55                   	push   %ebp
  100e4f:	89 e5                	mov    %esp,%ebp
  100e51:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e54:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e5e:	0f b7 00             	movzwl (%eax),%eax
  100e61:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e68:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e70:	0f b7 00             	movzwl (%eax),%eax
  100e73:	0f b7 c0             	movzwl %ax,%eax
  100e76:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e7b:	74 12                	je     100e8f <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e7d:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e84:	66 c7 05 66 fe 10 00 	movw   $0x3b4,0x10fe66
  100e8b:	b4 03 
  100e8d:	eb 13                	jmp    100ea2 <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e92:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e96:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e99:	66 c7 05 66 fe 10 00 	movw   $0x3d4,0x10fe66
  100ea0:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100ea2:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ea9:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ead:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eb1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100eb5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100eb9:	ee                   	out    %al,(%dx)
}
  100eba:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100ebb:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ec2:	40                   	inc    %eax
  100ec3:	0f b7 c0             	movzwl %ax,%eax
  100ec6:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100eca:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100ece:	89 c2                	mov    %eax,%edx
  100ed0:	ec                   	in     (%dx),%al
  100ed1:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100ed4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ed8:	0f b6 c0             	movzbl %al,%eax
  100edb:	c1 e0 08             	shl    $0x8,%eax
  100ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ee1:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ee8:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100eec:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ef0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ef4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ef8:	ee                   	out    %al,(%dx)
}
  100ef9:	90                   	nop
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100efa:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f01:	40                   	inc    %eax
  100f02:	0f b7 c0             	movzwl %ax,%eax
  100f05:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f09:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f0d:	89 c2                	mov    %eax,%edx
  100f0f:	ec                   	in     (%dx),%al
  100f10:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f13:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f17:	0f b6 c0             	movzbl %al,%eax
  100f1a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100f1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f20:	a3 60 fe 10 00       	mov    %eax,0x10fe60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f28:	0f b7 c0             	movzwl %ax,%eax
  100f2b:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
}
  100f31:	90                   	nop
  100f32:	89 ec                	mov    %ebp,%esp
  100f34:	5d                   	pop    %ebp
  100f35:	c3                   	ret    

00100f36 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f36:	55                   	push   %ebp
  100f37:	89 e5                	mov    %esp,%ebp
  100f39:	83 ec 48             	sub    $0x48,%esp
  100f3c:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f42:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f46:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f4a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f4e:	ee                   	out    %al,(%dx)
}
  100f4f:	90                   	nop
  100f50:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f56:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f5a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f5e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f62:	ee                   	out    %al,(%dx)
}
  100f63:	90                   	nop
  100f64:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f6a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f6e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f72:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f76:	ee                   	out    %al,(%dx)
}
  100f77:	90                   	nop
  100f78:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f7e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f82:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f86:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f8a:	ee                   	out    %al,(%dx)
}
  100f8b:	90                   	nop
  100f8c:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100f92:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f96:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f9a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f9e:	ee                   	out    %al,(%dx)
}
  100f9f:	90                   	nop
  100fa0:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fa6:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100faa:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fae:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fb2:	ee                   	out    %al,(%dx)
}
  100fb3:	90                   	nop
  100fb4:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fba:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fbe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fc2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fc6:	ee                   	out    %al,(%dx)
}
  100fc7:	90                   	nop
  100fc8:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fce:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100fd2:	89 c2                	mov    %eax,%edx
  100fd4:	ec                   	in     (%dx),%al
  100fd5:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100fd8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fdc:	3c ff                	cmp    $0xff,%al
  100fde:	0f 95 c0             	setne  %al
  100fe1:	0f b6 c0             	movzbl %al,%eax
  100fe4:	a3 68 fe 10 00       	mov    %eax,0x10fe68
  100fe9:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fef:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ff3:	89 c2                	mov    %eax,%edx
  100ff5:	ec                   	in     (%dx),%al
  100ff6:	88 45 f1             	mov    %al,-0xf(%ebp)
  100ff9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  100fff:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101003:	89 c2                	mov    %eax,%edx
  101005:	ec                   	in     (%dx),%al
  101006:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101009:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  10100e:	85 c0                	test   %eax,%eax
  101010:	74 0c                	je     10101e <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  101012:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101019:	e8 01 07 00 00       	call   10171f <pic_enable>
    }
}
  10101e:	90                   	nop
  10101f:	89 ec                	mov    %ebp,%esp
  101021:	5d                   	pop    %ebp
  101022:	c3                   	ret    

00101023 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101023:	55                   	push   %ebp
  101024:	89 e5                	mov    %esp,%ebp
  101026:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101029:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101030:	eb 08                	jmp    10103a <lpt_putc_sub+0x17>
        delay();
  101032:	e8 cc fd ff ff       	call   100e03 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101037:	ff 45 fc             	incl   -0x4(%ebp)
  10103a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101040:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101044:	89 c2                	mov    %eax,%edx
  101046:	ec                   	in     (%dx),%al
  101047:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10104a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10104e:	84 c0                	test   %al,%al
  101050:	78 09                	js     10105b <lpt_putc_sub+0x38>
  101052:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101059:	7e d7                	jle    101032 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  10105b:	8b 45 08             	mov    0x8(%ebp),%eax
  10105e:	0f b6 c0             	movzbl %al,%eax
  101061:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101067:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10106a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10106e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101072:	ee                   	out    %al,(%dx)
}
  101073:	90                   	nop
  101074:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  10107a:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10107e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101082:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101086:	ee                   	out    %al,(%dx)
}
  101087:	90                   	nop
  101088:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  10108e:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101092:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101096:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10109a:	ee                   	out    %al,(%dx)
}
  10109b:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10109c:	90                   	nop
  10109d:	89 ec                	mov    %ebp,%esp
  10109f:	5d                   	pop    %ebp
  1010a0:	c3                   	ret    

001010a1 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010a1:	55                   	push   %ebp
  1010a2:	89 e5                	mov    %esp,%ebp
  1010a4:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010a7:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010ab:	74 0d                	je     1010ba <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b0:	89 04 24             	mov    %eax,(%esp)
  1010b3:	e8 6b ff ff ff       	call   101023 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010b8:	eb 24                	jmp    1010de <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010c1:	e8 5d ff ff ff       	call   101023 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010cd:	e8 51 ff ff ff       	call   101023 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010d2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010d9:	e8 45 ff ff ff       	call   101023 <lpt_putc_sub>
}
  1010de:	90                   	nop
  1010df:	89 ec                	mov    %ebp,%esp
  1010e1:	5d                   	pop    %ebp
  1010e2:	c3                   	ret    

001010e3 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010e3:	55                   	push   %ebp
  1010e4:	89 e5                	mov    %esp,%ebp
  1010e6:	83 ec 38             	sub    $0x38,%esp
  1010e9:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  1010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ef:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010f4:	85 c0                	test   %eax,%eax
  1010f6:	75 07                	jne    1010ff <cga_putc+0x1c>
        c |= 0x0700;
  1010f8:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  101102:	0f b6 c0             	movzbl %al,%eax
  101105:	83 f8 0d             	cmp    $0xd,%eax
  101108:	74 72                	je     10117c <cga_putc+0x99>
  10110a:	83 f8 0d             	cmp    $0xd,%eax
  10110d:	0f 8f a3 00 00 00    	jg     1011b6 <cga_putc+0xd3>
  101113:	83 f8 08             	cmp    $0x8,%eax
  101116:	74 0a                	je     101122 <cga_putc+0x3f>
  101118:	83 f8 0a             	cmp    $0xa,%eax
  10111b:	74 4c                	je     101169 <cga_putc+0x86>
  10111d:	e9 94 00 00 00       	jmp    1011b6 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  101122:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101129:	85 c0                	test   %eax,%eax
  10112b:	0f 84 af 00 00 00    	je     1011e0 <cga_putc+0xfd>
            crt_pos --;
  101131:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101138:	48                   	dec    %eax
  101139:	0f b7 c0             	movzwl %ax,%eax
  10113c:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101142:	8b 45 08             	mov    0x8(%ebp),%eax
  101145:	98                   	cwtl   
  101146:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10114b:	98                   	cwtl   
  10114c:	83 c8 20             	or     $0x20,%eax
  10114f:	98                   	cwtl   
  101150:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  101156:	0f b7 15 64 fe 10 00 	movzwl 0x10fe64,%edx
  10115d:	01 d2                	add    %edx,%edx
  10115f:	01 ca                	add    %ecx,%edx
  101161:	0f b7 c0             	movzwl %ax,%eax
  101164:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101167:	eb 77                	jmp    1011e0 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  101169:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101170:	83 c0 50             	add    $0x50,%eax
  101173:	0f b7 c0             	movzwl %ax,%eax
  101176:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10117c:	0f b7 1d 64 fe 10 00 	movzwl 0x10fe64,%ebx
  101183:	0f b7 0d 64 fe 10 00 	movzwl 0x10fe64,%ecx
  10118a:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  10118f:	89 c8                	mov    %ecx,%eax
  101191:	f7 e2                	mul    %edx
  101193:	c1 ea 06             	shr    $0x6,%edx
  101196:	89 d0                	mov    %edx,%eax
  101198:	c1 e0 02             	shl    $0x2,%eax
  10119b:	01 d0                	add    %edx,%eax
  10119d:	c1 e0 04             	shl    $0x4,%eax
  1011a0:	29 c1                	sub    %eax,%ecx
  1011a2:	89 ca                	mov    %ecx,%edx
  1011a4:	0f b7 d2             	movzwl %dx,%edx
  1011a7:	89 d8                	mov    %ebx,%eax
  1011a9:	29 d0                	sub    %edx,%eax
  1011ab:	0f b7 c0             	movzwl %ax,%eax
  1011ae:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
        break;
  1011b4:	eb 2b                	jmp    1011e1 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011b6:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  1011bc:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011c3:	8d 50 01             	lea    0x1(%eax),%edx
  1011c6:	0f b7 d2             	movzwl %dx,%edx
  1011c9:	66 89 15 64 fe 10 00 	mov    %dx,0x10fe64
  1011d0:	01 c0                	add    %eax,%eax
  1011d2:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1011d8:	0f b7 c0             	movzwl %ax,%eax
  1011db:	66 89 02             	mov    %ax,(%edx)
        break;
  1011de:	eb 01                	jmp    1011e1 <cga_putc+0xfe>
        break;
  1011e0:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e1:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011e8:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011ed:	76 5e                	jbe    10124d <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011ef:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1011f4:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011fa:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1011ff:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101206:	00 
  101207:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120b:	89 04 24             	mov    %eax,(%esp)
  10120e:	e8 f4 21 00 00       	call   103407 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101213:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121a:	eb 15                	jmp    101231 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  10121c:	8b 15 60 fe 10 00    	mov    0x10fe60,%edx
  101222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101225:	01 c0                	add    %eax,%eax
  101227:	01 d0                	add    %edx,%eax
  101229:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10122e:	ff 45 f4             	incl   -0xc(%ebp)
  101231:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101238:	7e e2                	jle    10121c <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  10123a:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101241:	83 e8 50             	sub    $0x50,%eax
  101244:	0f b7 c0             	movzwl %ax,%eax
  101247:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124d:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  101254:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101258:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10125c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101260:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101264:	ee                   	out    %al,(%dx)
}
  101265:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  101266:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10126d:	c1 e8 08             	shr    $0x8,%eax
  101270:	0f b7 c0             	movzwl %ax,%eax
  101273:	0f b6 c0             	movzbl %al,%eax
  101276:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  10127d:	42                   	inc    %edx
  10127e:	0f b7 d2             	movzwl %dx,%edx
  101281:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101285:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101288:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10128c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101290:	ee                   	out    %al,(%dx)
}
  101291:	90                   	nop
    outb(addr_6845, 15);
  101292:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  101299:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10129d:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012a1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012a5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012a9:	ee                   	out    %al,(%dx)
}
  1012aa:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012ab:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1012b2:	0f b6 c0             	movzbl %al,%eax
  1012b5:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  1012bc:	42                   	inc    %edx
  1012bd:	0f b7 d2             	movzwl %dx,%edx
  1012c0:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012c4:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012c7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012cb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012cf:	ee                   	out    %al,(%dx)
}
  1012d0:	90                   	nop
}
  1012d1:	90                   	nop
  1012d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1012d5:	89 ec                	mov    %ebp,%esp
  1012d7:	5d                   	pop    %ebp
  1012d8:	c3                   	ret    

001012d9 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012d9:	55                   	push   %ebp
  1012da:	89 e5                	mov    %esp,%ebp
  1012dc:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e6:	eb 08                	jmp    1012f0 <serial_putc_sub+0x17>
        delay();
  1012e8:	e8 16 fb ff ff       	call   100e03 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012ed:	ff 45 fc             	incl   -0x4(%ebp)
  1012f0:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1012f6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fa:	89 c2                	mov    %eax,%edx
  1012fc:	ec                   	in     (%dx),%al
  1012fd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101300:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101304:	0f b6 c0             	movzbl %al,%eax
  101307:	83 e0 20             	and    $0x20,%eax
  10130a:	85 c0                	test   %eax,%eax
  10130c:	75 09                	jne    101317 <serial_putc_sub+0x3e>
  10130e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101315:	7e d1                	jle    1012e8 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101317:	8b 45 08             	mov    0x8(%ebp),%eax
  10131a:	0f b6 c0             	movzbl %al,%eax
  10131d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101323:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101326:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10132e:	ee                   	out    %al,(%dx)
}
  10132f:	90                   	nop
}
  101330:	90                   	nop
  101331:	89 ec                	mov    %ebp,%esp
  101333:	5d                   	pop    %ebp
  101334:	c3                   	ret    

00101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101335:	55                   	push   %ebp
  101336:	89 e5                	mov    %esp,%ebp
  101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133f:	74 0d                	je     10134e <serial_putc+0x19>
        serial_putc_sub(c);
  101341:	8b 45 08             	mov    0x8(%ebp),%eax
  101344:	89 04 24             	mov    %eax,(%esp)
  101347:	e8 8d ff ff ff       	call   1012d9 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10134c:	eb 24                	jmp    101372 <serial_putc+0x3d>
        serial_putc_sub('\b');
  10134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101355:	e8 7f ff ff ff       	call   1012d9 <serial_putc_sub>
        serial_putc_sub(' ');
  10135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101361:	e8 73 ff ff ff       	call   1012d9 <serial_putc_sub>
        serial_putc_sub('\b');
  101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136d:	e8 67 ff ff ff       	call   1012d9 <serial_putc_sub>
}
  101372:	90                   	nop
  101373:	89 ec                	mov    %ebp,%esp
  101375:	5d                   	pop    %ebp
  101376:	c3                   	ret    

00101377 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101377:	55                   	push   %ebp
  101378:	89 e5                	mov    %esp,%ebp
  10137a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10137d:	eb 33                	jmp    1013b2 <cons_intr+0x3b>
        if (c != 0) {
  10137f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101383:	74 2d                	je     1013b2 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101385:	a1 84 00 11 00       	mov    0x110084,%eax
  10138a:	8d 50 01             	lea    0x1(%eax),%edx
  10138d:	89 15 84 00 11 00    	mov    %edx,0x110084
  101393:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101396:	88 90 80 fe 10 00    	mov    %dl,0x10fe80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10139c:	a1 84 00 11 00       	mov    0x110084,%eax
  1013a1:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a6:	75 0a                	jne    1013b2 <cons_intr+0x3b>
                cons.wpos = 0;
  1013a8:	c7 05 84 00 11 00 00 	movl   $0x0,0x110084
  1013af:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b5:	ff d0                	call   *%eax
  1013b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013be:	75 bf                	jne    10137f <cons_intr+0x8>
            }
        }
    }
}
  1013c0:	90                   	nop
  1013c1:	90                   	nop
  1013c2:	89 ec                	mov    %ebp,%esp
  1013c4:	5d                   	pop    %ebp
  1013c5:	c3                   	ret    

001013c6 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013c6:	55                   	push   %ebp
  1013c7:	89 e5                	mov    %esp,%ebp
  1013c9:	83 ec 10             	sub    $0x10,%esp
  1013cc:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013d2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013d6:	89 c2                	mov    %eax,%edx
  1013d8:	ec                   	in     (%dx),%al
  1013d9:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013dc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013e0:	0f b6 c0             	movzbl %al,%eax
  1013e3:	83 e0 01             	and    $0x1,%eax
  1013e6:	85 c0                	test   %eax,%eax
  1013e8:	75 07                	jne    1013f1 <serial_proc_data+0x2b>
        return -1;
  1013ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013ef:	eb 2a                	jmp    10141b <serial_proc_data+0x55>
  1013f1:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013f7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013fb:	89 c2                	mov    %eax,%edx
  1013fd:	ec                   	in     (%dx),%al
  1013fe:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101401:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101405:	0f b6 c0             	movzbl %al,%eax
  101408:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10140b:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10140f:	75 07                	jne    101418 <serial_proc_data+0x52>
        c = '\b';
  101411:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101418:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10141b:	89 ec                	mov    %ebp,%esp
  10141d:	5d                   	pop    %ebp
  10141e:	c3                   	ret    

0010141f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10141f:	55                   	push   %ebp
  101420:	89 e5                	mov    %esp,%ebp
  101422:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101425:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  10142a:	85 c0                	test   %eax,%eax
  10142c:	74 0c                	je     10143a <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10142e:	c7 04 24 c6 13 10 00 	movl   $0x1013c6,(%esp)
  101435:	e8 3d ff ff ff       	call   101377 <cons_intr>
    }
}
  10143a:	90                   	nop
  10143b:	89 ec                	mov    %ebp,%esp
  10143d:	5d                   	pop    %ebp
  10143e:	c3                   	ret    

0010143f <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10143f:	55                   	push   %ebp
  101440:	89 e5                	mov    %esp,%ebp
  101442:	83 ec 38             	sub    $0x38,%esp
  101445:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10144b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10144e:	89 c2                	mov    %eax,%edx
  101450:	ec                   	in     (%dx),%al
  101451:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101454:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101458:	0f b6 c0             	movzbl %al,%eax
  10145b:	83 e0 01             	and    $0x1,%eax
  10145e:	85 c0                	test   %eax,%eax
  101460:	75 0a                	jne    10146c <kbd_proc_data+0x2d>
        return -1;
  101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101467:	e9 56 01 00 00       	jmp    1015c2 <kbd_proc_data+0x183>
  10146c:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101472:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101475:	89 c2                	mov    %eax,%edx
  101477:	ec                   	in     (%dx),%al
  101478:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10147b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10147f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101482:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101486:	75 17                	jne    10149f <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101488:	a1 88 00 11 00       	mov    0x110088,%eax
  10148d:	83 c8 40             	or     $0x40,%eax
  101490:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  101495:	b8 00 00 00 00       	mov    $0x0,%eax
  10149a:	e9 23 01 00 00       	jmp    1015c2 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  10149f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a3:	84 c0                	test   %al,%al
  1014a5:	79 45                	jns    1014ec <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014a7:	a1 88 00 11 00       	mov    0x110088,%eax
  1014ac:	83 e0 40             	and    $0x40,%eax
  1014af:	85 c0                	test   %eax,%eax
  1014b1:	75 08                	jne    1014bb <kbd_proc_data+0x7c>
  1014b3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b7:	24 7f                	and    $0x7f,%al
  1014b9:	eb 04                	jmp    1014bf <kbd_proc_data+0x80>
  1014bb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bf:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014c2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c6:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  1014cd:	0c 40                	or     $0x40,%al
  1014cf:	0f b6 c0             	movzbl %al,%eax
  1014d2:	f7 d0                	not    %eax
  1014d4:	89 c2                	mov    %eax,%edx
  1014d6:	a1 88 00 11 00       	mov    0x110088,%eax
  1014db:	21 d0                	and    %edx,%eax
  1014dd:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  1014e2:	b8 00 00 00 00       	mov    $0x0,%eax
  1014e7:	e9 d6 00 00 00       	jmp    1015c2 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  1014ec:	a1 88 00 11 00       	mov    0x110088,%eax
  1014f1:	83 e0 40             	and    $0x40,%eax
  1014f4:	85 c0                	test   %eax,%eax
  1014f6:	74 11                	je     101509 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014f8:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014fc:	a1 88 00 11 00       	mov    0x110088,%eax
  101501:	83 e0 bf             	and    $0xffffffbf,%eax
  101504:	a3 88 00 11 00       	mov    %eax,0x110088
    }

    shift |= shiftcode[data];
  101509:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150d:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  101514:	0f b6 d0             	movzbl %al,%edx
  101517:	a1 88 00 11 00       	mov    0x110088,%eax
  10151c:	09 d0                	or     %edx,%eax
  10151e:	a3 88 00 11 00       	mov    %eax,0x110088
    shift ^= togglecode[data];
  101523:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101527:	0f b6 80 40 f1 10 00 	movzbl 0x10f140(%eax),%eax
  10152e:	0f b6 d0             	movzbl %al,%edx
  101531:	a1 88 00 11 00       	mov    0x110088,%eax
  101536:	31 d0                	xor    %edx,%eax
  101538:	a3 88 00 11 00       	mov    %eax,0x110088

    c = charcode[shift & (CTL | SHIFT)][data];
  10153d:	a1 88 00 11 00       	mov    0x110088,%eax
  101542:	83 e0 03             	and    $0x3,%eax
  101545:	8b 14 85 40 f5 10 00 	mov    0x10f540(,%eax,4),%edx
  10154c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101550:	01 d0                	add    %edx,%eax
  101552:	0f b6 00             	movzbl (%eax),%eax
  101555:	0f b6 c0             	movzbl %al,%eax
  101558:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  10155b:	a1 88 00 11 00       	mov    0x110088,%eax
  101560:	83 e0 08             	and    $0x8,%eax
  101563:	85 c0                	test   %eax,%eax
  101565:	74 22                	je     101589 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  101567:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10156b:	7e 0c                	jle    101579 <kbd_proc_data+0x13a>
  10156d:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101571:	7f 06                	jg     101579 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101573:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101577:	eb 10                	jmp    101589 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101579:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10157d:	7e 0a                	jle    101589 <kbd_proc_data+0x14a>
  10157f:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101583:	7f 04                	jg     101589 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  101585:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101589:	a1 88 00 11 00       	mov    0x110088,%eax
  10158e:	f7 d0                	not    %eax
  101590:	83 e0 06             	and    $0x6,%eax
  101593:	85 c0                	test   %eax,%eax
  101595:	75 28                	jne    1015bf <kbd_proc_data+0x180>
  101597:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10159e:	75 1f                	jne    1015bf <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015a0:	c7 04 24 73 38 10 00 	movl   $0x103873,(%esp)
  1015a7:	e8 74 ed ff ff       	call   100320 <cprintf>
  1015ac:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015b2:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1015b6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015bd:	ee                   	out    %al,(%dx)
}
  1015be:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015c2:	89 ec                	mov    %ebp,%esp
  1015c4:	5d                   	pop    %ebp
  1015c5:	c3                   	ret    

001015c6 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015c6:	55                   	push   %ebp
  1015c7:	89 e5                	mov    %esp,%ebp
  1015c9:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015cc:	c7 04 24 3f 14 10 00 	movl   $0x10143f,(%esp)
  1015d3:	e8 9f fd ff ff       	call   101377 <cons_intr>
}
  1015d8:	90                   	nop
  1015d9:	89 ec                	mov    %ebp,%esp
  1015db:	5d                   	pop    %ebp
  1015dc:	c3                   	ret    

001015dd <kbd_init>:

static void
kbd_init(void) {
  1015dd:	55                   	push   %ebp
  1015de:	89 e5                	mov    %esp,%ebp
  1015e0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015e3:	e8 de ff ff ff       	call   1015c6 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015ef:	e8 2b 01 00 00       	call   10171f <pic_enable>
}
  1015f4:	90                   	nop
  1015f5:	89 ec                	mov    %ebp,%esp
  1015f7:	5d                   	pop    %ebp
  1015f8:	c3                   	ret    

001015f9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015f9:	55                   	push   %ebp
  1015fa:	89 e5                	mov    %esp,%ebp
  1015fc:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ff:	e8 4a f8 ff ff       	call   100e4e <cga_init>
    serial_init();
  101604:	e8 2d f9 ff ff       	call   100f36 <serial_init>
    kbd_init();
  101609:	e8 cf ff ff ff       	call   1015dd <kbd_init>
    if (!serial_exists) {
  10160e:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  101613:	85 c0                	test   %eax,%eax
  101615:	75 0c                	jne    101623 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101617:	c7 04 24 7f 38 10 00 	movl   $0x10387f,(%esp)
  10161e:	e8 fd ec ff ff       	call   100320 <cprintf>
    }
}
  101623:	90                   	nop
  101624:	89 ec                	mov    %ebp,%esp
  101626:	5d                   	pop    %ebp
  101627:	c3                   	ret    

00101628 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101628:	55                   	push   %ebp
  101629:	89 e5                	mov    %esp,%ebp
  10162b:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  10162e:	8b 45 08             	mov    0x8(%ebp),%eax
  101631:	89 04 24             	mov    %eax,(%esp)
  101634:	e8 68 fa ff ff       	call   1010a1 <lpt_putc>
    cga_putc(c);
  101639:	8b 45 08             	mov    0x8(%ebp),%eax
  10163c:	89 04 24             	mov    %eax,(%esp)
  10163f:	e8 9f fa ff ff       	call   1010e3 <cga_putc>
    serial_putc(c);
  101644:	8b 45 08             	mov    0x8(%ebp),%eax
  101647:	89 04 24             	mov    %eax,(%esp)
  10164a:	e8 e6 fc ff ff       	call   101335 <serial_putc>
}
  10164f:	90                   	nop
  101650:	89 ec                	mov    %ebp,%esp
  101652:	5d                   	pop    %ebp
  101653:	c3                   	ret    

00101654 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101654:	55                   	push   %ebp
  101655:	89 e5                	mov    %esp,%ebp
  101657:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  10165a:	e8 c0 fd ff ff       	call   10141f <serial_intr>
    kbd_intr();
  10165f:	e8 62 ff ff ff       	call   1015c6 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  101664:	8b 15 80 00 11 00    	mov    0x110080,%edx
  10166a:	a1 84 00 11 00       	mov    0x110084,%eax
  10166f:	39 c2                	cmp    %eax,%edx
  101671:	74 36                	je     1016a9 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  101673:	a1 80 00 11 00       	mov    0x110080,%eax
  101678:	8d 50 01             	lea    0x1(%eax),%edx
  10167b:	89 15 80 00 11 00    	mov    %edx,0x110080
  101681:	0f b6 80 80 fe 10 00 	movzbl 0x10fe80(%eax),%eax
  101688:	0f b6 c0             	movzbl %al,%eax
  10168b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  10168e:	a1 80 00 11 00       	mov    0x110080,%eax
  101693:	3d 00 02 00 00       	cmp    $0x200,%eax
  101698:	75 0a                	jne    1016a4 <cons_getc+0x50>
            cons.rpos = 0;
  10169a:	c7 05 80 00 11 00 00 	movl   $0x0,0x110080
  1016a1:	00 00 00 
        }
        return c;
  1016a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016a7:	eb 05                	jmp    1016ae <cons_getc+0x5a>
    }
    return 0;
  1016a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1016ae:	89 ec                	mov    %ebp,%esp
  1016b0:	5d                   	pop    %ebp
  1016b1:	c3                   	ret    

001016b2 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016b2:	55                   	push   %ebp
  1016b3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016b5:	fb                   	sti    
}
  1016b6:	90                   	nop
    sti();
}
  1016b7:	90                   	nop
  1016b8:	5d                   	pop    %ebp
  1016b9:	c3                   	ret    

001016ba <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016ba:	55                   	push   %ebp
  1016bb:	89 e5                	mov    %esp,%ebp

static inline void
cli(void) {
    asm volatile ("cli");
  1016bd:	fa                   	cli    
}
  1016be:	90                   	nop
    cli();
}
  1016bf:	90                   	nop
  1016c0:	5d                   	pop    %ebp
  1016c1:	c3                   	ret    

001016c2 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016c2:	55                   	push   %ebp
  1016c3:	89 e5                	mov    %esp,%ebp
  1016c5:	83 ec 14             	sub    $0x14,%esp
  1016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1016cb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016d2:	66 a3 50 f5 10 00    	mov    %ax,0x10f550
    if (did_init) {
  1016d8:	a1 8c 00 11 00       	mov    0x11008c,%eax
  1016dd:	85 c0                	test   %eax,%eax
  1016df:	74 39                	je     10171a <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  1016e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016e4:	0f b6 c0             	movzbl %al,%eax
  1016e7:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1016ed:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1016f0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016f4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016f8:	ee                   	out    %al,(%dx)
}
  1016f9:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  1016fa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016fe:	c1 e8 08             	shr    $0x8,%eax
  101701:	0f b7 c0             	movzwl %ax,%eax
  101704:	0f b6 c0             	movzbl %al,%eax
  101707:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10170d:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101710:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101714:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101718:	ee                   	out    %al,(%dx)
}
  101719:	90                   	nop
    }
}
  10171a:	90                   	nop
  10171b:	89 ec                	mov    %ebp,%esp
  10171d:	5d                   	pop    %ebp
  10171e:	c3                   	ret    

0010171f <pic_enable>:

void
pic_enable(unsigned int irq) {
  10171f:	55                   	push   %ebp
  101720:	89 e5                	mov    %esp,%ebp
  101722:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101725:	8b 45 08             	mov    0x8(%ebp),%eax
  101728:	ba 01 00 00 00       	mov    $0x1,%edx
  10172d:	88 c1                	mov    %al,%cl
  10172f:	d3 e2                	shl    %cl,%edx
  101731:	89 d0                	mov    %edx,%eax
  101733:	98                   	cwtl   
  101734:	f7 d0                	not    %eax
  101736:	0f bf d0             	movswl %ax,%edx
  101739:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101740:	98                   	cwtl   
  101741:	21 d0                	and    %edx,%eax
  101743:	98                   	cwtl   
  101744:	0f b7 c0             	movzwl %ax,%eax
  101747:	89 04 24             	mov    %eax,(%esp)
  10174a:	e8 73 ff ff ff       	call   1016c2 <pic_setmask>
}
  10174f:	90                   	nop
  101750:	89 ec                	mov    %ebp,%esp
  101752:	5d                   	pop    %ebp
  101753:	c3                   	ret    

00101754 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101754:	55                   	push   %ebp
  101755:	89 e5                	mov    %esp,%ebp
  101757:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10175a:	c7 05 8c 00 11 00 01 	movl   $0x1,0x11008c
  101761:	00 00 00 
  101764:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  10176a:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10176e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101772:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101776:	ee                   	out    %al,(%dx)
}
  101777:	90                   	nop
  101778:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  10177e:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101782:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101786:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10178a:	ee                   	out    %al,(%dx)
}
  10178b:	90                   	nop
  10178c:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101792:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101796:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10179a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10179e:	ee                   	out    %al,(%dx)
}
  10179f:	90                   	nop
  1017a0:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  1017a6:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017aa:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017ae:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017b2:	ee                   	out    %al,(%dx)
}
  1017b3:	90                   	nop
  1017b4:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017ba:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017be:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017c2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017c6:	ee                   	out    %al,(%dx)
}
  1017c7:	90                   	nop
  1017c8:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017ce:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017d2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017d6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017da:	ee                   	out    %al,(%dx)
}
  1017db:	90                   	nop
  1017dc:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1017e2:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017e6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017ea:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017ee:	ee                   	out    %al,(%dx)
}
  1017ef:	90                   	nop
  1017f0:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1017f6:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017fa:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017fe:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101802:	ee                   	out    %al,(%dx)
}
  101803:	90                   	nop
  101804:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  10180a:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10180e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101812:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101816:	ee                   	out    %al,(%dx)
}
  101817:	90                   	nop
  101818:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10181e:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101822:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101826:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10182a:	ee                   	out    %al,(%dx)
}
  10182b:	90                   	nop
  10182c:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101832:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101836:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10183a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10183e:	ee                   	out    %al,(%dx)
}
  10183f:	90                   	nop
  101840:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101846:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10184a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10184e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101852:	ee                   	out    %al,(%dx)
}
  101853:	90                   	nop
  101854:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  10185a:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10185e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101862:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101866:	ee                   	out    %al,(%dx)
}
  101867:	90                   	nop
  101868:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  10186e:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101872:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101876:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10187a:	ee                   	out    %al,(%dx)
}
  10187b:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10187c:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101883:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101888:	74 0f                	je     101899 <pic_init+0x145>
        pic_setmask(irq_mask);
  10188a:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101891:	89 04 24             	mov    %eax,(%esp)
  101894:	e8 29 fe ff ff       	call   1016c2 <pic_setmask>
    }
}
  101899:	90                   	nop
  10189a:	89 ec                	mov    %ebp,%esp
  10189c:	5d                   	pop    %ebp
  10189d:	c3                   	ret    

0010189e <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10189e:	55                   	push   %ebp
  10189f:	89 e5                	mov    %esp,%ebp
  1018a1:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018a4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018ab:	00 
  1018ac:	c7 04 24 a0 38 10 00 	movl   $0x1038a0,(%esp)
  1018b3:	e8 68 ea ff ff       	call   100320 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018b8:	c7 04 24 aa 38 10 00 	movl   $0x1038aa,(%esp)
  1018bf:	e8 5c ea ff ff       	call   100320 <cprintf>
    panic("EOT: kernel seems ok.");
  1018c4:	c7 44 24 08 b8 38 10 	movl   $0x1038b8,0x8(%esp)
  1018cb:	00 
  1018cc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018d3:	00 
  1018d4:	c7 04 24 ce 38 10 00 	movl   $0x1038ce,(%esp)
  1018db:	e8 e9 f3 ff ff       	call   100cc9 <__panic>

001018e0 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018e0:	55                   	push   %ebp
  1018e1:	89 e5                	mov    %esp,%ebp
  1018e3:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */

     extern uintptr_t __vectors[];
     int i;
     for(i=0;i<256;i++)
  1018e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018ed:	e9 c4 00 00 00       	jmp    1019b6 <idt_init+0xd6>
     {
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
  1018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f5:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1018fc:	0f b7 d0             	movzwl %ax,%edx
  1018ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101902:	66 89 14 c5 a0 00 11 	mov    %dx,0x1100a0(,%eax,8)
  101909:	00 
  10190a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190d:	66 c7 04 c5 a2 00 11 	movw   $0x8,0x1100a2(,%eax,8)
  101914:	00 08 00 
  101917:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191a:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101921:	00 
  101922:	80 e2 e0             	and    $0xe0,%dl
  101925:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  10192c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192f:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101936:	00 
  101937:	80 e2 1f             	and    $0x1f,%dl
  10193a:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101941:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101944:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  10194b:	00 
  10194c:	80 e2 f0             	and    $0xf0,%dl
  10194f:	80 ca 0e             	or     $0xe,%dl
  101952:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101959:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10195c:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101963:	00 
  101964:	80 e2 ef             	and    $0xef,%dl
  101967:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  10196e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101971:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101978:	00 
  101979:	80 e2 9f             	and    $0x9f,%dl
  10197c:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101983:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101986:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  10198d:	00 
  10198e:	80 ca 80             	or     $0x80,%dl
  101991:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101998:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199b:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1019a2:	c1 e8 10             	shr    $0x10,%eax
  1019a5:	0f b7 d0             	movzwl %ax,%edx
  1019a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ab:	66 89 14 c5 a6 00 11 	mov    %dx,0x1100a6(,%eax,8)
  1019b2:	00 
     for(i=0;i<256;i++)
  1019b3:	ff 45 fc             	incl   -0x4(%ebp)
  1019b6:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  1019bd:	0f 8e 2f ff ff ff    	jle    1018f2 <idt_init+0x12>
     }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], 3);
  1019c3:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  1019c8:	0f b7 c0             	movzwl %ax,%eax
  1019cb:	66 a3 68 04 11 00    	mov    %ax,0x110468
  1019d1:	66 c7 05 6a 04 11 00 	movw   $0x8,0x11046a
  1019d8:	08 00 
  1019da:	0f b6 05 6c 04 11 00 	movzbl 0x11046c,%eax
  1019e1:	24 e0                	and    $0xe0,%al
  1019e3:	a2 6c 04 11 00       	mov    %al,0x11046c
  1019e8:	0f b6 05 6c 04 11 00 	movzbl 0x11046c,%eax
  1019ef:	24 1f                	and    $0x1f,%al
  1019f1:	a2 6c 04 11 00       	mov    %al,0x11046c
  1019f6:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  1019fd:	24 f0                	and    $0xf0,%al
  1019ff:	0c 0e                	or     $0xe,%al
  101a01:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a06:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a0d:	24 ef                	and    $0xef,%al
  101a0f:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a14:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a1b:	0c 60                	or     $0x60,%al
  101a1d:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a22:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a29:	0c 80                	or     $0x80,%al
  101a2b:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a30:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  101a35:	c1 e8 10             	shr    $0x10,%eax
  101a38:	0f b7 c0             	movzwl %ax,%eax
  101a3b:	66 a3 6e 04 11 00    	mov    %ax,0x11046e
  101a41:	c7 45 f8 60 f5 10 00 	movl   $0x10f560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101a48:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a4b:	0f 01 18             	lidtl  (%eax)
}
  101a4e:	90                   	nop





}
  101a4f:	90                   	nop
  101a50:	89 ec                	mov    %ebp,%esp
  101a52:	5d                   	pop    %ebp
  101a53:	c3                   	ret    

00101a54 <trapname>:

static const char *
trapname(int trapno) {
  101a54:	55                   	push   %ebp
  101a55:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a57:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5a:	83 f8 13             	cmp    $0x13,%eax
  101a5d:	77 0c                	ja     101a6b <trapname+0x17>
        return excnames[trapno];
  101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a62:	8b 04 85 20 3c 10 00 	mov    0x103c20(,%eax,4),%eax
  101a69:	eb 18                	jmp    101a83 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a6b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a6f:	7e 0d                	jle    101a7e <trapname+0x2a>
  101a71:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a75:	7f 07                	jg     101a7e <trapname+0x2a>
        return "Hardware Interrupt";
  101a77:	b8 df 38 10 00       	mov    $0x1038df,%eax
  101a7c:	eb 05                	jmp    101a83 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a7e:	b8 f2 38 10 00       	mov    $0x1038f2,%eax
}
  101a83:	5d                   	pop    %ebp
  101a84:	c3                   	ret    

00101a85 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a85:	55                   	push   %ebp
  101a86:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a88:	8b 45 08             	mov    0x8(%ebp),%eax
  101a8b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a8f:	83 f8 08             	cmp    $0x8,%eax
  101a92:	0f 94 c0             	sete   %al
  101a95:	0f b6 c0             	movzbl %al,%eax
}
  101a98:	5d                   	pop    %ebp
  101a99:	c3                   	ret    

00101a9a <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a9a:	55                   	push   %ebp
  101a9b:	89 e5                	mov    %esp,%ebp
  101a9d:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa7:	c7 04 24 33 39 10 00 	movl   $0x103933,(%esp)
  101aae:	e8 6d e8 ff ff       	call   100320 <cprintf>
    print_regs(&tf->tf_regs);
  101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab6:	89 04 24             	mov    %eax,(%esp)
  101ab9:	e8 8f 01 00 00       	call   101c4d <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101abe:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac1:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac9:	c7 04 24 44 39 10 00 	movl   $0x103944,(%esp)
  101ad0:	e8 4b e8 ff ff       	call   100320 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad8:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae0:	c7 04 24 57 39 10 00 	movl   $0x103957,(%esp)
  101ae7:	e8 34 e8 ff ff       	call   100320 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aec:	8b 45 08             	mov    0x8(%ebp),%eax
  101aef:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af7:	c7 04 24 6a 39 10 00 	movl   $0x10396a,(%esp)
  101afe:	e8 1d e8 ff ff       	call   100320 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b03:	8b 45 08             	mov    0x8(%ebp),%eax
  101b06:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0e:	c7 04 24 7d 39 10 00 	movl   $0x10397d,(%esp)
  101b15:	e8 06 e8 ff ff       	call   100320 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1d:	8b 40 30             	mov    0x30(%eax),%eax
  101b20:	89 04 24             	mov    %eax,(%esp)
  101b23:	e8 2c ff ff ff       	call   101a54 <trapname>
  101b28:	8b 55 08             	mov    0x8(%ebp),%edx
  101b2b:	8b 52 30             	mov    0x30(%edx),%edx
  101b2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b32:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b36:	c7 04 24 90 39 10 00 	movl   $0x103990,(%esp)
  101b3d:	e8 de e7 ff ff       	call   100320 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b42:	8b 45 08             	mov    0x8(%ebp),%eax
  101b45:	8b 40 34             	mov    0x34(%eax),%eax
  101b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4c:	c7 04 24 a2 39 10 00 	movl   $0x1039a2,(%esp)
  101b53:	e8 c8 e7 ff ff       	call   100320 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	8b 40 38             	mov    0x38(%eax),%eax
  101b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b62:	c7 04 24 b1 39 10 00 	movl   $0x1039b1,(%esp)
  101b69:	e8 b2 e7 ff ff       	call   100320 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b71:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b79:	c7 04 24 c0 39 10 00 	movl   $0x1039c0,(%esp)
  101b80:	e8 9b e7 ff ff       	call   100320 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b85:	8b 45 08             	mov    0x8(%ebp),%eax
  101b88:	8b 40 40             	mov    0x40(%eax),%eax
  101b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8f:	c7 04 24 d3 39 10 00 	movl   $0x1039d3,(%esp)
  101b96:	e8 85 e7 ff ff       	call   100320 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ba2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ba9:	eb 3d                	jmp    101be8 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101bab:	8b 45 08             	mov    0x8(%ebp),%eax
  101bae:	8b 50 40             	mov    0x40(%eax),%edx
  101bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bb4:	21 d0                	and    %edx,%eax
  101bb6:	85 c0                	test   %eax,%eax
  101bb8:	74 28                	je     101be2 <print_trapframe+0x148>
  101bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bbd:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101bc4:	85 c0                	test   %eax,%eax
  101bc6:	74 1a                	je     101be2 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bcb:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd6:	c7 04 24 e2 39 10 00 	movl   $0x1039e2,(%esp)
  101bdd:	e8 3e e7 ff ff       	call   100320 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101be2:	ff 45 f4             	incl   -0xc(%ebp)
  101be5:	d1 65 f0             	shll   -0x10(%ebp)
  101be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101beb:	83 f8 17             	cmp    $0x17,%eax
  101bee:	76 bb                	jbe    101bab <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf3:	8b 40 40             	mov    0x40(%eax),%eax
  101bf6:	c1 e8 0c             	shr    $0xc,%eax
  101bf9:	83 e0 03             	and    $0x3,%eax
  101bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c00:	c7 04 24 e6 39 10 00 	movl   $0x1039e6,(%esp)
  101c07:	e8 14 e7 ff ff       	call   100320 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0f:	89 04 24             	mov    %eax,(%esp)
  101c12:	e8 6e fe ff ff       	call   101a85 <trap_in_kernel>
  101c17:	85 c0                	test   %eax,%eax
  101c19:	75 2d                	jne    101c48 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1e:	8b 40 44             	mov    0x44(%eax),%eax
  101c21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c25:	c7 04 24 ef 39 10 00 	movl   $0x1039ef,(%esp)
  101c2c:	e8 ef e6 ff ff       	call   100320 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c31:	8b 45 08             	mov    0x8(%ebp),%eax
  101c34:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3c:	c7 04 24 fe 39 10 00 	movl   $0x1039fe,(%esp)
  101c43:	e8 d8 e6 ff ff       	call   100320 <cprintf>
    }
}
  101c48:	90                   	nop
  101c49:	89 ec                	mov    %ebp,%esp
  101c4b:	5d                   	pop    %ebp
  101c4c:	c3                   	ret    

00101c4d <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c4d:	55                   	push   %ebp
  101c4e:	89 e5                	mov    %esp,%ebp
  101c50:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c53:	8b 45 08             	mov    0x8(%ebp),%eax
  101c56:	8b 00                	mov    (%eax),%eax
  101c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5c:	c7 04 24 11 3a 10 00 	movl   $0x103a11,(%esp)
  101c63:	e8 b8 e6 ff ff       	call   100320 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c68:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6b:	8b 40 04             	mov    0x4(%eax),%eax
  101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c72:	c7 04 24 20 3a 10 00 	movl   $0x103a20,(%esp)
  101c79:	e8 a2 e6 ff ff       	call   100320 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c81:	8b 40 08             	mov    0x8(%eax),%eax
  101c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c88:	c7 04 24 2f 3a 10 00 	movl   $0x103a2f,(%esp)
  101c8f:	e8 8c e6 ff ff       	call   100320 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c94:	8b 45 08             	mov    0x8(%ebp),%eax
  101c97:	8b 40 0c             	mov    0xc(%eax),%eax
  101c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9e:	c7 04 24 3e 3a 10 00 	movl   $0x103a3e,(%esp)
  101ca5:	e8 76 e6 ff ff       	call   100320 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101caa:	8b 45 08             	mov    0x8(%ebp),%eax
  101cad:	8b 40 10             	mov    0x10(%eax),%eax
  101cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb4:	c7 04 24 4d 3a 10 00 	movl   $0x103a4d,(%esp)
  101cbb:	e8 60 e6 ff ff       	call   100320 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc3:	8b 40 14             	mov    0x14(%eax),%eax
  101cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cca:	c7 04 24 5c 3a 10 00 	movl   $0x103a5c,(%esp)
  101cd1:	e8 4a e6 ff ff       	call   100320 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd9:	8b 40 18             	mov    0x18(%eax),%eax
  101cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce0:	c7 04 24 6b 3a 10 00 	movl   $0x103a6b,(%esp)
  101ce7:	e8 34 e6 ff ff       	call   100320 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cec:	8b 45 08             	mov    0x8(%ebp),%eax
  101cef:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf6:	c7 04 24 7a 3a 10 00 	movl   $0x103a7a,(%esp)
  101cfd:	e8 1e e6 ff ff       	call   100320 <cprintf>
}
  101d02:	90                   	nop
  101d03:	89 ec                	mov    %ebp,%esp
  101d05:	5d                   	pop    %ebp
  101d06:	c3                   	ret    

00101d07 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d07:	55                   	push   %ebp
  101d08:	89 e5                	mov    %esp,%ebp
  101d0a:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  101d10:	8b 40 30             	mov    0x30(%eax),%eax
  101d13:	83 f8 79             	cmp    $0x79,%eax
  101d16:	0f 87 e6 00 00 00    	ja     101e02 <trap_dispatch+0xfb>
  101d1c:	83 f8 78             	cmp    $0x78,%eax
  101d1f:	0f 83 c1 00 00 00    	jae    101de6 <trap_dispatch+0xdf>
  101d25:	83 f8 2f             	cmp    $0x2f,%eax
  101d28:	0f 87 d4 00 00 00    	ja     101e02 <trap_dispatch+0xfb>
  101d2e:	83 f8 2e             	cmp    $0x2e,%eax
  101d31:	0f 83 00 01 00 00    	jae    101e37 <trap_dispatch+0x130>
  101d37:	83 f8 24             	cmp    $0x24,%eax
  101d3a:	74 5e                	je     101d9a <trap_dispatch+0x93>
  101d3c:	83 f8 24             	cmp    $0x24,%eax
  101d3f:	0f 87 bd 00 00 00    	ja     101e02 <trap_dispatch+0xfb>
  101d45:	83 f8 20             	cmp    $0x20,%eax
  101d48:	74 0a                	je     101d54 <trap_dispatch+0x4d>
  101d4a:	83 f8 21             	cmp    $0x21,%eax
  101d4d:	74 71                	je     101dc0 <trap_dispatch+0xb9>
  101d4f:	e9 ae 00 00 00       	jmp    101e02 <trap_dispatch+0xfb>
    case IRQ_OFFSET + IRQ_TIMER:
        ticks+=1;
  101d54:	a1 44 fe 10 00       	mov    0x10fe44,%eax
  101d59:	40                   	inc    %eax
  101d5a:	a3 44 fe 10 00       	mov    %eax,0x10fe44
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        if (ticks % TICK_NUM == 0) {
  101d5f:	8b 0d 44 fe 10 00    	mov    0x10fe44,%ecx
  101d65:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d6a:	89 c8                	mov    %ecx,%eax
  101d6c:	f7 e2                	mul    %edx
  101d6e:	c1 ea 05             	shr    $0x5,%edx
  101d71:	89 d0                	mov    %edx,%eax
  101d73:	c1 e0 02             	shl    $0x2,%eax
  101d76:	01 d0                	add    %edx,%eax
  101d78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d7f:	01 d0                	add    %edx,%eax
  101d81:	c1 e0 02             	shl    $0x2,%eax
  101d84:	29 c1                	sub    %eax,%ecx
  101d86:	89 ca                	mov    %ecx,%edx
  101d88:	85 d2                	test   %edx,%edx
  101d8a:	0f 85 aa 00 00 00    	jne    101e3a <trap_dispatch+0x133>
            print_ticks();
  101d90:	e8 09 fb ff ff       	call   10189e <print_ticks>
        }
        break;
  101d95:	e9 a0 00 00 00       	jmp    101e3a <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d9a:	e8 b5 f8 ff ff       	call   101654 <cons_getc>
  101d9f:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101da2:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101da6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101daa:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dae:	89 44 24 04          	mov    %eax,0x4(%esp)
  101db2:	c7 04 24 89 3a 10 00 	movl   $0x103a89,(%esp)
  101db9:	e8 62 e5 ff ff       	call   100320 <cprintf>
        break;
  101dbe:	eb 7b                	jmp    101e3b <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101dc0:	e8 8f f8 ff ff       	call   101654 <cons_getc>
  101dc5:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101dc8:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101dcc:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dd0:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dd8:	c7 04 24 9b 3a 10 00 	movl   $0x103a9b,(%esp)
  101ddf:	e8 3c e5 ff ff       	call   100320 <cprintf>
        break;
  101de4:	eb 55                	jmp    101e3b <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101de6:	c7 44 24 08 aa 3a 10 	movl   $0x103aaa,0x8(%esp)
  101ded:	00 
  101dee:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101df5:	00 
  101df6:	c7 04 24 ce 38 10 00 	movl   $0x1038ce,(%esp)
  101dfd:	e8 c7 ee ff ff       	call   100cc9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e02:	8b 45 08             	mov    0x8(%ebp),%eax
  101e05:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e09:	83 e0 03             	and    $0x3,%eax
  101e0c:	85 c0                	test   %eax,%eax
  101e0e:	75 2b                	jne    101e3b <trap_dispatch+0x134>
            print_trapframe(tf);
  101e10:	8b 45 08             	mov    0x8(%ebp),%eax
  101e13:	89 04 24             	mov    %eax,(%esp)
  101e16:	e8 7f fc ff ff       	call   101a9a <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e1b:	c7 44 24 08 ba 3a 10 	movl   $0x103aba,0x8(%esp)
  101e22:	00 
  101e23:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
  101e2a:	00 
  101e2b:	c7 04 24 ce 38 10 00 	movl   $0x1038ce,(%esp)
  101e32:	e8 92 ee ff ff       	call   100cc9 <__panic>
        break;
  101e37:	90                   	nop
  101e38:	eb 01                	jmp    101e3b <trap_dispatch+0x134>
        break;
  101e3a:	90                   	nop
        }
    }
}
  101e3b:	90                   	nop
  101e3c:	89 ec                	mov    %ebp,%esp
  101e3e:	5d                   	pop    %ebp
  101e3f:	c3                   	ret    

00101e40 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e40:	55                   	push   %ebp
  101e41:	89 e5                	mov    %esp,%ebp
  101e43:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e46:	8b 45 08             	mov    0x8(%ebp),%eax
  101e49:	89 04 24             	mov    %eax,(%esp)
  101e4c:	e8 b6 fe ff ff       	call   101d07 <trap_dispatch>
    


}
  101e51:	90                   	nop
  101e52:	89 ec                	mov    %ebp,%esp
  101e54:	5d                   	pop    %ebp
  101e55:	c3                   	ret    

00101e56 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101e56:	1e                   	push   %ds
    pushl %es
  101e57:	06                   	push   %es
    pushl %fs
  101e58:	0f a0                	push   %fs
    pushl %gs
  101e5a:	0f a8                	push   %gs
    pushal
  101e5c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101e5d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101e62:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101e64:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101e66:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101e67:	e8 d4 ff ff ff       	call   101e40 <trap>

    # pop the pushed stack pointer
    popl %esp
  101e6c:	5c                   	pop    %esp

00101e6d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101e6d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101e6e:	0f a9                	pop    %gs
    popl %fs
  101e70:	0f a1                	pop    %fs
    popl %es
  101e72:	07                   	pop    %es
    popl %ds
  101e73:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101e74:	83 c4 08             	add    $0x8,%esp
    iret
  101e77:	cf                   	iret   

00101e78 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e78:	6a 00                	push   $0x0
  pushl $0
  101e7a:	6a 00                	push   $0x0
  jmp __alltraps
  101e7c:	e9 d5 ff ff ff       	jmp    101e56 <__alltraps>

00101e81 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e81:	6a 00                	push   $0x0
  pushl $1
  101e83:	6a 01                	push   $0x1
  jmp __alltraps
  101e85:	e9 cc ff ff ff       	jmp    101e56 <__alltraps>

00101e8a <vector2>:
.globl vector2
vector2:
  pushl $0
  101e8a:	6a 00                	push   $0x0
  pushl $2
  101e8c:	6a 02                	push   $0x2
  jmp __alltraps
  101e8e:	e9 c3 ff ff ff       	jmp    101e56 <__alltraps>

00101e93 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e93:	6a 00                	push   $0x0
  pushl $3
  101e95:	6a 03                	push   $0x3
  jmp __alltraps
  101e97:	e9 ba ff ff ff       	jmp    101e56 <__alltraps>

00101e9c <vector4>:
.globl vector4
vector4:
  pushl $0
  101e9c:	6a 00                	push   $0x0
  pushl $4
  101e9e:	6a 04                	push   $0x4
  jmp __alltraps
  101ea0:	e9 b1 ff ff ff       	jmp    101e56 <__alltraps>

00101ea5 <vector5>:
.globl vector5
vector5:
  pushl $0
  101ea5:	6a 00                	push   $0x0
  pushl $5
  101ea7:	6a 05                	push   $0x5
  jmp __alltraps
  101ea9:	e9 a8 ff ff ff       	jmp    101e56 <__alltraps>

00101eae <vector6>:
.globl vector6
vector6:
  pushl $0
  101eae:	6a 00                	push   $0x0
  pushl $6
  101eb0:	6a 06                	push   $0x6
  jmp __alltraps
  101eb2:	e9 9f ff ff ff       	jmp    101e56 <__alltraps>

00101eb7 <vector7>:
.globl vector7
vector7:
  pushl $0
  101eb7:	6a 00                	push   $0x0
  pushl $7
  101eb9:	6a 07                	push   $0x7
  jmp __alltraps
  101ebb:	e9 96 ff ff ff       	jmp    101e56 <__alltraps>

00101ec0 <vector8>:
.globl vector8
vector8:
  pushl $8
  101ec0:	6a 08                	push   $0x8
  jmp __alltraps
  101ec2:	e9 8f ff ff ff       	jmp    101e56 <__alltraps>

00101ec7 <vector9>:
.globl vector9
vector9:
  pushl $0
  101ec7:	6a 00                	push   $0x0
  pushl $9
  101ec9:	6a 09                	push   $0x9
  jmp __alltraps
  101ecb:	e9 86 ff ff ff       	jmp    101e56 <__alltraps>

00101ed0 <vector10>:
.globl vector10
vector10:
  pushl $10
  101ed0:	6a 0a                	push   $0xa
  jmp __alltraps
  101ed2:	e9 7f ff ff ff       	jmp    101e56 <__alltraps>

00101ed7 <vector11>:
.globl vector11
vector11:
  pushl $11
  101ed7:	6a 0b                	push   $0xb
  jmp __alltraps
  101ed9:	e9 78 ff ff ff       	jmp    101e56 <__alltraps>

00101ede <vector12>:
.globl vector12
vector12:
  pushl $12
  101ede:	6a 0c                	push   $0xc
  jmp __alltraps
  101ee0:	e9 71 ff ff ff       	jmp    101e56 <__alltraps>

00101ee5 <vector13>:
.globl vector13
vector13:
  pushl $13
  101ee5:	6a 0d                	push   $0xd
  jmp __alltraps
  101ee7:	e9 6a ff ff ff       	jmp    101e56 <__alltraps>

00101eec <vector14>:
.globl vector14
vector14:
  pushl $14
  101eec:	6a 0e                	push   $0xe
  jmp __alltraps
  101eee:	e9 63 ff ff ff       	jmp    101e56 <__alltraps>

00101ef3 <vector15>:
.globl vector15
vector15:
  pushl $0
  101ef3:	6a 00                	push   $0x0
  pushl $15
  101ef5:	6a 0f                	push   $0xf
  jmp __alltraps
  101ef7:	e9 5a ff ff ff       	jmp    101e56 <__alltraps>

00101efc <vector16>:
.globl vector16
vector16:
  pushl $0
  101efc:	6a 00                	push   $0x0
  pushl $16
  101efe:	6a 10                	push   $0x10
  jmp __alltraps
  101f00:	e9 51 ff ff ff       	jmp    101e56 <__alltraps>

00101f05 <vector17>:
.globl vector17
vector17:
  pushl $17
  101f05:	6a 11                	push   $0x11
  jmp __alltraps
  101f07:	e9 4a ff ff ff       	jmp    101e56 <__alltraps>

00101f0c <vector18>:
.globl vector18
vector18:
  pushl $0
  101f0c:	6a 00                	push   $0x0
  pushl $18
  101f0e:	6a 12                	push   $0x12
  jmp __alltraps
  101f10:	e9 41 ff ff ff       	jmp    101e56 <__alltraps>

00101f15 <vector19>:
.globl vector19
vector19:
  pushl $0
  101f15:	6a 00                	push   $0x0
  pushl $19
  101f17:	6a 13                	push   $0x13
  jmp __alltraps
  101f19:	e9 38 ff ff ff       	jmp    101e56 <__alltraps>

00101f1e <vector20>:
.globl vector20
vector20:
  pushl $0
  101f1e:	6a 00                	push   $0x0
  pushl $20
  101f20:	6a 14                	push   $0x14
  jmp __alltraps
  101f22:	e9 2f ff ff ff       	jmp    101e56 <__alltraps>

00101f27 <vector21>:
.globl vector21
vector21:
  pushl $0
  101f27:	6a 00                	push   $0x0
  pushl $21
  101f29:	6a 15                	push   $0x15
  jmp __alltraps
  101f2b:	e9 26 ff ff ff       	jmp    101e56 <__alltraps>

00101f30 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f30:	6a 00                	push   $0x0
  pushl $22
  101f32:	6a 16                	push   $0x16
  jmp __alltraps
  101f34:	e9 1d ff ff ff       	jmp    101e56 <__alltraps>

00101f39 <vector23>:
.globl vector23
vector23:
  pushl $0
  101f39:	6a 00                	push   $0x0
  pushl $23
  101f3b:	6a 17                	push   $0x17
  jmp __alltraps
  101f3d:	e9 14 ff ff ff       	jmp    101e56 <__alltraps>

00101f42 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f42:	6a 00                	push   $0x0
  pushl $24
  101f44:	6a 18                	push   $0x18
  jmp __alltraps
  101f46:	e9 0b ff ff ff       	jmp    101e56 <__alltraps>

00101f4b <vector25>:
.globl vector25
vector25:
  pushl $0
  101f4b:	6a 00                	push   $0x0
  pushl $25
  101f4d:	6a 19                	push   $0x19
  jmp __alltraps
  101f4f:	e9 02 ff ff ff       	jmp    101e56 <__alltraps>

00101f54 <vector26>:
.globl vector26
vector26:
  pushl $0
  101f54:	6a 00                	push   $0x0
  pushl $26
  101f56:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f58:	e9 f9 fe ff ff       	jmp    101e56 <__alltraps>

00101f5d <vector27>:
.globl vector27
vector27:
  pushl $0
  101f5d:	6a 00                	push   $0x0
  pushl $27
  101f5f:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f61:	e9 f0 fe ff ff       	jmp    101e56 <__alltraps>

00101f66 <vector28>:
.globl vector28
vector28:
  pushl $0
  101f66:	6a 00                	push   $0x0
  pushl $28
  101f68:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f6a:	e9 e7 fe ff ff       	jmp    101e56 <__alltraps>

00101f6f <vector29>:
.globl vector29
vector29:
  pushl $0
  101f6f:	6a 00                	push   $0x0
  pushl $29
  101f71:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f73:	e9 de fe ff ff       	jmp    101e56 <__alltraps>

00101f78 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f78:	6a 00                	push   $0x0
  pushl $30
  101f7a:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f7c:	e9 d5 fe ff ff       	jmp    101e56 <__alltraps>

00101f81 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f81:	6a 00                	push   $0x0
  pushl $31
  101f83:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f85:	e9 cc fe ff ff       	jmp    101e56 <__alltraps>

00101f8a <vector32>:
.globl vector32
vector32:
  pushl $0
  101f8a:	6a 00                	push   $0x0
  pushl $32
  101f8c:	6a 20                	push   $0x20
  jmp __alltraps
  101f8e:	e9 c3 fe ff ff       	jmp    101e56 <__alltraps>

00101f93 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f93:	6a 00                	push   $0x0
  pushl $33
  101f95:	6a 21                	push   $0x21
  jmp __alltraps
  101f97:	e9 ba fe ff ff       	jmp    101e56 <__alltraps>

00101f9c <vector34>:
.globl vector34
vector34:
  pushl $0
  101f9c:	6a 00                	push   $0x0
  pushl $34
  101f9e:	6a 22                	push   $0x22
  jmp __alltraps
  101fa0:	e9 b1 fe ff ff       	jmp    101e56 <__alltraps>

00101fa5 <vector35>:
.globl vector35
vector35:
  pushl $0
  101fa5:	6a 00                	push   $0x0
  pushl $35
  101fa7:	6a 23                	push   $0x23
  jmp __alltraps
  101fa9:	e9 a8 fe ff ff       	jmp    101e56 <__alltraps>

00101fae <vector36>:
.globl vector36
vector36:
  pushl $0
  101fae:	6a 00                	push   $0x0
  pushl $36
  101fb0:	6a 24                	push   $0x24
  jmp __alltraps
  101fb2:	e9 9f fe ff ff       	jmp    101e56 <__alltraps>

00101fb7 <vector37>:
.globl vector37
vector37:
  pushl $0
  101fb7:	6a 00                	push   $0x0
  pushl $37
  101fb9:	6a 25                	push   $0x25
  jmp __alltraps
  101fbb:	e9 96 fe ff ff       	jmp    101e56 <__alltraps>

00101fc0 <vector38>:
.globl vector38
vector38:
  pushl $0
  101fc0:	6a 00                	push   $0x0
  pushl $38
  101fc2:	6a 26                	push   $0x26
  jmp __alltraps
  101fc4:	e9 8d fe ff ff       	jmp    101e56 <__alltraps>

00101fc9 <vector39>:
.globl vector39
vector39:
  pushl $0
  101fc9:	6a 00                	push   $0x0
  pushl $39
  101fcb:	6a 27                	push   $0x27
  jmp __alltraps
  101fcd:	e9 84 fe ff ff       	jmp    101e56 <__alltraps>

00101fd2 <vector40>:
.globl vector40
vector40:
  pushl $0
  101fd2:	6a 00                	push   $0x0
  pushl $40
  101fd4:	6a 28                	push   $0x28
  jmp __alltraps
  101fd6:	e9 7b fe ff ff       	jmp    101e56 <__alltraps>

00101fdb <vector41>:
.globl vector41
vector41:
  pushl $0
  101fdb:	6a 00                	push   $0x0
  pushl $41
  101fdd:	6a 29                	push   $0x29
  jmp __alltraps
  101fdf:	e9 72 fe ff ff       	jmp    101e56 <__alltraps>

00101fe4 <vector42>:
.globl vector42
vector42:
  pushl $0
  101fe4:	6a 00                	push   $0x0
  pushl $42
  101fe6:	6a 2a                	push   $0x2a
  jmp __alltraps
  101fe8:	e9 69 fe ff ff       	jmp    101e56 <__alltraps>

00101fed <vector43>:
.globl vector43
vector43:
  pushl $0
  101fed:	6a 00                	push   $0x0
  pushl $43
  101fef:	6a 2b                	push   $0x2b
  jmp __alltraps
  101ff1:	e9 60 fe ff ff       	jmp    101e56 <__alltraps>

00101ff6 <vector44>:
.globl vector44
vector44:
  pushl $0
  101ff6:	6a 00                	push   $0x0
  pushl $44
  101ff8:	6a 2c                	push   $0x2c
  jmp __alltraps
  101ffa:	e9 57 fe ff ff       	jmp    101e56 <__alltraps>

00101fff <vector45>:
.globl vector45
vector45:
  pushl $0
  101fff:	6a 00                	push   $0x0
  pushl $45
  102001:	6a 2d                	push   $0x2d
  jmp __alltraps
  102003:	e9 4e fe ff ff       	jmp    101e56 <__alltraps>

00102008 <vector46>:
.globl vector46
vector46:
  pushl $0
  102008:	6a 00                	push   $0x0
  pushl $46
  10200a:	6a 2e                	push   $0x2e
  jmp __alltraps
  10200c:	e9 45 fe ff ff       	jmp    101e56 <__alltraps>

00102011 <vector47>:
.globl vector47
vector47:
  pushl $0
  102011:	6a 00                	push   $0x0
  pushl $47
  102013:	6a 2f                	push   $0x2f
  jmp __alltraps
  102015:	e9 3c fe ff ff       	jmp    101e56 <__alltraps>

0010201a <vector48>:
.globl vector48
vector48:
  pushl $0
  10201a:	6a 00                	push   $0x0
  pushl $48
  10201c:	6a 30                	push   $0x30
  jmp __alltraps
  10201e:	e9 33 fe ff ff       	jmp    101e56 <__alltraps>

00102023 <vector49>:
.globl vector49
vector49:
  pushl $0
  102023:	6a 00                	push   $0x0
  pushl $49
  102025:	6a 31                	push   $0x31
  jmp __alltraps
  102027:	e9 2a fe ff ff       	jmp    101e56 <__alltraps>

0010202c <vector50>:
.globl vector50
vector50:
  pushl $0
  10202c:	6a 00                	push   $0x0
  pushl $50
  10202e:	6a 32                	push   $0x32
  jmp __alltraps
  102030:	e9 21 fe ff ff       	jmp    101e56 <__alltraps>

00102035 <vector51>:
.globl vector51
vector51:
  pushl $0
  102035:	6a 00                	push   $0x0
  pushl $51
  102037:	6a 33                	push   $0x33
  jmp __alltraps
  102039:	e9 18 fe ff ff       	jmp    101e56 <__alltraps>

0010203e <vector52>:
.globl vector52
vector52:
  pushl $0
  10203e:	6a 00                	push   $0x0
  pushl $52
  102040:	6a 34                	push   $0x34
  jmp __alltraps
  102042:	e9 0f fe ff ff       	jmp    101e56 <__alltraps>

00102047 <vector53>:
.globl vector53
vector53:
  pushl $0
  102047:	6a 00                	push   $0x0
  pushl $53
  102049:	6a 35                	push   $0x35
  jmp __alltraps
  10204b:	e9 06 fe ff ff       	jmp    101e56 <__alltraps>

00102050 <vector54>:
.globl vector54
vector54:
  pushl $0
  102050:	6a 00                	push   $0x0
  pushl $54
  102052:	6a 36                	push   $0x36
  jmp __alltraps
  102054:	e9 fd fd ff ff       	jmp    101e56 <__alltraps>

00102059 <vector55>:
.globl vector55
vector55:
  pushl $0
  102059:	6a 00                	push   $0x0
  pushl $55
  10205b:	6a 37                	push   $0x37
  jmp __alltraps
  10205d:	e9 f4 fd ff ff       	jmp    101e56 <__alltraps>

00102062 <vector56>:
.globl vector56
vector56:
  pushl $0
  102062:	6a 00                	push   $0x0
  pushl $56
  102064:	6a 38                	push   $0x38
  jmp __alltraps
  102066:	e9 eb fd ff ff       	jmp    101e56 <__alltraps>

0010206b <vector57>:
.globl vector57
vector57:
  pushl $0
  10206b:	6a 00                	push   $0x0
  pushl $57
  10206d:	6a 39                	push   $0x39
  jmp __alltraps
  10206f:	e9 e2 fd ff ff       	jmp    101e56 <__alltraps>

00102074 <vector58>:
.globl vector58
vector58:
  pushl $0
  102074:	6a 00                	push   $0x0
  pushl $58
  102076:	6a 3a                	push   $0x3a
  jmp __alltraps
  102078:	e9 d9 fd ff ff       	jmp    101e56 <__alltraps>

0010207d <vector59>:
.globl vector59
vector59:
  pushl $0
  10207d:	6a 00                	push   $0x0
  pushl $59
  10207f:	6a 3b                	push   $0x3b
  jmp __alltraps
  102081:	e9 d0 fd ff ff       	jmp    101e56 <__alltraps>

00102086 <vector60>:
.globl vector60
vector60:
  pushl $0
  102086:	6a 00                	push   $0x0
  pushl $60
  102088:	6a 3c                	push   $0x3c
  jmp __alltraps
  10208a:	e9 c7 fd ff ff       	jmp    101e56 <__alltraps>

0010208f <vector61>:
.globl vector61
vector61:
  pushl $0
  10208f:	6a 00                	push   $0x0
  pushl $61
  102091:	6a 3d                	push   $0x3d
  jmp __alltraps
  102093:	e9 be fd ff ff       	jmp    101e56 <__alltraps>

00102098 <vector62>:
.globl vector62
vector62:
  pushl $0
  102098:	6a 00                	push   $0x0
  pushl $62
  10209a:	6a 3e                	push   $0x3e
  jmp __alltraps
  10209c:	e9 b5 fd ff ff       	jmp    101e56 <__alltraps>

001020a1 <vector63>:
.globl vector63
vector63:
  pushl $0
  1020a1:	6a 00                	push   $0x0
  pushl $63
  1020a3:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020a5:	e9 ac fd ff ff       	jmp    101e56 <__alltraps>

001020aa <vector64>:
.globl vector64
vector64:
  pushl $0
  1020aa:	6a 00                	push   $0x0
  pushl $64
  1020ac:	6a 40                	push   $0x40
  jmp __alltraps
  1020ae:	e9 a3 fd ff ff       	jmp    101e56 <__alltraps>

001020b3 <vector65>:
.globl vector65
vector65:
  pushl $0
  1020b3:	6a 00                	push   $0x0
  pushl $65
  1020b5:	6a 41                	push   $0x41
  jmp __alltraps
  1020b7:	e9 9a fd ff ff       	jmp    101e56 <__alltraps>

001020bc <vector66>:
.globl vector66
vector66:
  pushl $0
  1020bc:	6a 00                	push   $0x0
  pushl $66
  1020be:	6a 42                	push   $0x42
  jmp __alltraps
  1020c0:	e9 91 fd ff ff       	jmp    101e56 <__alltraps>

001020c5 <vector67>:
.globl vector67
vector67:
  pushl $0
  1020c5:	6a 00                	push   $0x0
  pushl $67
  1020c7:	6a 43                	push   $0x43
  jmp __alltraps
  1020c9:	e9 88 fd ff ff       	jmp    101e56 <__alltraps>

001020ce <vector68>:
.globl vector68
vector68:
  pushl $0
  1020ce:	6a 00                	push   $0x0
  pushl $68
  1020d0:	6a 44                	push   $0x44
  jmp __alltraps
  1020d2:	e9 7f fd ff ff       	jmp    101e56 <__alltraps>

001020d7 <vector69>:
.globl vector69
vector69:
  pushl $0
  1020d7:	6a 00                	push   $0x0
  pushl $69
  1020d9:	6a 45                	push   $0x45
  jmp __alltraps
  1020db:	e9 76 fd ff ff       	jmp    101e56 <__alltraps>

001020e0 <vector70>:
.globl vector70
vector70:
  pushl $0
  1020e0:	6a 00                	push   $0x0
  pushl $70
  1020e2:	6a 46                	push   $0x46
  jmp __alltraps
  1020e4:	e9 6d fd ff ff       	jmp    101e56 <__alltraps>

001020e9 <vector71>:
.globl vector71
vector71:
  pushl $0
  1020e9:	6a 00                	push   $0x0
  pushl $71
  1020eb:	6a 47                	push   $0x47
  jmp __alltraps
  1020ed:	e9 64 fd ff ff       	jmp    101e56 <__alltraps>

001020f2 <vector72>:
.globl vector72
vector72:
  pushl $0
  1020f2:	6a 00                	push   $0x0
  pushl $72
  1020f4:	6a 48                	push   $0x48
  jmp __alltraps
  1020f6:	e9 5b fd ff ff       	jmp    101e56 <__alltraps>

001020fb <vector73>:
.globl vector73
vector73:
  pushl $0
  1020fb:	6a 00                	push   $0x0
  pushl $73
  1020fd:	6a 49                	push   $0x49
  jmp __alltraps
  1020ff:	e9 52 fd ff ff       	jmp    101e56 <__alltraps>

00102104 <vector74>:
.globl vector74
vector74:
  pushl $0
  102104:	6a 00                	push   $0x0
  pushl $74
  102106:	6a 4a                	push   $0x4a
  jmp __alltraps
  102108:	e9 49 fd ff ff       	jmp    101e56 <__alltraps>

0010210d <vector75>:
.globl vector75
vector75:
  pushl $0
  10210d:	6a 00                	push   $0x0
  pushl $75
  10210f:	6a 4b                	push   $0x4b
  jmp __alltraps
  102111:	e9 40 fd ff ff       	jmp    101e56 <__alltraps>

00102116 <vector76>:
.globl vector76
vector76:
  pushl $0
  102116:	6a 00                	push   $0x0
  pushl $76
  102118:	6a 4c                	push   $0x4c
  jmp __alltraps
  10211a:	e9 37 fd ff ff       	jmp    101e56 <__alltraps>

0010211f <vector77>:
.globl vector77
vector77:
  pushl $0
  10211f:	6a 00                	push   $0x0
  pushl $77
  102121:	6a 4d                	push   $0x4d
  jmp __alltraps
  102123:	e9 2e fd ff ff       	jmp    101e56 <__alltraps>

00102128 <vector78>:
.globl vector78
vector78:
  pushl $0
  102128:	6a 00                	push   $0x0
  pushl $78
  10212a:	6a 4e                	push   $0x4e
  jmp __alltraps
  10212c:	e9 25 fd ff ff       	jmp    101e56 <__alltraps>

00102131 <vector79>:
.globl vector79
vector79:
  pushl $0
  102131:	6a 00                	push   $0x0
  pushl $79
  102133:	6a 4f                	push   $0x4f
  jmp __alltraps
  102135:	e9 1c fd ff ff       	jmp    101e56 <__alltraps>

0010213a <vector80>:
.globl vector80
vector80:
  pushl $0
  10213a:	6a 00                	push   $0x0
  pushl $80
  10213c:	6a 50                	push   $0x50
  jmp __alltraps
  10213e:	e9 13 fd ff ff       	jmp    101e56 <__alltraps>

00102143 <vector81>:
.globl vector81
vector81:
  pushl $0
  102143:	6a 00                	push   $0x0
  pushl $81
  102145:	6a 51                	push   $0x51
  jmp __alltraps
  102147:	e9 0a fd ff ff       	jmp    101e56 <__alltraps>

0010214c <vector82>:
.globl vector82
vector82:
  pushl $0
  10214c:	6a 00                	push   $0x0
  pushl $82
  10214e:	6a 52                	push   $0x52
  jmp __alltraps
  102150:	e9 01 fd ff ff       	jmp    101e56 <__alltraps>

00102155 <vector83>:
.globl vector83
vector83:
  pushl $0
  102155:	6a 00                	push   $0x0
  pushl $83
  102157:	6a 53                	push   $0x53
  jmp __alltraps
  102159:	e9 f8 fc ff ff       	jmp    101e56 <__alltraps>

0010215e <vector84>:
.globl vector84
vector84:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $84
  102160:	6a 54                	push   $0x54
  jmp __alltraps
  102162:	e9 ef fc ff ff       	jmp    101e56 <__alltraps>

00102167 <vector85>:
.globl vector85
vector85:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $85
  102169:	6a 55                	push   $0x55
  jmp __alltraps
  10216b:	e9 e6 fc ff ff       	jmp    101e56 <__alltraps>

00102170 <vector86>:
.globl vector86
vector86:
  pushl $0
  102170:	6a 00                	push   $0x0
  pushl $86
  102172:	6a 56                	push   $0x56
  jmp __alltraps
  102174:	e9 dd fc ff ff       	jmp    101e56 <__alltraps>

00102179 <vector87>:
.globl vector87
vector87:
  pushl $0
  102179:	6a 00                	push   $0x0
  pushl $87
  10217b:	6a 57                	push   $0x57
  jmp __alltraps
  10217d:	e9 d4 fc ff ff       	jmp    101e56 <__alltraps>

00102182 <vector88>:
.globl vector88
vector88:
  pushl $0
  102182:	6a 00                	push   $0x0
  pushl $88
  102184:	6a 58                	push   $0x58
  jmp __alltraps
  102186:	e9 cb fc ff ff       	jmp    101e56 <__alltraps>

0010218b <vector89>:
.globl vector89
vector89:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $89
  10218d:	6a 59                	push   $0x59
  jmp __alltraps
  10218f:	e9 c2 fc ff ff       	jmp    101e56 <__alltraps>

00102194 <vector90>:
.globl vector90
vector90:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $90
  102196:	6a 5a                	push   $0x5a
  jmp __alltraps
  102198:	e9 b9 fc ff ff       	jmp    101e56 <__alltraps>

0010219d <vector91>:
.globl vector91
vector91:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $91
  10219f:	6a 5b                	push   $0x5b
  jmp __alltraps
  1021a1:	e9 b0 fc ff ff       	jmp    101e56 <__alltraps>

001021a6 <vector92>:
.globl vector92
vector92:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $92
  1021a8:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021aa:	e9 a7 fc ff ff       	jmp    101e56 <__alltraps>

001021af <vector93>:
.globl vector93
vector93:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $93
  1021b1:	6a 5d                	push   $0x5d
  jmp __alltraps
  1021b3:	e9 9e fc ff ff       	jmp    101e56 <__alltraps>

001021b8 <vector94>:
.globl vector94
vector94:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $94
  1021ba:	6a 5e                	push   $0x5e
  jmp __alltraps
  1021bc:	e9 95 fc ff ff       	jmp    101e56 <__alltraps>

001021c1 <vector95>:
.globl vector95
vector95:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $95
  1021c3:	6a 5f                	push   $0x5f
  jmp __alltraps
  1021c5:	e9 8c fc ff ff       	jmp    101e56 <__alltraps>

001021ca <vector96>:
.globl vector96
vector96:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $96
  1021cc:	6a 60                	push   $0x60
  jmp __alltraps
  1021ce:	e9 83 fc ff ff       	jmp    101e56 <__alltraps>

001021d3 <vector97>:
.globl vector97
vector97:
  pushl $0
  1021d3:	6a 00                	push   $0x0
  pushl $97
  1021d5:	6a 61                	push   $0x61
  jmp __alltraps
  1021d7:	e9 7a fc ff ff       	jmp    101e56 <__alltraps>

001021dc <vector98>:
.globl vector98
vector98:
  pushl $0
  1021dc:	6a 00                	push   $0x0
  pushl $98
  1021de:	6a 62                	push   $0x62
  jmp __alltraps
  1021e0:	e9 71 fc ff ff       	jmp    101e56 <__alltraps>

001021e5 <vector99>:
.globl vector99
vector99:
  pushl $0
  1021e5:	6a 00                	push   $0x0
  pushl $99
  1021e7:	6a 63                	push   $0x63
  jmp __alltraps
  1021e9:	e9 68 fc ff ff       	jmp    101e56 <__alltraps>

001021ee <vector100>:
.globl vector100
vector100:
  pushl $0
  1021ee:	6a 00                	push   $0x0
  pushl $100
  1021f0:	6a 64                	push   $0x64
  jmp __alltraps
  1021f2:	e9 5f fc ff ff       	jmp    101e56 <__alltraps>

001021f7 <vector101>:
.globl vector101
vector101:
  pushl $0
  1021f7:	6a 00                	push   $0x0
  pushl $101
  1021f9:	6a 65                	push   $0x65
  jmp __alltraps
  1021fb:	e9 56 fc ff ff       	jmp    101e56 <__alltraps>

00102200 <vector102>:
.globl vector102
vector102:
  pushl $0
  102200:	6a 00                	push   $0x0
  pushl $102
  102202:	6a 66                	push   $0x66
  jmp __alltraps
  102204:	e9 4d fc ff ff       	jmp    101e56 <__alltraps>

00102209 <vector103>:
.globl vector103
vector103:
  pushl $0
  102209:	6a 00                	push   $0x0
  pushl $103
  10220b:	6a 67                	push   $0x67
  jmp __alltraps
  10220d:	e9 44 fc ff ff       	jmp    101e56 <__alltraps>

00102212 <vector104>:
.globl vector104
vector104:
  pushl $0
  102212:	6a 00                	push   $0x0
  pushl $104
  102214:	6a 68                	push   $0x68
  jmp __alltraps
  102216:	e9 3b fc ff ff       	jmp    101e56 <__alltraps>

0010221b <vector105>:
.globl vector105
vector105:
  pushl $0
  10221b:	6a 00                	push   $0x0
  pushl $105
  10221d:	6a 69                	push   $0x69
  jmp __alltraps
  10221f:	e9 32 fc ff ff       	jmp    101e56 <__alltraps>

00102224 <vector106>:
.globl vector106
vector106:
  pushl $0
  102224:	6a 00                	push   $0x0
  pushl $106
  102226:	6a 6a                	push   $0x6a
  jmp __alltraps
  102228:	e9 29 fc ff ff       	jmp    101e56 <__alltraps>

0010222d <vector107>:
.globl vector107
vector107:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $107
  10222f:	6a 6b                	push   $0x6b
  jmp __alltraps
  102231:	e9 20 fc ff ff       	jmp    101e56 <__alltraps>

00102236 <vector108>:
.globl vector108
vector108:
  pushl $0
  102236:	6a 00                	push   $0x0
  pushl $108
  102238:	6a 6c                	push   $0x6c
  jmp __alltraps
  10223a:	e9 17 fc ff ff       	jmp    101e56 <__alltraps>

0010223f <vector109>:
.globl vector109
vector109:
  pushl $0
  10223f:	6a 00                	push   $0x0
  pushl $109
  102241:	6a 6d                	push   $0x6d
  jmp __alltraps
  102243:	e9 0e fc ff ff       	jmp    101e56 <__alltraps>

00102248 <vector110>:
.globl vector110
vector110:
  pushl $0
  102248:	6a 00                	push   $0x0
  pushl $110
  10224a:	6a 6e                	push   $0x6e
  jmp __alltraps
  10224c:	e9 05 fc ff ff       	jmp    101e56 <__alltraps>

00102251 <vector111>:
.globl vector111
vector111:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $111
  102253:	6a 6f                	push   $0x6f
  jmp __alltraps
  102255:	e9 fc fb ff ff       	jmp    101e56 <__alltraps>

0010225a <vector112>:
.globl vector112
vector112:
  pushl $0
  10225a:	6a 00                	push   $0x0
  pushl $112
  10225c:	6a 70                	push   $0x70
  jmp __alltraps
  10225e:	e9 f3 fb ff ff       	jmp    101e56 <__alltraps>

00102263 <vector113>:
.globl vector113
vector113:
  pushl $0
  102263:	6a 00                	push   $0x0
  pushl $113
  102265:	6a 71                	push   $0x71
  jmp __alltraps
  102267:	e9 ea fb ff ff       	jmp    101e56 <__alltraps>

0010226c <vector114>:
.globl vector114
vector114:
  pushl $0
  10226c:	6a 00                	push   $0x0
  pushl $114
  10226e:	6a 72                	push   $0x72
  jmp __alltraps
  102270:	e9 e1 fb ff ff       	jmp    101e56 <__alltraps>

00102275 <vector115>:
.globl vector115
vector115:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $115
  102277:	6a 73                	push   $0x73
  jmp __alltraps
  102279:	e9 d8 fb ff ff       	jmp    101e56 <__alltraps>

0010227e <vector116>:
.globl vector116
vector116:
  pushl $0
  10227e:	6a 00                	push   $0x0
  pushl $116
  102280:	6a 74                	push   $0x74
  jmp __alltraps
  102282:	e9 cf fb ff ff       	jmp    101e56 <__alltraps>

00102287 <vector117>:
.globl vector117
vector117:
  pushl $0
  102287:	6a 00                	push   $0x0
  pushl $117
  102289:	6a 75                	push   $0x75
  jmp __alltraps
  10228b:	e9 c6 fb ff ff       	jmp    101e56 <__alltraps>

00102290 <vector118>:
.globl vector118
vector118:
  pushl $0
  102290:	6a 00                	push   $0x0
  pushl $118
  102292:	6a 76                	push   $0x76
  jmp __alltraps
  102294:	e9 bd fb ff ff       	jmp    101e56 <__alltraps>

00102299 <vector119>:
.globl vector119
vector119:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $119
  10229b:	6a 77                	push   $0x77
  jmp __alltraps
  10229d:	e9 b4 fb ff ff       	jmp    101e56 <__alltraps>

001022a2 <vector120>:
.globl vector120
vector120:
  pushl $0
  1022a2:	6a 00                	push   $0x0
  pushl $120
  1022a4:	6a 78                	push   $0x78
  jmp __alltraps
  1022a6:	e9 ab fb ff ff       	jmp    101e56 <__alltraps>

001022ab <vector121>:
.globl vector121
vector121:
  pushl $0
  1022ab:	6a 00                	push   $0x0
  pushl $121
  1022ad:	6a 79                	push   $0x79
  jmp __alltraps
  1022af:	e9 a2 fb ff ff       	jmp    101e56 <__alltraps>

001022b4 <vector122>:
.globl vector122
vector122:
  pushl $0
  1022b4:	6a 00                	push   $0x0
  pushl $122
  1022b6:	6a 7a                	push   $0x7a
  jmp __alltraps
  1022b8:	e9 99 fb ff ff       	jmp    101e56 <__alltraps>

001022bd <vector123>:
.globl vector123
vector123:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $123
  1022bf:	6a 7b                	push   $0x7b
  jmp __alltraps
  1022c1:	e9 90 fb ff ff       	jmp    101e56 <__alltraps>

001022c6 <vector124>:
.globl vector124
vector124:
  pushl $0
  1022c6:	6a 00                	push   $0x0
  pushl $124
  1022c8:	6a 7c                	push   $0x7c
  jmp __alltraps
  1022ca:	e9 87 fb ff ff       	jmp    101e56 <__alltraps>

001022cf <vector125>:
.globl vector125
vector125:
  pushl $0
  1022cf:	6a 00                	push   $0x0
  pushl $125
  1022d1:	6a 7d                	push   $0x7d
  jmp __alltraps
  1022d3:	e9 7e fb ff ff       	jmp    101e56 <__alltraps>

001022d8 <vector126>:
.globl vector126
vector126:
  pushl $0
  1022d8:	6a 00                	push   $0x0
  pushl $126
  1022da:	6a 7e                	push   $0x7e
  jmp __alltraps
  1022dc:	e9 75 fb ff ff       	jmp    101e56 <__alltraps>

001022e1 <vector127>:
.globl vector127
vector127:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $127
  1022e3:	6a 7f                	push   $0x7f
  jmp __alltraps
  1022e5:	e9 6c fb ff ff       	jmp    101e56 <__alltraps>

001022ea <vector128>:
.globl vector128
vector128:
  pushl $0
  1022ea:	6a 00                	push   $0x0
  pushl $128
  1022ec:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1022f1:	e9 60 fb ff ff       	jmp    101e56 <__alltraps>

001022f6 <vector129>:
.globl vector129
vector129:
  pushl $0
  1022f6:	6a 00                	push   $0x0
  pushl $129
  1022f8:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022fd:	e9 54 fb ff ff       	jmp    101e56 <__alltraps>

00102302 <vector130>:
.globl vector130
vector130:
  pushl $0
  102302:	6a 00                	push   $0x0
  pushl $130
  102304:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102309:	e9 48 fb ff ff       	jmp    101e56 <__alltraps>

0010230e <vector131>:
.globl vector131
vector131:
  pushl $0
  10230e:	6a 00                	push   $0x0
  pushl $131
  102310:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102315:	e9 3c fb ff ff       	jmp    101e56 <__alltraps>

0010231a <vector132>:
.globl vector132
vector132:
  pushl $0
  10231a:	6a 00                	push   $0x0
  pushl $132
  10231c:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102321:	e9 30 fb ff ff       	jmp    101e56 <__alltraps>

00102326 <vector133>:
.globl vector133
vector133:
  pushl $0
  102326:	6a 00                	push   $0x0
  pushl $133
  102328:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10232d:	e9 24 fb ff ff       	jmp    101e56 <__alltraps>

00102332 <vector134>:
.globl vector134
vector134:
  pushl $0
  102332:	6a 00                	push   $0x0
  pushl $134
  102334:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102339:	e9 18 fb ff ff       	jmp    101e56 <__alltraps>

0010233e <vector135>:
.globl vector135
vector135:
  pushl $0
  10233e:	6a 00                	push   $0x0
  pushl $135
  102340:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102345:	e9 0c fb ff ff       	jmp    101e56 <__alltraps>

0010234a <vector136>:
.globl vector136
vector136:
  pushl $0
  10234a:	6a 00                	push   $0x0
  pushl $136
  10234c:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102351:	e9 00 fb ff ff       	jmp    101e56 <__alltraps>

00102356 <vector137>:
.globl vector137
vector137:
  pushl $0
  102356:	6a 00                	push   $0x0
  pushl $137
  102358:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10235d:	e9 f4 fa ff ff       	jmp    101e56 <__alltraps>

00102362 <vector138>:
.globl vector138
vector138:
  pushl $0
  102362:	6a 00                	push   $0x0
  pushl $138
  102364:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102369:	e9 e8 fa ff ff       	jmp    101e56 <__alltraps>

0010236e <vector139>:
.globl vector139
vector139:
  pushl $0
  10236e:	6a 00                	push   $0x0
  pushl $139
  102370:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102375:	e9 dc fa ff ff       	jmp    101e56 <__alltraps>

0010237a <vector140>:
.globl vector140
vector140:
  pushl $0
  10237a:	6a 00                	push   $0x0
  pushl $140
  10237c:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102381:	e9 d0 fa ff ff       	jmp    101e56 <__alltraps>

00102386 <vector141>:
.globl vector141
vector141:
  pushl $0
  102386:	6a 00                	push   $0x0
  pushl $141
  102388:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10238d:	e9 c4 fa ff ff       	jmp    101e56 <__alltraps>

00102392 <vector142>:
.globl vector142
vector142:
  pushl $0
  102392:	6a 00                	push   $0x0
  pushl $142
  102394:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102399:	e9 b8 fa ff ff       	jmp    101e56 <__alltraps>

0010239e <vector143>:
.globl vector143
vector143:
  pushl $0
  10239e:	6a 00                	push   $0x0
  pushl $143
  1023a0:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023a5:	e9 ac fa ff ff       	jmp    101e56 <__alltraps>

001023aa <vector144>:
.globl vector144
vector144:
  pushl $0
  1023aa:	6a 00                	push   $0x0
  pushl $144
  1023ac:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1023b1:	e9 a0 fa ff ff       	jmp    101e56 <__alltraps>

001023b6 <vector145>:
.globl vector145
vector145:
  pushl $0
  1023b6:	6a 00                	push   $0x0
  pushl $145
  1023b8:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1023bd:	e9 94 fa ff ff       	jmp    101e56 <__alltraps>

001023c2 <vector146>:
.globl vector146
vector146:
  pushl $0
  1023c2:	6a 00                	push   $0x0
  pushl $146
  1023c4:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1023c9:	e9 88 fa ff ff       	jmp    101e56 <__alltraps>

001023ce <vector147>:
.globl vector147
vector147:
  pushl $0
  1023ce:	6a 00                	push   $0x0
  pushl $147
  1023d0:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1023d5:	e9 7c fa ff ff       	jmp    101e56 <__alltraps>

001023da <vector148>:
.globl vector148
vector148:
  pushl $0
  1023da:	6a 00                	push   $0x0
  pushl $148
  1023dc:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1023e1:	e9 70 fa ff ff       	jmp    101e56 <__alltraps>

001023e6 <vector149>:
.globl vector149
vector149:
  pushl $0
  1023e6:	6a 00                	push   $0x0
  pushl $149
  1023e8:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1023ed:	e9 64 fa ff ff       	jmp    101e56 <__alltraps>

001023f2 <vector150>:
.globl vector150
vector150:
  pushl $0
  1023f2:	6a 00                	push   $0x0
  pushl $150
  1023f4:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023f9:	e9 58 fa ff ff       	jmp    101e56 <__alltraps>

001023fe <vector151>:
.globl vector151
vector151:
  pushl $0
  1023fe:	6a 00                	push   $0x0
  pushl $151
  102400:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102405:	e9 4c fa ff ff       	jmp    101e56 <__alltraps>

0010240a <vector152>:
.globl vector152
vector152:
  pushl $0
  10240a:	6a 00                	push   $0x0
  pushl $152
  10240c:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102411:	e9 40 fa ff ff       	jmp    101e56 <__alltraps>

00102416 <vector153>:
.globl vector153
vector153:
  pushl $0
  102416:	6a 00                	push   $0x0
  pushl $153
  102418:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10241d:	e9 34 fa ff ff       	jmp    101e56 <__alltraps>

00102422 <vector154>:
.globl vector154
vector154:
  pushl $0
  102422:	6a 00                	push   $0x0
  pushl $154
  102424:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102429:	e9 28 fa ff ff       	jmp    101e56 <__alltraps>

0010242e <vector155>:
.globl vector155
vector155:
  pushl $0
  10242e:	6a 00                	push   $0x0
  pushl $155
  102430:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102435:	e9 1c fa ff ff       	jmp    101e56 <__alltraps>

0010243a <vector156>:
.globl vector156
vector156:
  pushl $0
  10243a:	6a 00                	push   $0x0
  pushl $156
  10243c:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102441:	e9 10 fa ff ff       	jmp    101e56 <__alltraps>

00102446 <vector157>:
.globl vector157
vector157:
  pushl $0
  102446:	6a 00                	push   $0x0
  pushl $157
  102448:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10244d:	e9 04 fa ff ff       	jmp    101e56 <__alltraps>

00102452 <vector158>:
.globl vector158
vector158:
  pushl $0
  102452:	6a 00                	push   $0x0
  pushl $158
  102454:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102459:	e9 f8 f9 ff ff       	jmp    101e56 <__alltraps>

0010245e <vector159>:
.globl vector159
vector159:
  pushl $0
  10245e:	6a 00                	push   $0x0
  pushl $159
  102460:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102465:	e9 ec f9 ff ff       	jmp    101e56 <__alltraps>

0010246a <vector160>:
.globl vector160
vector160:
  pushl $0
  10246a:	6a 00                	push   $0x0
  pushl $160
  10246c:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102471:	e9 e0 f9 ff ff       	jmp    101e56 <__alltraps>

00102476 <vector161>:
.globl vector161
vector161:
  pushl $0
  102476:	6a 00                	push   $0x0
  pushl $161
  102478:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10247d:	e9 d4 f9 ff ff       	jmp    101e56 <__alltraps>

00102482 <vector162>:
.globl vector162
vector162:
  pushl $0
  102482:	6a 00                	push   $0x0
  pushl $162
  102484:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102489:	e9 c8 f9 ff ff       	jmp    101e56 <__alltraps>

0010248e <vector163>:
.globl vector163
vector163:
  pushl $0
  10248e:	6a 00                	push   $0x0
  pushl $163
  102490:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102495:	e9 bc f9 ff ff       	jmp    101e56 <__alltraps>

0010249a <vector164>:
.globl vector164
vector164:
  pushl $0
  10249a:	6a 00                	push   $0x0
  pushl $164
  10249c:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1024a1:	e9 b0 f9 ff ff       	jmp    101e56 <__alltraps>

001024a6 <vector165>:
.globl vector165
vector165:
  pushl $0
  1024a6:	6a 00                	push   $0x0
  pushl $165
  1024a8:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024ad:	e9 a4 f9 ff ff       	jmp    101e56 <__alltraps>

001024b2 <vector166>:
.globl vector166
vector166:
  pushl $0
  1024b2:	6a 00                	push   $0x0
  pushl $166
  1024b4:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1024b9:	e9 98 f9 ff ff       	jmp    101e56 <__alltraps>

001024be <vector167>:
.globl vector167
vector167:
  pushl $0
  1024be:	6a 00                	push   $0x0
  pushl $167
  1024c0:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1024c5:	e9 8c f9 ff ff       	jmp    101e56 <__alltraps>

001024ca <vector168>:
.globl vector168
vector168:
  pushl $0
  1024ca:	6a 00                	push   $0x0
  pushl $168
  1024cc:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1024d1:	e9 80 f9 ff ff       	jmp    101e56 <__alltraps>

001024d6 <vector169>:
.globl vector169
vector169:
  pushl $0
  1024d6:	6a 00                	push   $0x0
  pushl $169
  1024d8:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1024dd:	e9 74 f9 ff ff       	jmp    101e56 <__alltraps>

001024e2 <vector170>:
.globl vector170
vector170:
  pushl $0
  1024e2:	6a 00                	push   $0x0
  pushl $170
  1024e4:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1024e9:	e9 68 f9 ff ff       	jmp    101e56 <__alltraps>

001024ee <vector171>:
.globl vector171
vector171:
  pushl $0
  1024ee:	6a 00                	push   $0x0
  pushl $171
  1024f0:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1024f5:	e9 5c f9 ff ff       	jmp    101e56 <__alltraps>

001024fa <vector172>:
.globl vector172
vector172:
  pushl $0
  1024fa:	6a 00                	push   $0x0
  pushl $172
  1024fc:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102501:	e9 50 f9 ff ff       	jmp    101e56 <__alltraps>

00102506 <vector173>:
.globl vector173
vector173:
  pushl $0
  102506:	6a 00                	push   $0x0
  pushl $173
  102508:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10250d:	e9 44 f9 ff ff       	jmp    101e56 <__alltraps>

00102512 <vector174>:
.globl vector174
vector174:
  pushl $0
  102512:	6a 00                	push   $0x0
  pushl $174
  102514:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102519:	e9 38 f9 ff ff       	jmp    101e56 <__alltraps>

0010251e <vector175>:
.globl vector175
vector175:
  pushl $0
  10251e:	6a 00                	push   $0x0
  pushl $175
  102520:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102525:	e9 2c f9 ff ff       	jmp    101e56 <__alltraps>

0010252a <vector176>:
.globl vector176
vector176:
  pushl $0
  10252a:	6a 00                	push   $0x0
  pushl $176
  10252c:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102531:	e9 20 f9 ff ff       	jmp    101e56 <__alltraps>

00102536 <vector177>:
.globl vector177
vector177:
  pushl $0
  102536:	6a 00                	push   $0x0
  pushl $177
  102538:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10253d:	e9 14 f9 ff ff       	jmp    101e56 <__alltraps>

00102542 <vector178>:
.globl vector178
vector178:
  pushl $0
  102542:	6a 00                	push   $0x0
  pushl $178
  102544:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102549:	e9 08 f9 ff ff       	jmp    101e56 <__alltraps>

0010254e <vector179>:
.globl vector179
vector179:
  pushl $0
  10254e:	6a 00                	push   $0x0
  pushl $179
  102550:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102555:	e9 fc f8 ff ff       	jmp    101e56 <__alltraps>

0010255a <vector180>:
.globl vector180
vector180:
  pushl $0
  10255a:	6a 00                	push   $0x0
  pushl $180
  10255c:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102561:	e9 f0 f8 ff ff       	jmp    101e56 <__alltraps>

00102566 <vector181>:
.globl vector181
vector181:
  pushl $0
  102566:	6a 00                	push   $0x0
  pushl $181
  102568:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10256d:	e9 e4 f8 ff ff       	jmp    101e56 <__alltraps>

00102572 <vector182>:
.globl vector182
vector182:
  pushl $0
  102572:	6a 00                	push   $0x0
  pushl $182
  102574:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102579:	e9 d8 f8 ff ff       	jmp    101e56 <__alltraps>

0010257e <vector183>:
.globl vector183
vector183:
  pushl $0
  10257e:	6a 00                	push   $0x0
  pushl $183
  102580:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102585:	e9 cc f8 ff ff       	jmp    101e56 <__alltraps>

0010258a <vector184>:
.globl vector184
vector184:
  pushl $0
  10258a:	6a 00                	push   $0x0
  pushl $184
  10258c:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102591:	e9 c0 f8 ff ff       	jmp    101e56 <__alltraps>

00102596 <vector185>:
.globl vector185
vector185:
  pushl $0
  102596:	6a 00                	push   $0x0
  pushl $185
  102598:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10259d:	e9 b4 f8 ff ff       	jmp    101e56 <__alltraps>

001025a2 <vector186>:
.globl vector186
vector186:
  pushl $0
  1025a2:	6a 00                	push   $0x0
  pushl $186
  1025a4:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025a9:	e9 a8 f8 ff ff       	jmp    101e56 <__alltraps>

001025ae <vector187>:
.globl vector187
vector187:
  pushl $0
  1025ae:	6a 00                	push   $0x0
  pushl $187
  1025b0:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1025b5:	e9 9c f8 ff ff       	jmp    101e56 <__alltraps>

001025ba <vector188>:
.globl vector188
vector188:
  pushl $0
  1025ba:	6a 00                	push   $0x0
  pushl $188
  1025bc:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1025c1:	e9 90 f8 ff ff       	jmp    101e56 <__alltraps>

001025c6 <vector189>:
.globl vector189
vector189:
  pushl $0
  1025c6:	6a 00                	push   $0x0
  pushl $189
  1025c8:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1025cd:	e9 84 f8 ff ff       	jmp    101e56 <__alltraps>

001025d2 <vector190>:
.globl vector190
vector190:
  pushl $0
  1025d2:	6a 00                	push   $0x0
  pushl $190
  1025d4:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1025d9:	e9 78 f8 ff ff       	jmp    101e56 <__alltraps>

001025de <vector191>:
.globl vector191
vector191:
  pushl $0
  1025de:	6a 00                	push   $0x0
  pushl $191
  1025e0:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1025e5:	e9 6c f8 ff ff       	jmp    101e56 <__alltraps>

001025ea <vector192>:
.globl vector192
vector192:
  pushl $0
  1025ea:	6a 00                	push   $0x0
  pushl $192
  1025ec:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1025f1:	e9 60 f8 ff ff       	jmp    101e56 <__alltraps>

001025f6 <vector193>:
.globl vector193
vector193:
  pushl $0
  1025f6:	6a 00                	push   $0x0
  pushl $193
  1025f8:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025fd:	e9 54 f8 ff ff       	jmp    101e56 <__alltraps>

00102602 <vector194>:
.globl vector194
vector194:
  pushl $0
  102602:	6a 00                	push   $0x0
  pushl $194
  102604:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102609:	e9 48 f8 ff ff       	jmp    101e56 <__alltraps>

0010260e <vector195>:
.globl vector195
vector195:
  pushl $0
  10260e:	6a 00                	push   $0x0
  pushl $195
  102610:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102615:	e9 3c f8 ff ff       	jmp    101e56 <__alltraps>

0010261a <vector196>:
.globl vector196
vector196:
  pushl $0
  10261a:	6a 00                	push   $0x0
  pushl $196
  10261c:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102621:	e9 30 f8 ff ff       	jmp    101e56 <__alltraps>

00102626 <vector197>:
.globl vector197
vector197:
  pushl $0
  102626:	6a 00                	push   $0x0
  pushl $197
  102628:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10262d:	e9 24 f8 ff ff       	jmp    101e56 <__alltraps>

00102632 <vector198>:
.globl vector198
vector198:
  pushl $0
  102632:	6a 00                	push   $0x0
  pushl $198
  102634:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102639:	e9 18 f8 ff ff       	jmp    101e56 <__alltraps>

0010263e <vector199>:
.globl vector199
vector199:
  pushl $0
  10263e:	6a 00                	push   $0x0
  pushl $199
  102640:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102645:	e9 0c f8 ff ff       	jmp    101e56 <__alltraps>

0010264a <vector200>:
.globl vector200
vector200:
  pushl $0
  10264a:	6a 00                	push   $0x0
  pushl $200
  10264c:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102651:	e9 00 f8 ff ff       	jmp    101e56 <__alltraps>

00102656 <vector201>:
.globl vector201
vector201:
  pushl $0
  102656:	6a 00                	push   $0x0
  pushl $201
  102658:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10265d:	e9 f4 f7 ff ff       	jmp    101e56 <__alltraps>

00102662 <vector202>:
.globl vector202
vector202:
  pushl $0
  102662:	6a 00                	push   $0x0
  pushl $202
  102664:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102669:	e9 e8 f7 ff ff       	jmp    101e56 <__alltraps>

0010266e <vector203>:
.globl vector203
vector203:
  pushl $0
  10266e:	6a 00                	push   $0x0
  pushl $203
  102670:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102675:	e9 dc f7 ff ff       	jmp    101e56 <__alltraps>

0010267a <vector204>:
.globl vector204
vector204:
  pushl $0
  10267a:	6a 00                	push   $0x0
  pushl $204
  10267c:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102681:	e9 d0 f7 ff ff       	jmp    101e56 <__alltraps>

00102686 <vector205>:
.globl vector205
vector205:
  pushl $0
  102686:	6a 00                	push   $0x0
  pushl $205
  102688:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10268d:	e9 c4 f7 ff ff       	jmp    101e56 <__alltraps>

00102692 <vector206>:
.globl vector206
vector206:
  pushl $0
  102692:	6a 00                	push   $0x0
  pushl $206
  102694:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102699:	e9 b8 f7 ff ff       	jmp    101e56 <__alltraps>

0010269e <vector207>:
.globl vector207
vector207:
  pushl $0
  10269e:	6a 00                	push   $0x0
  pushl $207
  1026a0:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026a5:	e9 ac f7 ff ff       	jmp    101e56 <__alltraps>

001026aa <vector208>:
.globl vector208
vector208:
  pushl $0
  1026aa:	6a 00                	push   $0x0
  pushl $208
  1026ac:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1026b1:	e9 a0 f7 ff ff       	jmp    101e56 <__alltraps>

001026b6 <vector209>:
.globl vector209
vector209:
  pushl $0
  1026b6:	6a 00                	push   $0x0
  pushl $209
  1026b8:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1026bd:	e9 94 f7 ff ff       	jmp    101e56 <__alltraps>

001026c2 <vector210>:
.globl vector210
vector210:
  pushl $0
  1026c2:	6a 00                	push   $0x0
  pushl $210
  1026c4:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1026c9:	e9 88 f7 ff ff       	jmp    101e56 <__alltraps>

001026ce <vector211>:
.globl vector211
vector211:
  pushl $0
  1026ce:	6a 00                	push   $0x0
  pushl $211
  1026d0:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1026d5:	e9 7c f7 ff ff       	jmp    101e56 <__alltraps>

001026da <vector212>:
.globl vector212
vector212:
  pushl $0
  1026da:	6a 00                	push   $0x0
  pushl $212
  1026dc:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1026e1:	e9 70 f7 ff ff       	jmp    101e56 <__alltraps>

001026e6 <vector213>:
.globl vector213
vector213:
  pushl $0
  1026e6:	6a 00                	push   $0x0
  pushl $213
  1026e8:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1026ed:	e9 64 f7 ff ff       	jmp    101e56 <__alltraps>

001026f2 <vector214>:
.globl vector214
vector214:
  pushl $0
  1026f2:	6a 00                	push   $0x0
  pushl $214
  1026f4:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026f9:	e9 58 f7 ff ff       	jmp    101e56 <__alltraps>

001026fe <vector215>:
.globl vector215
vector215:
  pushl $0
  1026fe:	6a 00                	push   $0x0
  pushl $215
  102700:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102705:	e9 4c f7 ff ff       	jmp    101e56 <__alltraps>

0010270a <vector216>:
.globl vector216
vector216:
  pushl $0
  10270a:	6a 00                	push   $0x0
  pushl $216
  10270c:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102711:	e9 40 f7 ff ff       	jmp    101e56 <__alltraps>

00102716 <vector217>:
.globl vector217
vector217:
  pushl $0
  102716:	6a 00                	push   $0x0
  pushl $217
  102718:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10271d:	e9 34 f7 ff ff       	jmp    101e56 <__alltraps>

00102722 <vector218>:
.globl vector218
vector218:
  pushl $0
  102722:	6a 00                	push   $0x0
  pushl $218
  102724:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102729:	e9 28 f7 ff ff       	jmp    101e56 <__alltraps>

0010272e <vector219>:
.globl vector219
vector219:
  pushl $0
  10272e:	6a 00                	push   $0x0
  pushl $219
  102730:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102735:	e9 1c f7 ff ff       	jmp    101e56 <__alltraps>

0010273a <vector220>:
.globl vector220
vector220:
  pushl $0
  10273a:	6a 00                	push   $0x0
  pushl $220
  10273c:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102741:	e9 10 f7 ff ff       	jmp    101e56 <__alltraps>

00102746 <vector221>:
.globl vector221
vector221:
  pushl $0
  102746:	6a 00                	push   $0x0
  pushl $221
  102748:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10274d:	e9 04 f7 ff ff       	jmp    101e56 <__alltraps>

00102752 <vector222>:
.globl vector222
vector222:
  pushl $0
  102752:	6a 00                	push   $0x0
  pushl $222
  102754:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102759:	e9 f8 f6 ff ff       	jmp    101e56 <__alltraps>

0010275e <vector223>:
.globl vector223
vector223:
  pushl $0
  10275e:	6a 00                	push   $0x0
  pushl $223
  102760:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102765:	e9 ec f6 ff ff       	jmp    101e56 <__alltraps>

0010276a <vector224>:
.globl vector224
vector224:
  pushl $0
  10276a:	6a 00                	push   $0x0
  pushl $224
  10276c:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102771:	e9 e0 f6 ff ff       	jmp    101e56 <__alltraps>

00102776 <vector225>:
.globl vector225
vector225:
  pushl $0
  102776:	6a 00                	push   $0x0
  pushl $225
  102778:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10277d:	e9 d4 f6 ff ff       	jmp    101e56 <__alltraps>

00102782 <vector226>:
.globl vector226
vector226:
  pushl $0
  102782:	6a 00                	push   $0x0
  pushl $226
  102784:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102789:	e9 c8 f6 ff ff       	jmp    101e56 <__alltraps>

0010278e <vector227>:
.globl vector227
vector227:
  pushl $0
  10278e:	6a 00                	push   $0x0
  pushl $227
  102790:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102795:	e9 bc f6 ff ff       	jmp    101e56 <__alltraps>

0010279a <vector228>:
.globl vector228
vector228:
  pushl $0
  10279a:	6a 00                	push   $0x0
  pushl $228
  10279c:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1027a1:	e9 b0 f6 ff ff       	jmp    101e56 <__alltraps>

001027a6 <vector229>:
.globl vector229
vector229:
  pushl $0
  1027a6:	6a 00                	push   $0x0
  pushl $229
  1027a8:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027ad:	e9 a4 f6 ff ff       	jmp    101e56 <__alltraps>

001027b2 <vector230>:
.globl vector230
vector230:
  pushl $0
  1027b2:	6a 00                	push   $0x0
  pushl $230
  1027b4:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1027b9:	e9 98 f6 ff ff       	jmp    101e56 <__alltraps>

001027be <vector231>:
.globl vector231
vector231:
  pushl $0
  1027be:	6a 00                	push   $0x0
  pushl $231
  1027c0:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1027c5:	e9 8c f6 ff ff       	jmp    101e56 <__alltraps>

001027ca <vector232>:
.globl vector232
vector232:
  pushl $0
  1027ca:	6a 00                	push   $0x0
  pushl $232
  1027cc:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1027d1:	e9 80 f6 ff ff       	jmp    101e56 <__alltraps>

001027d6 <vector233>:
.globl vector233
vector233:
  pushl $0
  1027d6:	6a 00                	push   $0x0
  pushl $233
  1027d8:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1027dd:	e9 74 f6 ff ff       	jmp    101e56 <__alltraps>

001027e2 <vector234>:
.globl vector234
vector234:
  pushl $0
  1027e2:	6a 00                	push   $0x0
  pushl $234
  1027e4:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1027e9:	e9 68 f6 ff ff       	jmp    101e56 <__alltraps>

001027ee <vector235>:
.globl vector235
vector235:
  pushl $0
  1027ee:	6a 00                	push   $0x0
  pushl $235
  1027f0:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1027f5:	e9 5c f6 ff ff       	jmp    101e56 <__alltraps>

001027fa <vector236>:
.globl vector236
vector236:
  pushl $0
  1027fa:	6a 00                	push   $0x0
  pushl $236
  1027fc:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102801:	e9 50 f6 ff ff       	jmp    101e56 <__alltraps>

00102806 <vector237>:
.globl vector237
vector237:
  pushl $0
  102806:	6a 00                	push   $0x0
  pushl $237
  102808:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10280d:	e9 44 f6 ff ff       	jmp    101e56 <__alltraps>

00102812 <vector238>:
.globl vector238
vector238:
  pushl $0
  102812:	6a 00                	push   $0x0
  pushl $238
  102814:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102819:	e9 38 f6 ff ff       	jmp    101e56 <__alltraps>

0010281e <vector239>:
.globl vector239
vector239:
  pushl $0
  10281e:	6a 00                	push   $0x0
  pushl $239
  102820:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102825:	e9 2c f6 ff ff       	jmp    101e56 <__alltraps>

0010282a <vector240>:
.globl vector240
vector240:
  pushl $0
  10282a:	6a 00                	push   $0x0
  pushl $240
  10282c:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102831:	e9 20 f6 ff ff       	jmp    101e56 <__alltraps>

00102836 <vector241>:
.globl vector241
vector241:
  pushl $0
  102836:	6a 00                	push   $0x0
  pushl $241
  102838:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10283d:	e9 14 f6 ff ff       	jmp    101e56 <__alltraps>

00102842 <vector242>:
.globl vector242
vector242:
  pushl $0
  102842:	6a 00                	push   $0x0
  pushl $242
  102844:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102849:	e9 08 f6 ff ff       	jmp    101e56 <__alltraps>

0010284e <vector243>:
.globl vector243
vector243:
  pushl $0
  10284e:	6a 00                	push   $0x0
  pushl $243
  102850:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102855:	e9 fc f5 ff ff       	jmp    101e56 <__alltraps>

0010285a <vector244>:
.globl vector244
vector244:
  pushl $0
  10285a:	6a 00                	push   $0x0
  pushl $244
  10285c:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102861:	e9 f0 f5 ff ff       	jmp    101e56 <__alltraps>

00102866 <vector245>:
.globl vector245
vector245:
  pushl $0
  102866:	6a 00                	push   $0x0
  pushl $245
  102868:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10286d:	e9 e4 f5 ff ff       	jmp    101e56 <__alltraps>

00102872 <vector246>:
.globl vector246
vector246:
  pushl $0
  102872:	6a 00                	push   $0x0
  pushl $246
  102874:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102879:	e9 d8 f5 ff ff       	jmp    101e56 <__alltraps>

0010287e <vector247>:
.globl vector247
vector247:
  pushl $0
  10287e:	6a 00                	push   $0x0
  pushl $247
  102880:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102885:	e9 cc f5 ff ff       	jmp    101e56 <__alltraps>

0010288a <vector248>:
.globl vector248
vector248:
  pushl $0
  10288a:	6a 00                	push   $0x0
  pushl $248
  10288c:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102891:	e9 c0 f5 ff ff       	jmp    101e56 <__alltraps>

00102896 <vector249>:
.globl vector249
vector249:
  pushl $0
  102896:	6a 00                	push   $0x0
  pushl $249
  102898:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10289d:	e9 b4 f5 ff ff       	jmp    101e56 <__alltraps>

001028a2 <vector250>:
.globl vector250
vector250:
  pushl $0
  1028a2:	6a 00                	push   $0x0
  pushl $250
  1028a4:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028a9:	e9 a8 f5 ff ff       	jmp    101e56 <__alltraps>

001028ae <vector251>:
.globl vector251
vector251:
  pushl $0
  1028ae:	6a 00                	push   $0x0
  pushl $251
  1028b0:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1028b5:	e9 9c f5 ff ff       	jmp    101e56 <__alltraps>

001028ba <vector252>:
.globl vector252
vector252:
  pushl $0
  1028ba:	6a 00                	push   $0x0
  pushl $252
  1028bc:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1028c1:	e9 90 f5 ff ff       	jmp    101e56 <__alltraps>

001028c6 <vector253>:
.globl vector253
vector253:
  pushl $0
  1028c6:	6a 00                	push   $0x0
  pushl $253
  1028c8:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1028cd:	e9 84 f5 ff ff       	jmp    101e56 <__alltraps>

001028d2 <vector254>:
.globl vector254
vector254:
  pushl $0
  1028d2:	6a 00                	push   $0x0
  pushl $254
  1028d4:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1028d9:	e9 78 f5 ff ff       	jmp    101e56 <__alltraps>

001028de <vector255>:
.globl vector255
vector255:
  pushl $0
  1028de:	6a 00                	push   $0x0
  pushl $255
  1028e0:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1028e5:	e9 6c f5 ff ff       	jmp    101e56 <__alltraps>

001028ea <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1028ea:	55                   	push   %ebp
  1028eb:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1028ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1028f0:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1028f3:	b8 23 00 00 00       	mov    $0x23,%eax
  1028f8:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1028fa:	b8 23 00 00 00       	mov    $0x23,%eax
  1028ff:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102901:	b8 10 00 00 00       	mov    $0x10,%eax
  102906:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102908:	b8 10 00 00 00       	mov    $0x10,%eax
  10290d:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  10290f:	b8 10 00 00 00       	mov    $0x10,%eax
  102914:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102916:	ea 1d 29 10 00 08 00 	ljmp   $0x8,$0x10291d
}
  10291d:	90                   	nop
  10291e:	5d                   	pop    %ebp
  10291f:	c3                   	ret    

00102920 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102920:	55                   	push   %ebp
  102921:	89 e5                	mov    %esp,%ebp
  102923:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102926:	b8 a0 08 11 00       	mov    $0x1108a0,%eax
  10292b:	05 00 04 00 00       	add    $0x400,%eax
  102930:	a3 a4 0c 11 00       	mov    %eax,0x110ca4
    ts.ts_ss0 = KERNEL_DS;
  102935:	66 c7 05 a8 0c 11 00 	movw   $0x10,0x110ca8
  10293c:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  10293e:	66 c7 05 08 fa 10 00 	movw   $0x68,0x10fa08
  102945:	68 00 
  102947:	b8 a0 0c 11 00       	mov    $0x110ca0,%eax
  10294c:	0f b7 c0             	movzwl %ax,%eax
  10294f:	66 a3 0a fa 10 00    	mov    %ax,0x10fa0a
  102955:	b8 a0 0c 11 00       	mov    $0x110ca0,%eax
  10295a:	c1 e8 10             	shr    $0x10,%eax
  10295d:	a2 0c fa 10 00       	mov    %al,0x10fa0c
  102962:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102969:	24 f0                	and    $0xf0,%al
  10296b:	0c 09                	or     $0x9,%al
  10296d:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102972:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102979:	0c 10                	or     $0x10,%al
  10297b:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102980:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102987:	24 9f                	and    $0x9f,%al
  102989:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  10298e:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102995:	0c 80                	or     $0x80,%al
  102997:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  10299c:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  1029a3:	24 f0                	and    $0xf0,%al
  1029a5:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  1029aa:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  1029b1:	24 ef                	and    $0xef,%al
  1029b3:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  1029b8:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  1029bf:	24 df                	and    $0xdf,%al
  1029c1:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  1029c6:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  1029cd:	0c 40                	or     $0x40,%al
  1029cf:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  1029d4:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  1029db:	24 7f                	and    $0x7f,%al
  1029dd:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  1029e2:	b8 a0 0c 11 00       	mov    $0x110ca0,%eax
  1029e7:	c1 e8 18             	shr    $0x18,%eax
  1029ea:	a2 0f fa 10 00       	mov    %al,0x10fa0f
    gdt[SEG_TSS].sd_s = 0;
  1029ef:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  1029f6:	24 ef                	and    $0xef,%al
  1029f8:	a2 0d fa 10 00       	mov    %al,0x10fa0d

    // reload all segment registers
    lgdt(&gdt_pd);
  1029fd:	c7 04 24 10 fa 10 00 	movl   $0x10fa10,(%esp)
  102a04:	e8 e1 fe ff ff       	call   1028ea <lgdt>
  102a09:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102a0f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102a13:	0f 00 d8             	ltr    %ax
}
  102a16:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102a17:	90                   	nop
  102a18:	89 ec                	mov    %ebp,%esp
  102a1a:	5d                   	pop    %ebp
  102a1b:	c3                   	ret    

00102a1c <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102a1c:	55                   	push   %ebp
  102a1d:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102a1f:	e8 fc fe ff ff       	call   102920 <gdt_init>
}
  102a24:	90                   	nop
  102a25:	5d                   	pop    %ebp
  102a26:	c3                   	ret    

00102a27 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102a27:	55                   	push   %ebp
  102a28:	89 e5                	mov    %esp,%ebp
  102a2a:	83 ec 58             	sub    $0x58,%esp
  102a2d:	8b 45 10             	mov    0x10(%ebp),%eax
  102a30:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a33:	8b 45 14             	mov    0x14(%ebp),%eax
  102a36:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102a39:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a3c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102a42:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102a45:	8b 45 18             	mov    0x18(%ebp),%eax
  102a48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102a4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102a4e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102a51:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102a54:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102a61:	74 1c                	je     102a7f <printnum+0x58>
  102a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a66:	ba 00 00 00 00       	mov    $0x0,%edx
  102a6b:	f7 75 e4             	divl   -0x1c(%ebp)
  102a6e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a74:	ba 00 00 00 00       	mov    $0x0,%edx
  102a79:	f7 75 e4             	divl   -0x1c(%ebp)
  102a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102a85:	f7 75 e4             	divl   -0x1c(%ebp)
  102a88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102a8b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a91:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102a94:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102a97:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102a9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a9d:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102aa0:	8b 45 18             	mov    0x18(%ebp),%eax
  102aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  102aa8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  102aab:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102aae:	19 d1                	sbb    %edx,%ecx
  102ab0:	72 4c                	jb     102afe <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  102ab2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102ab5:	8d 50 ff             	lea    -0x1(%eax),%edx
  102ab8:	8b 45 20             	mov    0x20(%ebp),%eax
  102abb:	89 44 24 18          	mov    %eax,0x18(%esp)
  102abf:	89 54 24 14          	mov    %edx,0x14(%esp)
  102ac3:	8b 45 18             	mov    0x18(%ebp),%eax
  102ac6:	89 44 24 10          	mov    %eax,0x10(%esp)
  102aca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102acd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102ad0:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ad4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  102adf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae2:	89 04 24             	mov    %eax,(%esp)
  102ae5:	e8 3d ff ff ff       	call   102a27 <printnum>
  102aea:	eb 1b                	jmp    102b07 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  102aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  102af3:	8b 45 20             	mov    0x20(%ebp),%eax
  102af6:	89 04 24             	mov    %eax,(%esp)
  102af9:	8b 45 08             	mov    0x8(%ebp),%eax
  102afc:	ff d0                	call   *%eax
        while (-- width > 0)
  102afe:	ff 4d 1c             	decl   0x1c(%ebp)
  102b01:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102b05:	7f e5                	jg     102aec <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102b07:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b0a:	05 f0 3c 10 00       	add    $0x103cf0,%eax
  102b0f:	0f b6 00             	movzbl (%eax),%eax
  102b12:	0f be c0             	movsbl %al,%eax
  102b15:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b18:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b1c:	89 04 24             	mov    %eax,(%esp)
  102b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b22:	ff d0                	call   *%eax
}
  102b24:	90                   	nop
  102b25:	89 ec                	mov    %ebp,%esp
  102b27:	5d                   	pop    %ebp
  102b28:	c3                   	ret    

00102b29 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102b29:	55                   	push   %ebp
  102b2a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102b2c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102b30:	7e 14                	jle    102b46 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102b32:	8b 45 08             	mov    0x8(%ebp),%eax
  102b35:	8b 00                	mov    (%eax),%eax
  102b37:	8d 48 08             	lea    0x8(%eax),%ecx
  102b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  102b3d:	89 0a                	mov    %ecx,(%edx)
  102b3f:	8b 50 04             	mov    0x4(%eax),%edx
  102b42:	8b 00                	mov    (%eax),%eax
  102b44:	eb 30                	jmp    102b76 <getuint+0x4d>
    }
    else if (lflag) {
  102b46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b4a:	74 16                	je     102b62 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b4f:	8b 00                	mov    (%eax),%eax
  102b51:	8d 48 04             	lea    0x4(%eax),%ecx
  102b54:	8b 55 08             	mov    0x8(%ebp),%edx
  102b57:	89 0a                	mov    %ecx,(%edx)
  102b59:	8b 00                	mov    (%eax),%eax
  102b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  102b60:	eb 14                	jmp    102b76 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102b62:	8b 45 08             	mov    0x8(%ebp),%eax
  102b65:	8b 00                	mov    (%eax),%eax
  102b67:	8d 48 04             	lea    0x4(%eax),%ecx
  102b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  102b6d:	89 0a                	mov    %ecx,(%edx)
  102b6f:	8b 00                	mov    (%eax),%eax
  102b71:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102b76:	5d                   	pop    %ebp
  102b77:	c3                   	ret    

00102b78 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102b78:	55                   	push   %ebp
  102b79:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102b7b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102b7f:	7e 14                	jle    102b95 <getint+0x1d>
        return va_arg(*ap, long long);
  102b81:	8b 45 08             	mov    0x8(%ebp),%eax
  102b84:	8b 00                	mov    (%eax),%eax
  102b86:	8d 48 08             	lea    0x8(%eax),%ecx
  102b89:	8b 55 08             	mov    0x8(%ebp),%edx
  102b8c:	89 0a                	mov    %ecx,(%edx)
  102b8e:	8b 50 04             	mov    0x4(%eax),%edx
  102b91:	8b 00                	mov    (%eax),%eax
  102b93:	eb 28                	jmp    102bbd <getint+0x45>
    }
    else if (lflag) {
  102b95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b99:	74 12                	je     102bad <getint+0x35>
        return va_arg(*ap, long);
  102b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b9e:	8b 00                	mov    (%eax),%eax
  102ba0:	8d 48 04             	lea    0x4(%eax),%ecx
  102ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  102ba6:	89 0a                	mov    %ecx,(%edx)
  102ba8:	8b 00                	mov    (%eax),%eax
  102baa:	99                   	cltd   
  102bab:	eb 10                	jmp    102bbd <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102bad:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb0:	8b 00                	mov    (%eax),%eax
  102bb2:	8d 48 04             	lea    0x4(%eax),%ecx
  102bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  102bb8:	89 0a                	mov    %ecx,(%edx)
  102bba:	8b 00                	mov    (%eax),%eax
  102bbc:	99                   	cltd   
    }
}
  102bbd:	5d                   	pop    %ebp
  102bbe:	c3                   	ret    

00102bbf <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102bbf:	55                   	push   %ebp
  102bc0:	89 e5                	mov    %esp,%ebp
  102bc2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102bc5:	8d 45 14             	lea    0x14(%ebp),%eax
  102bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  102bd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  102bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  102be0:	8b 45 08             	mov    0x8(%ebp),%eax
  102be3:	89 04 24             	mov    %eax,(%esp)
  102be6:	e8 05 00 00 00       	call   102bf0 <vprintfmt>
    va_end(ap);
}
  102beb:	90                   	nop
  102bec:	89 ec                	mov    %ebp,%esp
  102bee:	5d                   	pop    %ebp
  102bef:	c3                   	ret    

00102bf0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102bf0:	55                   	push   %ebp
  102bf1:	89 e5                	mov    %esp,%ebp
  102bf3:	56                   	push   %esi
  102bf4:	53                   	push   %ebx
  102bf5:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102bf8:	eb 17                	jmp    102c11 <vprintfmt+0x21>
            if (ch == '\0') {
  102bfa:	85 db                	test   %ebx,%ebx
  102bfc:	0f 84 bf 03 00 00    	je     102fc1 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  102c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c09:	89 1c 24             	mov    %ebx,(%esp)
  102c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102c0f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102c11:	8b 45 10             	mov    0x10(%ebp),%eax
  102c14:	8d 50 01             	lea    0x1(%eax),%edx
  102c17:	89 55 10             	mov    %edx,0x10(%ebp)
  102c1a:	0f b6 00             	movzbl (%eax),%eax
  102c1d:	0f b6 d8             	movzbl %al,%ebx
  102c20:	83 fb 25             	cmp    $0x25,%ebx
  102c23:	75 d5                	jne    102bfa <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  102c25:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102c29:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102c30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c33:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102c36:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c40:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102c43:	8b 45 10             	mov    0x10(%ebp),%eax
  102c46:	8d 50 01             	lea    0x1(%eax),%edx
  102c49:	89 55 10             	mov    %edx,0x10(%ebp)
  102c4c:	0f b6 00             	movzbl (%eax),%eax
  102c4f:	0f b6 d8             	movzbl %al,%ebx
  102c52:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102c55:	83 f8 55             	cmp    $0x55,%eax
  102c58:	0f 87 37 03 00 00    	ja     102f95 <vprintfmt+0x3a5>
  102c5e:	8b 04 85 14 3d 10 00 	mov    0x103d14(,%eax,4),%eax
  102c65:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102c67:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102c6b:	eb d6                	jmp    102c43 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102c6d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102c71:	eb d0                	jmp    102c43 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102c73:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102c7a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102c7d:	89 d0                	mov    %edx,%eax
  102c7f:	c1 e0 02             	shl    $0x2,%eax
  102c82:	01 d0                	add    %edx,%eax
  102c84:	01 c0                	add    %eax,%eax
  102c86:	01 d8                	add    %ebx,%eax
  102c88:	83 e8 30             	sub    $0x30,%eax
  102c8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102c8e:	8b 45 10             	mov    0x10(%ebp),%eax
  102c91:	0f b6 00             	movzbl (%eax),%eax
  102c94:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102c97:	83 fb 2f             	cmp    $0x2f,%ebx
  102c9a:	7e 38                	jle    102cd4 <vprintfmt+0xe4>
  102c9c:	83 fb 39             	cmp    $0x39,%ebx
  102c9f:	7f 33                	jg     102cd4 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  102ca1:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  102ca4:	eb d4                	jmp    102c7a <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  102ca6:	8b 45 14             	mov    0x14(%ebp),%eax
  102ca9:	8d 50 04             	lea    0x4(%eax),%edx
  102cac:	89 55 14             	mov    %edx,0x14(%ebp)
  102caf:	8b 00                	mov    (%eax),%eax
  102cb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102cb4:	eb 1f                	jmp    102cd5 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  102cb6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102cba:	79 87                	jns    102c43 <vprintfmt+0x53>
                width = 0;
  102cbc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102cc3:	e9 7b ff ff ff       	jmp    102c43 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  102cc8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102ccf:	e9 6f ff ff ff       	jmp    102c43 <vprintfmt+0x53>
            goto process_precision;
  102cd4:	90                   	nop

        process_precision:
            if (width < 0)
  102cd5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102cd9:	0f 89 64 ff ff ff    	jns    102c43 <vprintfmt+0x53>
                width = precision, precision = -1;
  102cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ce2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102ce5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102cec:	e9 52 ff ff ff       	jmp    102c43 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102cf1:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  102cf4:	e9 4a ff ff ff       	jmp    102c43 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102cf9:	8b 45 14             	mov    0x14(%ebp),%eax
  102cfc:	8d 50 04             	lea    0x4(%eax),%edx
  102cff:	89 55 14             	mov    %edx,0x14(%ebp)
  102d02:	8b 00                	mov    (%eax),%eax
  102d04:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d07:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d0b:	89 04 24             	mov    %eax,(%esp)
  102d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d11:	ff d0                	call   *%eax
            break;
  102d13:	e9 a4 02 00 00       	jmp    102fbc <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102d18:	8b 45 14             	mov    0x14(%ebp),%eax
  102d1b:	8d 50 04             	lea    0x4(%eax),%edx
  102d1e:	89 55 14             	mov    %edx,0x14(%ebp)
  102d21:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102d23:	85 db                	test   %ebx,%ebx
  102d25:	79 02                	jns    102d29 <vprintfmt+0x139>
                err = -err;
  102d27:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102d29:	83 fb 06             	cmp    $0x6,%ebx
  102d2c:	7f 0b                	jg     102d39 <vprintfmt+0x149>
  102d2e:	8b 34 9d d4 3c 10 00 	mov    0x103cd4(,%ebx,4),%esi
  102d35:	85 f6                	test   %esi,%esi
  102d37:	75 23                	jne    102d5c <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  102d39:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102d3d:	c7 44 24 08 01 3d 10 	movl   $0x103d01,0x8(%esp)
  102d44:	00 
  102d45:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d4f:	89 04 24             	mov    %eax,(%esp)
  102d52:	e8 68 fe ff ff       	call   102bbf <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102d57:	e9 60 02 00 00       	jmp    102fbc <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  102d5c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102d60:	c7 44 24 08 0a 3d 10 	movl   $0x103d0a,0x8(%esp)
  102d67:	00 
  102d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  102d72:	89 04 24             	mov    %eax,(%esp)
  102d75:	e8 45 fe ff ff       	call   102bbf <printfmt>
            break;
  102d7a:	e9 3d 02 00 00       	jmp    102fbc <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102d7f:	8b 45 14             	mov    0x14(%ebp),%eax
  102d82:	8d 50 04             	lea    0x4(%eax),%edx
  102d85:	89 55 14             	mov    %edx,0x14(%ebp)
  102d88:	8b 30                	mov    (%eax),%esi
  102d8a:	85 f6                	test   %esi,%esi
  102d8c:	75 05                	jne    102d93 <vprintfmt+0x1a3>
                p = "(null)";
  102d8e:	be 0d 3d 10 00       	mov    $0x103d0d,%esi
            }
            if (width > 0 && padc != '-') {
  102d93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d97:	7e 76                	jle    102e0f <vprintfmt+0x21f>
  102d99:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102d9d:	74 70                	je     102e0f <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  102da6:	89 34 24             	mov    %esi,(%esp)
  102da9:	e8 16 03 00 00       	call   1030c4 <strnlen>
  102dae:	89 c2                	mov    %eax,%edx
  102db0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102db3:	29 d0                	sub    %edx,%eax
  102db5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102db8:	eb 16                	jmp    102dd0 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  102dba:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  102dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  102dc5:	89 04 24             	mov    %eax,(%esp)
  102dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  102dcb:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  102dcd:	ff 4d e8             	decl   -0x18(%ebp)
  102dd0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102dd4:	7f e4                	jg     102dba <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102dd6:	eb 37                	jmp    102e0f <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  102dd8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102ddc:	74 1f                	je     102dfd <vprintfmt+0x20d>
  102dde:	83 fb 1f             	cmp    $0x1f,%ebx
  102de1:	7e 05                	jle    102de8 <vprintfmt+0x1f8>
  102de3:	83 fb 7e             	cmp    $0x7e,%ebx
  102de6:	7e 15                	jle    102dfd <vprintfmt+0x20d>
                    putch('?', putdat);
  102de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  102def:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102df6:	8b 45 08             	mov    0x8(%ebp),%eax
  102df9:	ff d0                	call   *%eax
  102dfb:	eb 0f                	jmp    102e0c <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  102dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e04:	89 1c 24             	mov    %ebx,(%esp)
  102e07:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102e0c:	ff 4d e8             	decl   -0x18(%ebp)
  102e0f:	89 f0                	mov    %esi,%eax
  102e11:	8d 70 01             	lea    0x1(%eax),%esi
  102e14:	0f b6 00             	movzbl (%eax),%eax
  102e17:	0f be d8             	movsbl %al,%ebx
  102e1a:	85 db                	test   %ebx,%ebx
  102e1c:	74 27                	je     102e45 <vprintfmt+0x255>
  102e1e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e22:	78 b4                	js     102dd8 <vprintfmt+0x1e8>
  102e24:	ff 4d e4             	decl   -0x1c(%ebp)
  102e27:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e2b:	79 ab                	jns    102dd8 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  102e2d:	eb 16                	jmp    102e45 <vprintfmt+0x255>
                putch(' ', putdat);
  102e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e32:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e36:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  102e40:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  102e42:	ff 4d e8             	decl   -0x18(%ebp)
  102e45:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e49:	7f e4                	jg     102e2f <vprintfmt+0x23f>
            }
            break;
  102e4b:	e9 6c 01 00 00       	jmp    102fbc <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102e50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e53:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e57:	8d 45 14             	lea    0x14(%ebp),%eax
  102e5a:	89 04 24             	mov    %eax,(%esp)
  102e5d:	e8 16 fd ff ff       	call   102b78 <getint>
  102e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e65:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e6e:	85 d2                	test   %edx,%edx
  102e70:	79 26                	jns    102e98 <vprintfmt+0x2a8>
                putch('-', putdat);
  102e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e75:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e79:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  102e80:	8b 45 08             	mov    0x8(%ebp),%eax
  102e83:	ff d0                	call   *%eax
                num = -(long long)num;
  102e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e8b:	f7 d8                	neg    %eax
  102e8d:	83 d2 00             	adc    $0x0,%edx
  102e90:	f7 da                	neg    %edx
  102e92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e95:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  102e98:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102e9f:	e9 a8 00 00 00       	jmp    102f4c <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  102ea4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eab:	8d 45 14             	lea    0x14(%ebp),%eax
  102eae:	89 04 24             	mov    %eax,(%esp)
  102eb1:	e8 73 fc ff ff       	call   102b29 <getuint>
  102eb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102eb9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  102ebc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102ec3:	e9 84 00 00 00       	jmp    102f4c <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  102ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ecf:	8d 45 14             	lea    0x14(%ebp),%eax
  102ed2:	89 04 24             	mov    %eax,(%esp)
  102ed5:	e8 4f fc ff ff       	call   102b29 <getuint>
  102eda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102edd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  102ee0:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  102ee7:	eb 63                	jmp    102f4c <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  102ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eec:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ef0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  102ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  102efa:	ff d0                	call   *%eax
            putch('x', putdat);
  102efc:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eff:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f03:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  102f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f0d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  102f0f:	8b 45 14             	mov    0x14(%ebp),%eax
  102f12:	8d 50 04             	lea    0x4(%eax),%edx
  102f15:	89 55 14             	mov    %edx,0x14(%ebp)
  102f18:	8b 00                	mov    (%eax),%eax
  102f1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  102f24:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  102f2b:	eb 1f                	jmp    102f4c <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  102f2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f30:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f34:	8d 45 14             	lea    0x14(%ebp),%eax
  102f37:	89 04 24             	mov    %eax,(%esp)
  102f3a:	e8 ea fb ff ff       	call   102b29 <getuint>
  102f3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f42:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  102f45:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  102f4c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  102f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f53:	89 54 24 18          	mov    %edx,0x18(%esp)
  102f57:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102f5a:	89 54 24 14          	mov    %edx,0x14(%esp)
  102f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  102f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f68:	89 44 24 08          	mov    %eax,0x8(%esp)
  102f6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102f70:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f73:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f77:	8b 45 08             	mov    0x8(%ebp),%eax
  102f7a:	89 04 24             	mov    %eax,(%esp)
  102f7d:	e8 a5 fa ff ff       	call   102a27 <printnum>
            break;
  102f82:	eb 38                	jmp    102fbc <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  102f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f8b:	89 1c 24             	mov    %ebx,(%esp)
  102f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f91:	ff d0                	call   *%eax
            break;
  102f93:	eb 27                	jmp    102fbc <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  102f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f9c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  102fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  102fa6:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  102fa8:	ff 4d 10             	decl   0x10(%ebp)
  102fab:	eb 03                	jmp    102fb0 <vprintfmt+0x3c0>
  102fad:	ff 4d 10             	decl   0x10(%ebp)
  102fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  102fb3:	48                   	dec    %eax
  102fb4:	0f b6 00             	movzbl (%eax),%eax
  102fb7:	3c 25                	cmp    $0x25,%al
  102fb9:	75 f2                	jne    102fad <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  102fbb:	90                   	nop
    while (1) {
  102fbc:	e9 37 fc ff ff       	jmp    102bf8 <vprintfmt+0x8>
                return;
  102fc1:	90                   	nop
        }
    }
}
  102fc2:	83 c4 40             	add    $0x40,%esp
  102fc5:	5b                   	pop    %ebx
  102fc6:	5e                   	pop    %esi
  102fc7:	5d                   	pop    %ebp
  102fc8:	c3                   	ret    

00102fc9 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  102fc9:	55                   	push   %ebp
  102fca:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  102fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fcf:	8b 40 08             	mov    0x8(%eax),%eax
  102fd2:	8d 50 01             	lea    0x1(%eax),%edx
  102fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fd8:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  102fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fde:	8b 10                	mov    (%eax),%edx
  102fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fe3:	8b 40 04             	mov    0x4(%eax),%eax
  102fe6:	39 c2                	cmp    %eax,%edx
  102fe8:	73 12                	jae    102ffc <sprintputch+0x33>
        *b->buf ++ = ch;
  102fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fed:	8b 00                	mov    (%eax),%eax
  102fef:	8d 48 01             	lea    0x1(%eax),%ecx
  102ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ff5:	89 0a                	mov    %ecx,(%edx)
  102ff7:	8b 55 08             	mov    0x8(%ebp),%edx
  102ffa:	88 10                	mov    %dl,(%eax)
    }
}
  102ffc:	90                   	nop
  102ffd:	5d                   	pop    %ebp
  102ffe:	c3                   	ret    

00102fff <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  102fff:	55                   	push   %ebp
  103000:	89 e5                	mov    %esp,%ebp
  103002:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  103005:	8d 45 14             	lea    0x14(%ebp),%eax
  103008:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  10300b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10300e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103012:	8b 45 10             	mov    0x10(%ebp),%eax
  103015:	89 44 24 08          	mov    %eax,0x8(%esp)
  103019:	8b 45 0c             	mov    0xc(%ebp),%eax
  10301c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103020:	8b 45 08             	mov    0x8(%ebp),%eax
  103023:	89 04 24             	mov    %eax,(%esp)
  103026:	e8 0a 00 00 00       	call   103035 <vsnprintf>
  10302b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10302e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103031:	89 ec                	mov    %ebp,%esp
  103033:	5d                   	pop    %ebp
  103034:	c3                   	ret    

00103035 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103035:	55                   	push   %ebp
  103036:	89 e5                	mov    %esp,%ebp
  103038:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10303b:	8b 45 08             	mov    0x8(%ebp),%eax
  10303e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103041:	8b 45 0c             	mov    0xc(%ebp),%eax
  103044:	8d 50 ff             	lea    -0x1(%eax),%edx
  103047:	8b 45 08             	mov    0x8(%ebp),%eax
  10304a:	01 d0                	add    %edx,%eax
  10304c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10304f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103056:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10305a:	74 0a                	je     103066 <vsnprintf+0x31>
  10305c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10305f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103062:	39 c2                	cmp    %eax,%edx
  103064:	76 07                	jbe    10306d <vsnprintf+0x38>
        return -E_INVAL;
  103066:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10306b:	eb 2a                	jmp    103097 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  10306d:	8b 45 14             	mov    0x14(%ebp),%eax
  103070:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103074:	8b 45 10             	mov    0x10(%ebp),%eax
  103077:	89 44 24 08          	mov    %eax,0x8(%esp)
  10307b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  10307e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103082:	c7 04 24 c9 2f 10 00 	movl   $0x102fc9,(%esp)
  103089:	e8 62 fb ff ff       	call   102bf0 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  10308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103091:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103094:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103097:	89 ec                	mov    %ebp,%esp
  103099:	5d                   	pop    %ebp
  10309a:	c3                   	ret    

0010309b <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10309b:	55                   	push   %ebp
  10309c:	89 e5                	mov    %esp,%ebp
  10309e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1030a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1030a8:	eb 03                	jmp    1030ad <strlen+0x12>
        cnt ++;
  1030aa:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1030ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1030b0:	8d 50 01             	lea    0x1(%eax),%edx
  1030b3:	89 55 08             	mov    %edx,0x8(%ebp)
  1030b6:	0f b6 00             	movzbl (%eax),%eax
  1030b9:	84 c0                	test   %al,%al
  1030bb:	75 ed                	jne    1030aa <strlen+0xf>
    }
    return cnt;
  1030bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1030c0:	89 ec                	mov    %ebp,%esp
  1030c2:	5d                   	pop    %ebp
  1030c3:	c3                   	ret    

001030c4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1030c4:	55                   	push   %ebp
  1030c5:	89 e5                	mov    %esp,%ebp
  1030c7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1030ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1030d1:	eb 03                	jmp    1030d6 <strnlen+0x12>
        cnt ++;
  1030d3:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1030d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1030d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1030dc:	73 10                	jae    1030ee <strnlen+0x2a>
  1030de:	8b 45 08             	mov    0x8(%ebp),%eax
  1030e1:	8d 50 01             	lea    0x1(%eax),%edx
  1030e4:	89 55 08             	mov    %edx,0x8(%ebp)
  1030e7:	0f b6 00             	movzbl (%eax),%eax
  1030ea:	84 c0                	test   %al,%al
  1030ec:	75 e5                	jne    1030d3 <strnlen+0xf>
    }
    return cnt;
  1030ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1030f1:	89 ec                	mov    %ebp,%esp
  1030f3:	5d                   	pop    %ebp
  1030f4:	c3                   	ret    

001030f5 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1030f5:	55                   	push   %ebp
  1030f6:	89 e5                	mov    %esp,%ebp
  1030f8:	57                   	push   %edi
  1030f9:	56                   	push   %esi
  1030fa:	83 ec 20             	sub    $0x20,%esp
  1030fd:	8b 45 08             	mov    0x8(%ebp),%eax
  103100:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103103:	8b 45 0c             	mov    0xc(%ebp),%eax
  103106:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  103109:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10310c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10310f:	89 d1                	mov    %edx,%ecx
  103111:	89 c2                	mov    %eax,%edx
  103113:	89 ce                	mov    %ecx,%esi
  103115:	89 d7                	mov    %edx,%edi
  103117:	ac                   	lods   %ds:(%esi),%al
  103118:	aa                   	stos   %al,%es:(%edi)
  103119:	84 c0                	test   %al,%al
  10311b:	75 fa                	jne    103117 <strcpy+0x22>
  10311d:	89 fa                	mov    %edi,%edx
  10311f:	89 f1                	mov    %esi,%ecx
  103121:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  103124:	89 55 e8             	mov    %edx,-0x18(%ebp)
  103127:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  10312a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10312d:	83 c4 20             	add    $0x20,%esp
  103130:	5e                   	pop    %esi
  103131:	5f                   	pop    %edi
  103132:	5d                   	pop    %ebp
  103133:	c3                   	ret    

00103134 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  103134:	55                   	push   %ebp
  103135:	89 e5                	mov    %esp,%ebp
  103137:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  10313a:	8b 45 08             	mov    0x8(%ebp),%eax
  10313d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  103140:	eb 1e                	jmp    103160 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  103142:	8b 45 0c             	mov    0xc(%ebp),%eax
  103145:	0f b6 10             	movzbl (%eax),%edx
  103148:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10314b:	88 10                	mov    %dl,(%eax)
  10314d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103150:	0f b6 00             	movzbl (%eax),%eax
  103153:	84 c0                	test   %al,%al
  103155:	74 03                	je     10315a <strncpy+0x26>
            src ++;
  103157:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  10315a:	ff 45 fc             	incl   -0x4(%ebp)
  10315d:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  103160:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103164:	75 dc                	jne    103142 <strncpy+0xe>
    }
    return dst;
  103166:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103169:	89 ec                	mov    %ebp,%esp
  10316b:	5d                   	pop    %ebp
  10316c:	c3                   	ret    

0010316d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10316d:	55                   	push   %ebp
  10316e:	89 e5                	mov    %esp,%ebp
  103170:	57                   	push   %edi
  103171:	56                   	push   %esi
  103172:	83 ec 20             	sub    $0x20,%esp
  103175:	8b 45 08             	mov    0x8(%ebp),%eax
  103178:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10317b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10317e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  103181:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103187:	89 d1                	mov    %edx,%ecx
  103189:	89 c2                	mov    %eax,%edx
  10318b:	89 ce                	mov    %ecx,%esi
  10318d:	89 d7                	mov    %edx,%edi
  10318f:	ac                   	lods   %ds:(%esi),%al
  103190:	ae                   	scas   %es:(%edi),%al
  103191:	75 08                	jne    10319b <strcmp+0x2e>
  103193:	84 c0                	test   %al,%al
  103195:	75 f8                	jne    10318f <strcmp+0x22>
  103197:	31 c0                	xor    %eax,%eax
  103199:	eb 04                	jmp    10319f <strcmp+0x32>
  10319b:	19 c0                	sbb    %eax,%eax
  10319d:	0c 01                	or     $0x1,%al
  10319f:	89 fa                	mov    %edi,%edx
  1031a1:	89 f1                	mov    %esi,%ecx
  1031a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031a6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1031a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1031ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1031af:	83 c4 20             	add    $0x20,%esp
  1031b2:	5e                   	pop    %esi
  1031b3:	5f                   	pop    %edi
  1031b4:	5d                   	pop    %ebp
  1031b5:	c3                   	ret    

001031b6 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1031b6:	55                   	push   %ebp
  1031b7:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1031b9:	eb 09                	jmp    1031c4 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1031bb:	ff 4d 10             	decl   0x10(%ebp)
  1031be:	ff 45 08             	incl   0x8(%ebp)
  1031c1:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1031c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1031c8:	74 1a                	je     1031e4 <strncmp+0x2e>
  1031ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1031cd:	0f b6 00             	movzbl (%eax),%eax
  1031d0:	84 c0                	test   %al,%al
  1031d2:	74 10                	je     1031e4 <strncmp+0x2e>
  1031d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1031d7:	0f b6 10             	movzbl (%eax),%edx
  1031da:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031dd:	0f b6 00             	movzbl (%eax),%eax
  1031e0:	38 c2                	cmp    %al,%dl
  1031e2:	74 d7                	je     1031bb <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1031e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1031e8:	74 18                	je     103202 <strncmp+0x4c>
  1031ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ed:	0f b6 00             	movzbl (%eax),%eax
  1031f0:	0f b6 d0             	movzbl %al,%edx
  1031f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031f6:	0f b6 00             	movzbl (%eax),%eax
  1031f9:	0f b6 c8             	movzbl %al,%ecx
  1031fc:	89 d0                	mov    %edx,%eax
  1031fe:	29 c8                	sub    %ecx,%eax
  103200:	eb 05                	jmp    103207 <strncmp+0x51>
  103202:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103207:	5d                   	pop    %ebp
  103208:	c3                   	ret    

00103209 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  103209:	55                   	push   %ebp
  10320a:	89 e5                	mov    %esp,%ebp
  10320c:	83 ec 04             	sub    $0x4,%esp
  10320f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103212:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103215:	eb 13                	jmp    10322a <strchr+0x21>
        if (*s == c) {
  103217:	8b 45 08             	mov    0x8(%ebp),%eax
  10321a:	0f b6 00             	movzbl (%eax),%eax
  10321d:	38 45 fc             	cmp    %al,-0x4(%ebp)
  103220:	75 05                	jne    103227 <strchr+0x1e>
            return (char *)s;
  103222:	8b 45 08             	mov    0x8(%ebp),%eax
  103225:	eb 12                	jmp    103239 <strchr+0x30>
        }
        s ++;
  103227:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  10322a:	8b 45 08             	mov    0x8(%ebp),%eax
  10322d:	0f b6 00             	movzbl (%eax),%eax
  103230:	84 c0                	test   %al,%al
  103232:	75 e3                	jne    103217 <strchr+0xe>
    }
    return NULL;
  103234:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103239:	89 ec                	mov    %ebp,%esp
  10323b:	5d                   	pop    %ebp
  10323c:	c3                   	ret    

0010323d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10323d:	55                   	push   %ebp
  10323e:	89 e5                	mov    %esp,%ebp
  103240:	83 ec 04             	sub    $0x4,%esp
  103243:	8b 45 0c             	mov    0xc(%ebp),%eax
  103246:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103249:	eb 0e                	jmp    103259 <strfind+0x1c>
        if (*s == c) {
  10324b:	8b 45 08             	mov    0x8(%ebp),%eax
  10324e:	0f b6 00             	movzbl (%eax),%eax
  103251:	38 45 fc             	cmp    %al,-0x4(%ebp)
  103254:	74 0f                	je     103265 <strfind+0x28>
            break;
        }
        s ++;
  103256:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  103259:	8b 45 08             	mov    0x8(%ebp),%eax
  10325c:	0f b6 00             	movzbl (%eax),%eax
  10325f:	84 c0                	test   %al,%al
  103261:	75 e8                	jne    10324b <strfind+0xe>
  103263:	eb 01                	jmp    103266 <strfind+0x29>
            break;
  103265:	90                   	nop
    }
    return (char *)s;
  103266:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103269:	89 ec                	mov    %ebp,%esp
  10326b:	5d                   	pop    %ebp
  10326c:	c3                   	ret    

0010326d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10326d:	55                   	push   %ebp
  10326e:	89 e5                	mov    %esp,%ebp
  103270:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  103273:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  10327a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  103281:	eb 03                	jmp    103286 <strtol+0x19>
        s ++;
  103283:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  103286:	8b 45 08             	mov    0x8(%ebp),%eax
  103289:	0f b6 00             	movzbl (%eax),%eax
  10328c:	3c 20                	cmp    $0x20,%al
  10328e:	74 f3                	je     103283 <strtol+0x16>
  103290:	8b 45 08             	mov    0x8(%ebp),%eax
  103293:	0f b6 00             	movzbl (%eax),%eax
  103296:	3c 09                	cmp    $0x9,%al
  103298:	74 e9                	je     103283 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  10329a:	8b 45 08             	mov    0x8(%ebp),%eax
  10329d:	0f b6 00             	movzbl (%eax),%eax
  1032a0:	3c 2b                	cmp    $0x2b,%al
  1032a2:	75 05                	jne    1032a9 <strtol+0x3c>
        s ++;
  1032a4:	ff 45 08             	incl   0x8(%ebp)
  1032a7:	eb 14                	jmp    1032bd <strtol+0x50>
    }
    else if (*s == '-') {
  1032a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ac:	0f b6 00             	movzbl (%eax),%eax
  1032af:	3c 2d                	cmp    $0x2d,%al
  1032b1:	75 0a                	jne    1032bd <strtol+0x50>
        s ++, neg = 1;
  1032b3:	ff 45 08             	incl   0x8(%ebp)
  1032b6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1032bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032c1:	74 06                	je     1032c9 <strtol+0x5c>
  1032c3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1032c7:	75 22                	jne    1032eb <strtol+0x7e>
  1032c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1032cc:	0f b6 00             	movzbl (%eax),%eax
  1032cf:	3c 30                	cmp    $0x30,%al
  1032d1:	75 18                	jne    1032eb <strtol+0x7e>
  1032d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1032d6:	40                   	inc    %eax
  1032d7:	0f b6 00             	movzbl (%eax),%eax
  1032da:	3c 78                	cmp    $0x78,%al
  1032dc:	75 0d                	jne    1032eb <strtol+0x7e>
        s += 2, base = 16;
  1032de:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1032e2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1032e9:	eb 29                	jmp    103314 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1032eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032ef:	75 16                	jne    103307 <strtol+0x9a>
  1032f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f4:	0f b6 00             	movzbl (%eax),%eax
  1032f7:	3c 30                	cmp    $0x30,%al
  1032f9:	75 0c                	jne    103307 <strtol+0x9a>
        s ++, base = 8;
  1032fb:	ff 45 08             	incl   0x8(%ebp)
  1032fe:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  103305:	eb 0d                	jmp    103314 <strtol+0xa7>
    }
    else if (base == 0) {
  103307:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10330b:	75 07                	jne    103314 <strtol+0xa7>
        base = 10;
  10330d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  103314:	8b 45 08             	mov    0x8(%ebp),%eax
  103317:	0f b6 00             	movzbl (%eax),%eax
  10331a:	3c 2f                	cmp    $0x2f,%al
  10331c:	7e 1b                	jle    103339 <strtol+0xcc>
  10331e:	8b 45 08             	mov    0x8(%ebp),%eax
  103321:	0f b6 00             	movzbl (%eax),%eax
  103324:	3c 39                	cmp    $0x39,%al
  103326:	7f 11                	jg     103339 <strtol+0xcc>
            dig = *s - '0';
  103328:	8b 45 08             	mov    0x8(%ebp),%eax
  10332b:	0f b6 00             	movzbl (%eax),%eax
  10332e:	0f be c0             	movsbl %al,%eax
  103331:	83 e8 30             	sub    $0x30,%eax
  103334:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103337:	eb 48                	jmp    103381 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  103339:	8b 45 08             	mov    0x8(%ebp),%eax
  10333c:	0f b6 00             	movzbl (%eax),%eax
  10333f:	3c 60                	cmp    $0x60,%al
  103341:	7e 1b                	jle    10335e <strtol+0xf1>
  103343:	8b 45 08             	mov    0x8(%ebp),%eax
  103346:	0f b6 00             	movzbl (%eax),%eax
  103349:	3c 7a                	cmp    $0x7a,%al
  10334b:	7f 11                	jg     10335e <strtol+0xf1>
            dig = *s - 'a' + 10;
  10334d:	8b 45 08             	mov    0x8(%ebp),%eax
  103350:	0f b6 00             	movzbl (%eax),%eax
  103353:	0f be c0             	movsbl %al,%eax
  103356:	83 e8 57             	sub    $0x57,%eax
  103359:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10335c:	eb 23                	jmp    103381 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10335e:	8b 45 08             	mov    0x8(%ebp),%eax
  103361:	0f b6 00             	movzbl (%eax),%eax
  103364:	3c 40                	cmp    $0x40,%al
  103366:	7e 3b                	jle    1033a3 <strtol+0x136>
  103368:	8b 45 08             	mov    0x8(%ebp),%eax
  10336b:	0f b6 00             	movzbl (%eax),%eax
  10336e:	3c 5a                	cmp    $0x5a,%al
  103370:	7f 31                	jg     1033a3 <strtol+0x136>
            dig = *s - 'A' + 10;
  103372:	8b 45 08             	mov    0x8(%ebp),%eax
  103375:	0f b6 00             	movzbl (%eax),%eax
  103378:	0f be c0             	movsbl %al,%eax
  10337b:	83 e8 37             	sub    $0x37,%eax
  10337e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  103381:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103384:	3b 45 10             	cmp    0x10(%ebp),%eax
  103387:	7d 19                	jge    1033a2 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  103389:	ff 45 08             	incl   0x8(%ebp)
  10338c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10338f:	0f af 45 10          	imul   0x10(%ebp),%eax
  103393:	89 c2                	mov    %eax,%edx
  103395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103398:	01 d0                	add    %edx,%eax
  10339a:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  10339d:	e9 72 ff ff ff       	jmp    103314 <strtol+0xa7>
            break;
  1033a2:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1033a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1033a7:	74 08                	je     1033b1 <strtol+0x144>
        *endptr = (char *) s;
  1033a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033ac:	8b 55 08             	mov    0x8(%ebp),%edx
  1033af:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1033b1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1033b5:	74 07                	je     1033be <strtol+0x151>
  1033b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1033ba:	f7 d8                	neg    %eax
  1033bc:	eb 03                	jmp    1033c1 <strtol+0x154>
  1033be:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1033c1:	89 ec                	mov    %ebp,%esp
  1033c3:	5d                   	pop    %ebp
  1033c4:	c3                   	ret    

001033c5 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1033c5:	55                   	push   %ebp
  1033c6:	89 e5                	mov    %esp,%ebp
  1033c8:	83 ec 28             	sub    $0x28,%esp
  1033cb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1033ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033d1:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1033d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  1033d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033db:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1033de:	88 55 f7             	mov    %dl,-0x9(%ebp)
  1033e1:	8b 45 10             	mov    0x10(%ebp),%eax
  1033e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1033e7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1033ea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1033ee:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1033f1:	89 d7                	mov    %edx,%edi
  1033f3:	f3 aa                	rep stos %al,%es:(%edi)
  1033f5:	89 fa                	mov    %edi,%edx
  1033f7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1033fa:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  1033fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  103400:	8b 7d fc             	mov    -0x4(%ebp),%edi
  103403:	89 ec                	mov    %ebp,%esp
  103405:	5d                   	pop    %ebp
  103406:	c3                   	ret    

00103407 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  103407:	55                   	push   %ebp
  103408:	89 e5                	mov    %esp,%ebp
  10340a:	57                   	push   %edi
  10340b:	56                   	push   %esi
  10340c:	53                   	push   %ebx
  10340d:	83 ec 30             	sub    $0x30,%esp
  103410:	8b 45 08             	mov    0x8(%ebp),%eax
  103413:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103416:	8b 45 0c             	mov    0xc(%ebp),%eax
  103419:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10341c:	8b 45 10             	mov    0x10(%ebp),%eax
  10341f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  103422:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103425:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103428:	73 42                	jae    10346c <memmove+0x65>
  10342a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10342d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103430:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103436:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103439:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10343c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10343f:	c1 e8 02             	shr    $0x2,%eax
  103442:	89 c1                	mov    %eax,%ecx
    asm volatile (
  103444:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103447:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10344a:	89 d7                	mov    %edx,%edi
  10344c:	89 c6                	mov    %eax,%esi
  10344e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103450:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  103453:	83 e1 03             	and    $0x3,%ecx
  103456:	74 02                	je     10345a <memmove+0x53>
  103458:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10345a:	89 f0                	mov    %esi,%eax
  10345c:	89 fa                	mov    %edi,%edx
  10345e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  103461:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103464:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  103467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  10346a:	eb 36                	jmp    1034a2 <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10346c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10346f:	8d 50 ff             	lea    -0x1(%eax),%edx
  103472:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103475:	01 c2                	add    %eax,%edx
  103477:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10347a:	8d 48 ff             	lea    -0x1(%eax),%ecx
  10347d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103480:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  103483:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103486:	89 c1                	mov    %eax,%ecx
  103488:	89 d8                	mov    %ebx,%eax
  10348a:	89 d6                	mov    %edx,%esi
  10348c:	89 c7                	mov    %eax,%edi
  10348e:	fd                   	std    
  10348f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103491:	fc                   	cld    
  103492:	89 f8                	mov    %edi,%eax
  103494:	89 f2                	mov    %esi,%edx
  103496:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  103499:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10349c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10349f:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1034a2:	83 c4 30             	add    $0x30,%esp
  1034a5:	5b                   	pop    %ebx
  1034a6:	5e                   	pop    %esi
  1034a7:	5f                   	pop    %edi
  1034a8:	5d                   	pop    %ebp
  1034a9:	c3                   	ret    

001034aa <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1034aa:	55                   	push   %ebp
  1034ab:	89 e5                	mov    %esp,%ebp
  1034ad:	57                   	push   %edi
  1034ae:	56                   	push   %esi
  1034af:	83 ec 20             	sub    $0x20,%esp
  1034b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1034b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034be:	8b 45 10             	mov    0x10(%ebp),%eax
  1034c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1034c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034c7:	c1 e8 02             	shr    $0x2,%eax
  1034ca:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1034cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1034cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034d2:	89 d7                	mov    %edx,%edi
  1034d4:	89 c6                	mov    %eax,%esi
  1034d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1034d8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1034db:	83 e1 03             	and    $0x3,%ecx
  1034de:	74 02                	je     1034e2 <memcpy+0x38>
  1034e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1034e2:	89 f0                	mov    %esi,%eax
  1034e4:	89 fa                	mov    %edi,%edx
  1034e6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1034e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1034ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1034ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1034f2:	83 c4 20             	add    $0x20,%esp
  1034f5:	5e                   	pop    %esi
  1034f6:	5f                   	pop    %edi
  1034f7:	5d                   	pop    %ebp
  1034f8:	c3                   	ret    

001034f9 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1034f9:	55                   	push   %ebp
  1034fa:	89 e5                	mov    %esp,%ebp
  1034fc:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1034ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103502:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  103505:	8b 45 0c             	mov    0xc(%ebp),%eax
  103508:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10350b:	eb 2e                	jmp    10353b <memcmp+0x42>
        if (*s1 != *s2) {
  10350d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103510:	0f b6 10             	movzbl (%eax),%edx
  103513:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103516:	0f b6 00             	movzbl (%eax),%eax
  103519:	38 c2                	cmp    %al,%dl
  10351b:	74 18                	je     103535 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  10351d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103520:	0f b6 00             	movzbl (%eax),%eax
  103523:	0f b6 d0             	movzbl %al,%edx
  103526:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103529:	0f b6 00             	movzbl (%eax),%eax
  10352c:	0f b6 c8             	movzbl %al,%ecx
  10352f:	89 d0                	mov    %edx,%eax
  103531:	29 c8                	sub    %ecx,%eax
  103533:	eb 18                	jmp    10354d <memcmp+0x54>
        }
        s1 ++, s2 ++;
  103535:	ff 45 fc             	incl   -0x4(%ebp)
  103538:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  10353b:	8b 45 10             	mov    0x10(%ebp),%eax
  10353e:	8d 50 ff             	lea    -0x1(%eax),%edx
  103541:	89 55 10             	mov    %edx,0x10(%ebp)
  103544:	85 c0                	test   %eax,%eax
  103546:	75 c5                	jne    10350d <memcmp+0x14>
    }
    return 0;
  103548:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10354d:	89 ec                	mov    %ebp,%esp
  10354f:	5d                   	pop    %ebp
  103550:	c3                   	ret    
