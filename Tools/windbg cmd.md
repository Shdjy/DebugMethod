一、.symfix
.symfix
作用：配置微软符号服务器
等价于：.sympath srv*
实际会设置：SRV*https://msdl.microsoft.com/download/symbols
为什么需要它：
dump 中会涉及：dump 包含：
  ntdll
  kernel32内核32
  ucrtbase
这些系统 DLL。没有微软符号，调用栈会乱。
执行后效果你会看到：Symbol search path is: srv*

二、.sympath+ 路径
.sympath+ C:\xxx\Debug
作用：添加你自己的 pdb 搜索路径
这里：+，表示：追加不是覆盖。
为什么需要它：.symfix，只会找微软系统符号，不会找：你的pdb，exe，dll
执行后会变成：srv*;C:\xxx\Debug
表示：WinDbg：先找本地 pdb。首先查找本地 pdb。找不到再去微软服务器。

三、.reload
.reload
作用：重新加载所有模块符号
.reload
它实际干了什么
例如：
  Server.exe
  Algo.dll
  ntdll.dll
WinDbg 会重新：找 pdb，匹配 GUID，加载符号载入符号，建立源码映射

四、!analyze -v
!analyze -v
作用：自动分析崩溃，这是 WinDbg 最核心命令。

五、.ecxr
.ecxr
作用：恢复异常现场上下文，它会恢复崩溃瞬间 CPU 状态包括：
  rsp
  rip撕裂
  rcx
  栈堆
  调用链
没有 .ecxr，你看到的k，很多时候是假栈

六、kp
kp
作用：查看调用栈（带参数），这通常就是真正崩溃点。


总结：这五条命令整体流程
第一步
.symfix
配置系统符号。
第二步
.sympath+ xxx
配置自己 pdb。
第三步
.reload
重新加载符号。重新载入符号。
第四步
!analyze -v
自动分析崩溃。
第五步
.ecxr
恢复崩溃现场。
第六步
kp
查看真正调用栈。
