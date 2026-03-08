# Danmaku 滚幕模块 API 文档

## 概述

滚幕模块提供视频滚幕的获取、发送和删除功能，为用户提供实时互动体验。

**基础信息**:
- **基础路径**: `/api/danmaku`
- **请求格式**: JSON（POST）或表单数据（POST）
- **响应格式**: JSON
- **认证方式**: 部分接口通过 `token` 参数传递（GET请求）或请求体（POST请求）
- **字符编码**: UTF-8

## 通用响应格式

**成功响应**:
```json
{
  "status": "success",
  "data": { ... }
}
```

**错误响应**:
```json
{
  "status": "error",
  "message": "错误信息代码"
}
```

## 通用错误码

- `missing_argument`: 缺少必需参数
- `error_token`: Token无效或已过期
- `system_error`: 系统错误
- `error_type`: 参数类型错误
- `no_permission`: 权限不足

---

## 滚幕接口

### 1. 获取视频滚幕

**请求**: `GET /api/danmaku/{vid}`

**路径参数**:
- `vid` (integer, 必需): 视频ID

**成功响应**:
```json
{
  "status": "success",
  "code": 0,
  "data": [
    {
      "danmaku_id": 1,
      "text": "这是一条滚幕",
      "time": 10.5,
      "mode": "scroll",
      "color": "#ffffff",
      "font_size": "25px",
      "render": ""
    },
    ...
  ]
}
```

**响应字段说明**:
- `danmaku_id`: 滚幕ID
- `text`: 滚幕文本内容
- `time`: 滚幕出现时间（秒）
- `mode`: 滚幕模式（`scroll`: 滚动, `top`: 顶部, `bottom`: 底部）
- `color`: 滚幕颜色（十六进制颜色码）
- `font_size`: 滚幕字体大小
- `render`: 渲染参数（通常为空）

**错误码**:
- `error_type`: 视频ID格式错误
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 获取成功
- `400`: 参数错误
- `500`: 系统错误

**注意**:
- 此接口无需用户登录
- 最多返回3000条滚幕
- 只返回已审核通过且未删除的滚幕
- 按滚幕ID倒序排列（最新的滚幕在前）

---

### 2. 发送滚幕

**请求**: `POST /api/danmaku`

**请求参数** (Body):
- `token` (string, 必需): 用户认证令牌
- `vid` (integer/string, 必需): 视频ID
- `text` (string, 必需): 滚幕文本内容（1-50个字符）
- `time` (number/string, 必需): 滚幕出现时间（秒）
- `mode` (string, 必需): 滚幕模式（`scroll`, `top`, `bottom`）
- `color` (string, 必需): 滚幕颜色（6位十六进制颜色码，不含#）
- `font_size` (string, 必需): 滚幕字体大小（5-100px）
- `render` (string, 必需): 渲染参数（通常为空字符串）

**成功响应**:
```json
{
  "status": "success"
}
```

**错误码**:
- `missing_argument`: 缺少必需参数
- `error_token`: Token无效或已过期
- `error_type`: 参数类型错误
- `no_permission`: 经验值不足（需要≥50）
- `error_time`: 时间格式错误
- `error_mode`: 滚幕模式错误
- `error_color`: 颜色格式错误
- `error_font_size`: 字体大小格式错误
- `warn`: 文本内容包含敏感词
- `text_too_long`: 文本内容过长（超过50个字符）
- `text_too_short`: 文本内容过短（少于1个字符）
- `render_too_long`: render参数过长（超过153个字符）
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 发送成功
- `400`: 参数错误或验证失败
- `401`: Token无效或未提供
- `403`: 权限不足
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 用户需要至少50点经验值才能发送滚幕
- 滚幕会自动通过审核（audit_status=1）
- 系统会自动生成唯一的滚幕ID

---

### 3. 删除滚幕

**请求**: `DELETE /api/danmaku/{danmaku_id}`

**路径参数**:
- `danmaku_id` (integer, 必需): 滚幕ID

**请求参数** (Query/Body):
- `token` (string, 必需): 用户认证令牌

**成功响应**:
```json
{
  "status": "success"
}
```

**错误码**:
- `missing_argument`: 缺少必需参数
- `error_token`: Token无效或已过期
- `error_type`: 参数类型错误
- `error_danmaku_id`: 滚幕不存在或已删除
- `no_permission`: 权限不足（不是滚幕作者）
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 删除成功
- `400`: 参数错误或验证失败
- `401`: Token无效或未提供
- `403`: 权限不足
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 用户只能删除自己发送的滚幕
- 滚幕删除为软删除（is_deleted=1）

---

## 接口使用流程示例

### 发送滚幕流程

1. **用户登录获取token**
   ```
   POST /api/auth/login
   Body: { "uid_email": "user@qq.com", "pw": "password123" }
   ```

2. **发送滚幕**
   ```
   POST /api/danmaku
   Body: {
     "token": "abc123def456...",
     "vid": "123",
     "text": "这是一条新滚幕",
     "time": "15.5",
     "mode": "scroll",
     "color": "ffffff",
     "font_size": "25px",
     "render": ""
   }
   ```

3. **获取视频滚幕**
   ```
   GET /api/danmaku/123
   ```

4. **删除自己的滚幕**
   ```
   DELETE /api/danmaku/456?token=abc123def456...
   ```

---

## 安全说明

1. **参数验证**:
   - 所有输入参数都会进行严格的类型和格式验证
   - 防止注入攻击和恶意参数

2. **权限控制**:
   - 发送滚幕需要用户登录且经验值≥50
   - 删除滚幕只能由滚幕作者操作

3. **数据安全**:
   - 滚幕内容会进行敏感词检测
   - 滚幕ID自动生成，确保唯一性

4. **Token安全**:
   - Token用于身份认证
   - Token应妥善保管，不要泄露

---

## 常见问题

**Q: 为什么发送滚幕提示"权限不足"？**
A: 发送滚幕需要用户经验值≥50，请先通过签到、发布内容等方式获取经验值。

**Q: 为什么删除滚幕提示"权限不足"？**
A: 用户只能删除自己发送的滚幕，无法删除其他用户的滚幕。

**Q: 为什么获取滚幕返回空数组？**
A: 可能的原因：
   - 视频ID不存在
   - 视频没有滚幕
   - 所有滚幕都被删除或未通过审核

**Q: 滚幕模式有哪些？**
A: 支持三种滚幕模式：
   - `scroll`: 滚动滚幕（从右向左）
   - `top`: 顶部滚幕（固定在顶部）
   - `bottom`: 底部滚幕（固定在底部）

**Q: 滚幕颜色格式有什么要求？**
A: 滚幕颜色需要是6位十六进制颜色码，不需要包含#前缀，例如：`ffffff`（白色）、`ff0000`（红色）。

**Q: 滚幕字体大小有什么限制？**
A: 滚幕字体大小需要在5-100px之间，例如：`25px`。