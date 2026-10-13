# Final Audit Matrix 明细（FL-002 T-27）

依据：`DESIGN.md` §67 九列 + `audit-model.md` §2。生成时点：2026-10-13。

| Req | Title | AC 数 | AC 清单 | Source | SPEC 落点 | Task 落点 | Code 落点 | Test 落点 | Review | Runtime | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| REQ-D | 生成 SPEC —— 能生成 SPEC | 4 | AC-D1、AC-D2、AC-D3、AC-D4 | SRC-101/SRC-102/SRC-204/SRC-301/SRC-205/SRC-201 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-E | 生成 Plan —— 能生成 Plan | 4 | AC-E1、AC-E2、AC-E3、AC-E4 | SRC-101/SRC-102/SRC-108/SRC-203 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-L | Final Audit —— 能执行 Final Audit | 5 | AC-L1、AC-L2、AC-L3、AC-L4、AC-L5 | SRC-101/SRC-103/SRC-106/SRC-107/SRC-202/SRC-504/SRC-501 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-M | Audit Repair Loop —— 能继续修复 Audit Findings | 5 | AC-M1、AC-M2、AC-M3、AC-M4、AC-M5 | SRC-101/SRC-103/SRC-105/SRC-402/SRC-403/SRC-302 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-N | Release —— 能进入 Release | 5 | AC-N1、AC-N2、AC-N3、AC-N4、AC-N5 | SRC-101/SRC-104/SRC-401/SRC-404/SRC-601/SRC-502/SRC-503/SRC-602 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-001 | Document Discovery —— 能读取文档 | 1 | AC-001 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-002 | Requirement Extraction —— 能建立 Requirement | 3 | AC-002、AC-003、AC-004 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-003 | MVP Scope —— 能执行 MVP Scope | 2 | AC-005、AC-006 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-004 | Single Task Iteration —— 能执行单 Task Iteration | 2 | AC-007、AC-008 | SRC-001/SRC-004 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-005 | Test —— 能测试 | 1 | AC-009 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-006 | Code Review —— 能 Review | 1 | AC-010 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-007 | Requirement Verification —— 能验证 Requirement | 1 | AC-011 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-008 | Git Checkpoint —— 能形成 Git Checkpoint | 1 | AC-012 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
| REQ-009 | Recovery —— 能恢复中断状态 | 1 | AC-013 | SRC-001 | SPEC R 区 | tasks.md 条目 | 见 e2e 判据 | 自检断言 | 自审 | 自检 exit 0 | VERIFIED |
