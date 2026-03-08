# Block 拉黑系统 API 文档

## 概述

拉黑系统提供用户拉黑、解除拉黑、查看拉黑列表和被拉黑列表的功能，为用户提供更好的社交体验和隐私保护。

**基础信息**:
- **基础路径**: `/api/block`
- **请求格式**: JSON（POST）或表单数据（POST）
- **响应格式**: JSON
- **认证方式**: 所有接口通过 `token` 参数传递（GET请求）或请求体（POST请求）
- **字符编码**: UTF-8

## 通用响应格式

**成功响应**:
```json
{
  "status": "success",
  "message": "操作成功信息",
  "data": { ... }
}
```

**错误响应**:
```json
{
  "status": "error",
  "message": "错误信息"
}
```

## 通用错误码

- `Missing blocked_id parameter`: 缺少blocked_id参数
- `Cannot block yourself`: 不能拉黑自己
- `User not found`: 用户不存在
- `User already blocked`: 用户已经被拉黑
- `Block record not found`: 拉黑记录不存在
- `Cannot unblock yourself`: 不能解除拉黑自己
- `error_token`: Token无效或已过期
- `Token required`: 需要Token
- `system_error`: 系统错误

## 拉黑接口

### 1. 拉黑用户

**请求**: `POST /api/block`

**请求参数** (Body):
- `token` (string, 必需): 用户认证令牌
- `blocked_id` (integer, 必需): 被拉黑用户ID
- `reason` (string, 可选): 拉黑原因
- `reason_visible` (integer, 可选): 拉黑原因是否对被拉黑者可见（0=不可见，1=可见）

**成功响应**:
```json
{
  "status": "success",
  "message": "User blocked successfully",
  "data": {
    "block_id": 1234567890,
    "blocked_id": 123,
    "reason": "骚扰行为",
    "reason_visible": 1
  }
}
```

**错误码**:
- `Missing blocked_id parameter`: 缺少blocked_id参数
- `Cannot block yourself`: 不能拉黑自己
- `User not found`: 用户不存在
- `User already blocked`: 用户已经被拉黑
- `error_token`: Token无效或已过期
- `Token required`: 需要Token
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 拉黑成功
- `400`: 参数错误或验证失败
- `401`: Token无效或未提供
- `404`: 用户不存在
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 拉黑后双方都无法互相沟通
- 拉黑原因是可选的，最多255个字符
- 可以设置拉黑原因是否对被拉黑者可见

### 2. 解除拉黑

**请求**: `DELETE /api/block/{blocked_id}`

**路径参数**:
- `blocked_id` (integer, 必需): 被解除拉黑用户ID

**请求参数** (Query/Body):
- `token` (string, 必需): 用户认证令牌

**成功响应**:
```json
{
  "status": "success",
  "message": "User unblocked successfully",
  "data": {
    "blocked_id": 123
  }
}
```

**错误码**:
- `Cannot unblock yourself`: 不能解除拉黑自己
- `Block record not found`: 拉黑记录不存在
- `error_token`: Token无效或已过期
- `Token required`: 需要Token
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 解除拉黑成功
- `400`: 参数错误或验证失败
- `401`: Token无效或未提供
- `404`: 拉黑记录不存在
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 解除拉黑为软删除，保留历史记录
- 只有双方都解除拉黑，才能恢复正常沟通

### 3. 获取拉黑列表

**请求**: `GET /api/block/list`

**请求参数** (Query):
- `token` (string, 必需): 用户认证令牌
- `page` (integer, 可选): 页码，默认1
- `page_size` (integer, 可选): 每页条数，默认20

**成功响应**:
```json
{
  "status": "success",
  "message": "Get block list successfully",
  "data": {
    "list": [
      {
        "block_id": 1234567890,
        "blocked_id": 123,
        "username": "user123",
        "avatar": "https://example.com/avatar.jpg",
        "reason": "骚扰行为",
        "reason_visible": 1,
        "created_at": "2026-03-02 12:00:00"
      },
      ...
    ],
    "total": 5,
    "page": 1,
    "page_size": 20,
    "total_pages": 1
  }
}
```

**错误码**:
- `error_token`: Token无效或已过期
- `Token required`: 需要Token
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 获取成功
- `401`: Token无效或未提供
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 返回当前用户的拉黑列表
- 支持分页查询
- 按拉黑时间倒序排列（最新的拉黑在前）

