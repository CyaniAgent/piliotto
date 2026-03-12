# Auth 认证模块 API 文档

## 概述

认证模块提供用户注册、登录、密码重置、签到等基础认证功能。

**基础信息**:
- **基础路径**: `/api/auth`
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
- `too_many_requests`: 请求频率过高（10分钟内只能发送一次验证码）

---

## 用户认证

### 1. 用户登录

**请求**: `POST /api/auth/login`

**请求参数** (Body):
- `uid_email` (string, 必需): 用户ID或邮箱地址
- `pw` (string, 必需): 用户密码

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "uid": 123,
    "token": "abc123def456...",
    "avatar_url": "https://example.com/avatar.jpg",
    "cover_url": "https://example.com/cover.jpg",
    "if_today_first_login": "yes",
    "email": "user@qq.com",
    "is_audit": 0,
    "is_admin": 0
  }
}
```

**响应字段说明**:
- `uid`: 用户ID
- `token`: 用户认证令牌，后续请求需要携带此token
- `avatar_url`: 用户头像URL
- `cover_url`: 用户封面URL
- `if_today_first_login`: 是否今日首次登录（`yes` 或 `no`），首次登录会获得10经验值
- `email`: 用户邮箱
- `is_audit`: 是否为审核员（0-否，1-是）
- `is_admin`: 是否为管理员（0-否，1-是）

**错误码**:
- `missing_argument`: 缺少必需参数
- `error_password`: 用户名/邮箱或密码错误

**HTTP状态码**:
- `200`: 登录成功
- `400`: 参数错误
- `401`: 认证失败

---

### 2. 用户注册

**请求**: `POST /api/auth/register`

**请求参数** (Body):
- `email` (string, 必需): 用户邮箱（必须是QQ邮箱格式：5-12位数字@qq.com）
- `register_verification_code` (string/int, 必需): 注册验证码（需先调用"发送注册验证码"接口获取）
- `pw` (string, 必需): 用户密码（8-20个字符，不能包含非ASCII字符）
- `confirm_pw` (string, 必需): 确认密码（必须与 `pw` 相同）

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "uid": 123,
    "token": "abc123def456...",
    "avatar_url": "https://example.com/avatar.jpg",
    "cover_url": "https://example.com/cover.jpg",
    "if_today_first_login": "yes",
    "email": "user@qq.com",
    "is_audit": 0,
    "is_admin": 0
  }
}
```

**注意**: 注册成功后会自动登录，返回与登录接口相同的数据结构。

**错误码**:
- `missing_argument`: 缺少必需参数
- `mismatch_pw`: 两次输入的密码不一致
- `error_pw`: 密码格式错误（长度必须在8-20之间，不能包含非ASCII字符）
- `email_exist`: 邮箱已被注册
- `error_verification_code`: 验证码错误或已失效
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 注册成功
- `400`: 参数错误或验证失败
- `500`: 系统错误

**注意**:
- 注册成功后，验证码会被自动删除
- 新用户注册时会自动获得10经验值
- 系统会自动生成用户名（格式：`{uid}_{8位随机数字}`）

---

### 3. 发送注册验证码

**请求**: `POST /api/auth/register/verification-code`

**请求参数** (Body):
- `email` (string, 必需): 用户邮箱（必须是QQ邮箱格式：5-12位数字@qq.com）

**成功响应**:
```json
{
  "status": "success"
}
```

**错误码**:
- `missing_argument`: 缺少必需参数
- `email_exist`: 邮箱已被注册
- `error_email`: 邮箱格式错误（必须是@qq.com结尾）
- `error_qq_email`: QQ邮箱格式错误（必须是5-12位数字@qq.com）
- `too_many_requests`: 请求频率过高（10分钟内只能发送一次）
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 发送成功
- `400`: 参数错误
- `429`: 请求频率过高
- `500`: 系统错误

**限制说明**:
- 同一账号10分钟内只能发送一次验证码
- 验证码为6位数字，通过邮件发送
- 邮件主题："来自OTTOhub的邀请函"
- 验证码有效期为一定时间（具体由系统配置决定）

---

### 4. 重置密码

**请求**: `POST /api/auth/password-reset`

**请求参数** (Body):
- `email` (string, 必需): 用户邮箱
- `passwordreset_verification_code` (string/int, 必需): 密码重置验证码（需先调用"发送密码重置验证码"接口获取）
- `pw` (string, 必需): 新密码（8-20个字符，只能包含字母和数字）
- `confirm_pw` (string, 必需): 确认密码（必须与 `pw` 相同）

**成功响应**:
```json
{
  "status": "success"
}
```

