在c#程序中调试到C++生成的Dll中
1.断点调试
（1）c++DLL选择Debug模式，确保生成了.pdb文件

（2）设置c#项目属性
	右键 C#项目→属性→调试。
	启动外部程序→选择你的 C#可执行文件。
	工作目录 →确保 DLL 在可访问路径。符号(.pdb) 文件路径 → VS 会自动加载 DLL 的 PDB，只要 DLL 和 PDB 在相同目录。
	调试程序引擎勾选->启用本地代码调试。
	
2.排查问题->生成Dump文件

（1）Dll程序入口添加
```cpp
// dllmain.cpp : 定义 DLL 应用程序的入口点。
#include "pch.h"
#include <windows.h>
#include <DbgHelp.h>
#pragma comment(lib, "Dbghelp.lib")

LONG WINAPI MyUnhandledExceptionFilter(EXCEPTION_POINTERS* pExceptionInfo)
{
	// 生成 dump 文件
	HANDLE hFile = CreateFile(L"CrashDump.dmp",
		GENERIC_WRITE,
		0,
		nullptr,
		CREATE_ALWAYS,
		FILE_ATTRIBUTE_NORMAL,
		nullptr);

	if (hFile != INVALID_HANDLE_VALUE)
	{
		MINIDUMP_EXCEPTION_INFORMATION dumpInfo;
		dumpInfo.ThreadId = GetCurrentThreadId();
		dumpInfo.ExceptionPointers = pExceptionInfo;
		dumpInfo.ClientPointers = FALSE;

		MINIDUMP_TYPE dumpType = static_cast<MINIDUMP_TYPE>(
			MiniDumpWithFullMemory | MiniDumpWithDataSegs | MiniDumpWithHandleData
			);

		MiniDumpWriteDump(GetCurrentProcess(),
			GetCurrentProcessId(),
			hFile,
			dumpType,
			&dumpInfo,
			nullptr,
			nullptr);

		CloseHandle(hFile);
	}

	return EXCEPTION_EXECUTE_HANDLER;
}

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		// 注册全局未处理异常处理器
		SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);
		break;
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}
```

（2）当dll中出现异常中断时会在程序目录生成.dmp 文件，用vs打开该文件。

（3）VS 会提示选择 调试类型：
	对于 .NET 程序 → 选择 混合模式调试 (.NET + 本机)。
	对于 C++ DLL → 选择 本机代码。
	
3.远程调试
	目标机上安装msvsmon.exe管理员运行，工具->无身份验证+允许任何用户进行调试。启动待调试程序。
	调试机上管理员启动vs，打开项目：调试->调试->附加到进程->连接类型：远程Windows,连接目标：目标IP：端口（4026）；选择进程。