### 4. 获取被拉黑列表

**请求**: `GET /api/block/blocked/list`

**请求参数** (Query):
- `token` (string, 必需): 用户认证令牌
- `page` (integer, 可选): 页码，默认1
- `page_size` (integer, 可选): 每页条数，默认20

**成功响应**:
```json
{
  "status": "success",
  "message": "Get blocked list successfully",
  "data": {
    "list": [
      {
        "block_id": 1234567891,
        "blocker_id": 456,
        "username": "user456",
        "avatar": "https://example.com/avatar2.jpg",
        "reason": "",
        "reason_visible": 0,
        "created_at": "2026-03-01 10:00:00"
      },
      ...
    ],
    "total": 3,
    "page": 1,
    "page_size": 20,
    "total_pages": 1
  }
}
```

**错误码**:
- `error_token`: Token无效或已过期
- `Token required`: 需要Token
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 获取成功
- `401`: Token无效或未提供
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 返回当前用户的被拉黑列表
- 只有当对方设置了拉黑原因可见时，才会显示拉黑原因
- 支持分页查询
- 按拉黑时间倒序排列（最新的拉黑在前）

### 5. 检查拉黑状态

**请求**: `GET /api/block/status/{user_id}`

**路径参数**:
- `user_id` (integer, 必需): 目标用户ID

**请求参数** (Query):
- `token` (string, 必需): 用户认证令牌

**成功响应**:
```json
{
  "status": "success",
  "message": "Check block status successfully",
  "data": {
    "target_user_id": 123,
    "i_blocked": true,
    "he_blocked": false,
    "mutual_block": false,
    "any_block": true,
    "my_reason": "骚扰行为",
    "his_reason": "",
    "his_reason_visible": false
  }
}
```

**错误码**:
- `User not found`: 用户不存在
- `error_token`: Token无效或已过期
- `Token required`: 需要Token
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 检查成功
- `401`: Token无效或未提供
- `404`: 用户不存在
- `500`: 系统错误

**注意**:
- 此接口需要用户已登录（提供有效的token）
- 检查当前用户与目标用户的拉黑状态
- 只有当对方设置了拉黑原因可见时，才会显示对方的拉黑原因

## 接口使用流程示例

### 拉黑用户流程

1. **用户登录获取token**
   ```
   POST /api/auth/login
   Body: { "uid_email": "user@qq.com", "pw": "password123" }
   ```

2. **拉黑用户**
   ```
   POST /api/block
   Body: {
     "token": "abc123def456...",
     "blocked_id": 123,
     "reason": "骚扰行为",
     "reason_visible": 1
   }
   ```

3. **获取拉黑列表**
   ```
   GET /api/block/list?token=abc123def456...&page=1&page_size=20
   ```

4. **检查拉黑状态**
   ```
   GET /api/block/status/123?token=abc123def456...
   ```

5. **解除拉黑**
   ```
   DELETE /api/block/123?token=abc123def456...
   ```

## 安全说明

1. **参数验证**:
   - 所有输入参数都会进行严格的类型和格式验证
   - 防止注入攻击和恶意参数

2. **权限控制**:
   - 所有接口需要用户登录且提供有效的token
   - 只能拉黑或解除拉黑其他用户，不能操作自己

3. **数据安全**:
   - 拉黑记录使用软删除，保留历史记录
   - 拉黑原因的可见性由拉黑者控制

4. **Token安全**:
   - Token用于身份认证
   - Token应妥善保管，不要泄露

## 常见问题

**Q: 为什么拉黑后双方都无法沟通？**
A: 系统设计为双向拉黑，只要一方拉黑另一方，双方就无法互相沟通，这是为了保护用户的隐私和安全。

**Q: 为什么解除拉黑后仍然无法沟通？**
A: 解除拉黑需要双方都操作，只有当双方都解除拉黑后，才能恢复正常沟通。

**Q: 为什么被拉黑列表中看不到拉黑原因？**
A: 拉黑原因的可见性由拉黑者控制，只有当拉黑者设置了可见时，被拉黑者才能看到拉黑原因。

**Q: 拉黑记录会一直保存吗？**
A: 是的，解除拉黑为软删除，拉黑记录会一直保存，便于后续的数据分析和审计。

**Q: 拉黑后会影响哪些功能？**
A: 拉黑后，双方无法互相发送私信、评论、关注，也无法在推荐列表中看到对方的内容。