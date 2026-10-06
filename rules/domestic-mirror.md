# ForgeLoop Domestic Mirror Rules

## 1. Purpose

在拉取外部资源（模型、依赖包、Git 仓库、容器镜像等）时，优先使用国内镜像，以获得更快、更稳定的结果。

前提是镜像可用且内容与上游一致。

---

## 2. Scope

本 Rule 适用于所有需要从外部网络获取资源的动作，包括但不限于：

```text
Model / Dataset 下载
Python 包
Node 包
Conda 环境与包
Git 仓库
容器镜像
通用 HTTP 下载
```

---

## 3. Model And Dataset

HuggingFace 等模型/数据集源使用国内镜像端点：

```text
HF_ENDPOINT=https://hf-mirror.com
ModelScope（魔搭）作为国内原生替代源
```

---

## 4. Package Managers

按包管理器配置国内镜像源：

```text
pip / uv  → 国内 PyPI 镜像
npm       → 国内 npm 镜像
conda     → 国内 conda 镜像（可通过 chsrc 切换）
```

安装决策树本身服从全局 `package-manager.md`（CUDA/GPU 强制使用 conda 环境 `deeplearning`）；本 Rule 只决定源地址，不改变包管理器的选择。

---

## 5. Git

Git 拉取优先使用国内可访问的通道。已有的 git 包装（如 `~/.local/bin/git`）会在 HTTPS 与 SSH 之间自动回退——一个协议卡住时用另一个重试，而不是盲目切换通道。

---

## 6. Fallback

镜像不可用、超时或内容缺失时：

```text
Mirror
  ↓ failed
Retry once
  ↓ failed
Upstream
  ↓ failed
Report to user
```

回退到上游不是默认路径。镜像失败一次后重试一次，仍失败才回退，并在报告中说明已回退。

---

## 7. Integrity

使用镜像不放松完整性校验：

```text
包管理器校验（lockfile / hash）
模型校验（revision / commit hash）
```

镜像提供的内容必须与上游一致。发现镜像内容与预期不符时，停止使用并上报，不静默接受。