**错误码**:
- `missing_argument`: 缺少必需参数
- `mismatch_pw`: 两次输入的密码不一致
- `error_pw`: 密码格式错误（长度必须在8-20之间，只能包含字母和数字）
- `email_unexist`: 邮箱不存在或未注册
- `error_verification_code`: 验证码错误或已失效
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 重置成功
- `400`: 参数错误或验证失败
- `500`: 系统错误

**注意**:
- 重置成功后，验证码会被自动删除
- 密码会被加密存储（MD5）

---

### 5. 发送密码重置验证码

**请求**: `POST /api/auth/password-reset/verification-code`

**请求参数** (Body):
- `email` (string, 必需): 用户邮箱

**成功响应**:
```json
{
  "status": "success"
}
```

**错误码**:
- `missing_argument`: 缺少必需参数
- `email_unexist`: 邮箱不存在或未注册
- `too_many_requests`: 请求频率过高（10分钟内只能发送一次）
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 发送成功
- `400`: 参数错误
- `429`: 请求频率过高
- `500`: 系统错误

**限制说明**:
- 同一账号10分钟内只能发送一次验证码
- 验证码为6位数字，通过邮件发送
- 邮件主题："OTTOhub密码找回"
- 验证码有效期为一定时间（具体由系统配置决定）

---

### 6. 用户签到

**请求**: `POST /api/auth/sign-in`

**请求参数** (Body):
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "if_today_first_login": "yes"
}
```

**响应字段说明**:
- `if_today_first_login`: 是否今日首次登录（`yes` 或 `no`）
  - `yes`: 今日首次登录，已获得10经验值
  - `no`: 今日已登录过，未获得经验值

**注意**: 此接口响应格式特殊，字段直接在根级别，不在 `data` 中。

**错误码**:
- `missing_argument`: 缺少必需参数
- `error_token`: Token无效或已过期
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 签到成功
- `401`: Token无效或未提供
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 如果用户今日首次登录，会获得10经验值
- 签到会更新用户的最后登录时间

---

## 接口使用流程示例

### 注册流程

1. **发送注册验证码**
   ```
   POST /api/auth/register/verification-code
   Body: { "email": "123456789@qq.com" }
   ```

2. **用户收到邮件，输入验证码**

3. **提交注册信息**
   ```
   POST /api/auth/register
   Body: {
     "email": "123456789@qq.com",
     "register_verification_code": "123456",
     "pw": "password123",
     "confirm_pw": "password123"
   }
   ```

### 登录流程

1. **用户登录**
   ```
   POST /api/auth/login
   Body: {
     "uid_email": "123456789@qq.com",
     "pw": "password123"
   }
   ```

2. **获取token，后续请求携带token**

### 密码重置流程

1. **发送密码重置验证码**
   ```
   POST /api/auth/password-reset/verification-code
   Body: { "email": "123456789@qq.com" }
   ```

2. **用户收到邮件，输入验证码**

3. **提交新密码**
   ```
   POST /api/auth/password-reset
   Body: {
     "email": "123456789@qq.com",
     "passwordreset_verification_code": "123456",
     "pw": "newpassword123",
     "confirm_pw": "newpassword123"
   }
   ```

### 签到流程

1. **用户签到（需要已登录）**
   ```
   POST /api/auth/sign-in
   Body: { "token": "abc123def456..." }
   ```

---

## 安全说明

1. **密码安全**:
   - 注册密码：8-20个字符，不能包含非ASCII字符
   - 重置密码：8-20个字符，只能包含字母和数字
   - 密码使用MD5加密存储

2. **验证码安全**:
   - 验证码为6位数字
   - 验证码通过邮件发送
   - 验证码使用后会被删除
   - 10分钟内只能发送一次验证码

3. **Token安全**:
   - Token用于后续API请求的身份认证
   - Token应妥善保管，不要泄露
   - Token失效后需要重新登录

4. **邮箱限制**:
   - 目前仅支持QQ邮箱注册
   - 邮箱格式：5-12位数字@qq.com

---

## 常见问题

**Q: 为什么注册时提示"邮箱已被注册"？**
A: 该邮箱已经被其他用户使用，请使用其他邮箱或尝试找回密码。

**Q: 为什么提示"请求频率过高"？**
A: 验证码发送有频率限制，10分钟内只能发送一次，请稍后再试。

**Q: 验证码有效期是多久？**
A: 验证码有效期由系统配置决定，建议收到后尽快使用。

**Q: 忘记密码怎么办？**
A: 使用"发送密码重置验证码"接口获取验证码，然后使用"重置密码"接口重置密码。

**Q: 登录后如何保持登录状态？**
A: 登录成功后会返回token，后续请求需要携带此token进行身份认证。
