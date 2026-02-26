# 好词好句

一个 Flutter 应用，用于：
- 使用手机摄像头扫描多页文章
- 本地 OCR 文字提取与页面合并（ML Kit）
- 真正的 LLM 驱动的好词好句分析
- 本地摘录存储，具备云端同步的数据接口

## 已实现的 MVP 功能

1. 相机扫描流程（逐页扫描）
2. 每页 OCR 提取（本地 ML Kit）
3. 多页文本合并成整篇文章
4. 文学摘录建议与上下文分析
5. 本地摘录列表（SQLite）
6. 云端迁移就绪的数据接口（`CloudQuoteSync`）
7. LLM 指令提示模板文件（`assets/prompts/literary_analysis_prompt.txt`）

## 项目结构

- `lib/src/ui/screens/scan_screen.dart`: 扫描、OCR、分析、保存
- `lib/src/ui/screens/quotes_screen.dart`: 已保存的摘录列表
- `lib/src/services`: 远程 OCR + LLM 分析的抽象与实现
- `lib/src/data`: 仓储 + 本地数据源 + 云端同步接口
- `lib/src/models`: 核心领域模型

## 运行

创建 `env/dev.json`：

```json
{
  "LLM_BASE_URL": "<OPENAI_BASE_URL>",
  "LLM_API_KEY": "<OPENAI_API_KEY>",
  "LLM_MODEL": "qwen3-max",
  "LLM_CHAT_COMPLETIONS_PATH": "/chat/completions"
}
```

然后运行：

```bash
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

## OCR 实现

- 当前默认使用本地 `ML Kit 文字识别`
- 扫描识别无需 OCR API URL 或 API 密钥

## 云端迁移说明

应用已通过 `QuoteRepository` 和 `CloudQuoteSync` 分离了存储层。
后续迁移到云端：
1. 实现具体的 `CloudQuoteSync`（REST/Firebase/Supabase）
2. 将其传入 `LocalQuoteRepository(cloudSync: ...)`
3. 添加认证与冲突解决策略
