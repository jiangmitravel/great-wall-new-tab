# Great Wall Extension - 构建系统使用指南

## 🎯 概述

这个项目使用**单源多构建**系统,维护一份代码,自动生成 Chrome 和 Edge 两个平台的发布包。

## 📂 目录结构

```
great-wall-new-tab/
├── src/                          # 源代码 (浏览器中立)
│   ├── manifest.json            # 扩展配置
│   ├── newtab.html              # 新标签页
│   ├── newtab.js                # JavaScript
│   ├── newtab.css               # 样式
│   ├── PRIVACY.template.md      # 隐私政策模板
│   └── images/                  # 图片资源
│       ├── backgrounds/         # 10张背景图
│       └── icons/               # 3个图标 (16, 48, 128)
│
├── build/                        # 构建输出
│   ├── chrome/                  # Chrome 版本
│   ├── edge/                    # Edge 版本
│   ├── great-wall-chrome-v1.0.0.zip
│   └── great-wall-edge-v1.0.0.zip
│
└── scripts/                      # 构建脚本
    ├── build.sh                 # 主构建脚本
    ├── build-all.sh             # 全平台构建
    └── config.json              # 平台配置
```

## 🚀 快速开始

### 构建单个平台

```bash
# 构建 Chrome 版本
./scripts/build.sh chrome 1.0.0

# 构建 Edge 版本
./scripts/build.sh edge 1.0.0
```

### 构建所有平台

```bash
# 一次性构建所有平台
./scripts/build-all.sh 1.0.0
```

## 📝 开发流程

### 1. 修改代码

在 `src/` 目录中编辑文件:

```bash
cd src/
# 编辑 newtab.html, newtab.js, newtab.css 等
```

**注意:** 使用浏览器中立的语言,避免 "Chrome" 等特定词汇。

### 2. 使用模板变量

对于需要平台特定文本的地方,使用模板变量:

**可用变量:**
- `{{PLATFORM_NAME}}` - Chrome / Browser
- `{{PLATFORM_FULL}}` - Chrome Extension / Browser Extension  
- `{{BROWSER_NAME}}` - Chrome browser / browser
- `{{STORE_NAME}}` - Chrome Web Store / extension store
- `{{STORE_POLICY}}` - 商店政策名称
- `{{STORE_URL}}` - chrome://extensions/ / edge://extensions/

**示例:**

```markdown
<!-- PRIVACY.template.md -->
# {{PLATFORM_FULL}} Privacy Policy

This extension works on your {{BROWSER_NAME}}.
```

### 3. 测试构建

```bash
# 构建测试
./scripts/build.sh chrome 1.0.0

# 检查生成的文件
cat build/chrome/PRIVACY.md | head -5
```

### 4. 提交到商店

```bash
# 构建最终版本
./scripts/build-all.sh 1.0.1

# 上传文件:
# Chrome: build/great-wall-chrome-v1.0.1.zip
# Edge: build/great-wall-edge-v1.0.1.zip
```

## 🔄 更新流程

### 发布新版本

1. **修改源代码** (在 `src/` 目录)
2. **增加版本号**
3. **构建所有平台**
4. **测试两个包**
5. **同时提交到两个商店**

```bash
# 完整流程
vim src/newtab.js              # 修改代码
./scripts/build-all.sh 1.0.2   # 构建新版本
# 测试 build/chrome/ 和 build/edge/
# 上传到商店
```

## 📋 配置文件

### scripts/config.json

```json
{
  "platforms": {
    "chrome": {
      "PLATFORM_NAME": "Chrome",
      ...
    },
    "edge": {
      "PLATFORM_NAME": "Browser",
      ...
    }
  }
}
```

**添加新平台:**

1. 在 `config.json` 添加平台配置
2. 运行 `./scripts/build.sh new-platform 1.0.0`

## ✅ 最佳实践

### DO ✅

- 在 `src/` 目录编辑代码
- 使用模板变量处理平台差异
- 每次发布同时更新所有平台
- 测试生成的包

### DON'T ❌

- 不要直接编辑 `build/` 目录的文件
- 不要在源代码中硬编码 "Chrome"
- 不要手动替换文本
- 不要维护两份代码

## 🐛 故障排查

### 构建失败

```bash
# 检查权限
chmod +x scripts/*.sh

# 检查 jq 是否安装 (可选,有 fallback)
brew install jq
```

### 模板变量未替换

检查文件名是否包含 `.template.`:
- ✅ `PRIVACY.template.md`
- ❌ `PRIVACY.md`

### ZIP 包损坏

```bash
# 测试 ZIP 包
unzip -t build/great-wall-chrome-v1.0.0.zip
```

## 📦 生成的文件

每次构建会生成:

1. **build/chrome/** - Chrome 版本源文件
2. **build/edge/** - Edge 版本源文件  
3. **build/great-wall-chrome-v{version}.zip** - Chrome 发布包
4. **build/great-wall-edge-v{version}.zip** - Edge 发布包

## 🎓 示例

### 添加新的模板文件

1. 创建 `src/new-file.template.txt`
2. 使用 `{{变量}}`
3. 运行构建
4. 检查 `build/chrome/new-file.txt`

### 修改平台配置

```bash
vim scripts/config.json
# 修改 PLATFORM_NAME 等
./scripts/build-all.sh 1.0.0
```

## 📞 需要帮助?

- 查看构建日志
- 检查 `build/` 目录
- 验证模板文件语法
