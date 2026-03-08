# Following 关注模块 API 文档

## 概述

关注模块提供用户关注、取消关注、查询关注状态、获取关注列表和粉丝列表、以及时间线相关功能。

**基础信息**:
- **基础路径**: `/api/following`
- **请求格式**: JSON（POST）或查询参数（GET）
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
- `error_uid`: 用户ID无效
- `error_following_uid`: 关注目标用户ID无效
- `system_error`: 系统错误
- `too_big_num`: 请求数量过大
- `error_type`: 参数类型错误

---

## 关注管理

### 1. 关注/取消关注

**请求**: `POST /api/following/follow/{following_uid}`

**路径参数**:
- `following_uid` (int, 必需): 要关注/取消关注的用户ID

**请求参数** (Body):
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "new_fans_count": 15,
  "follow_status": 1
}
```

**响应字段说明**:
- `new_fans_count`: 被关注用户的最新粉丝数
- `follow_status`: 关注状态（1=已关注，0=未关注）

**错误码**:
- `error_following_uid`: 关注目标用户ID无效
- `error_token`: Token无效或已过期
- `too_many_followings`: 关注数量超过限制（最多888个）
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 操作成功
- `400`: 参数错误
- `401`: Token无效或未提供
- `500`: 系统错误

**注意**:
- 此接口为幂等操作，调用一次关注，再调用一次取消关注
- 关注数量限制为888个

---

### 2. 获取关注状态

**请求**: `GET /api/following/status/{following_uid}?token={token}`

**路径参数**:
- `following_uid` (int, 必需): 要查询的用户ID

**查询参数**:
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "follow_status": 1
}
```

**响应字段说明**:
- `follow_status`: 关注状态（1=已关注，0=未关注）

**错误码**:
- `error_following_uid`: 用户ID无效
- `error_token`: Token无效或已过期

**HTTP状态码**:
- `200`: 查询成功
- `400`: 参数错误
- `401`: Token无效或未提供

---

### 3. 获取关注列表

**请求**: `GET /api/following/list/{uid}?offset={offset}&num={num}&token={token}`

**路径参数**:
- `uid` (int, 必需): 要查询的用户ID

**查询参数**:
- `offset` (int, 可选): 偏移量，默认为0
- `num` (int, 可选): 数量，默认为20，最大为18
- `token` (string, 可选): 当前用户Token（用于显示是否已关注）

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "user_list": [
      {
        "uid": 123,
        "username": "user123",
        "avatar_url": "https://example.com/avatar.jpg",
        "follow_status": 1
      },
      ...
    ]
  }
}
```

**响应字段说明**:
- `user_list`: 用户列表
  - `uid`: 用户ID
  - `username`: 用户名
  - `avatar_url`: 头像URL
  - `follow_status`: 当前用户对该用户的关注状态（仅当提供token时返回）

**错误码**:
- `error_uid`: 用户ID无效
- `too_big_num`: 请求数量过大
- `error_type`: 参数类型错误
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 查询成功
- `400`: 参数错误
- `500`: 系统错误

---

### 4. 获取粉丝列表

**请求**: `GET /api/following/fans/{uid}?offset={offset}&num={num}&token={token}`

**路径参数**:
- `uid` (int, 必需): 要查询的用户ID

**查询参数**:
- `offset` (int, 可选): 偏移量，默认为0
- `num` (int, 可选): 数量，默认为20，最大为18
- `token` (string, 可选): 当前用户Token（用于显示是否已关注）

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "user_list": [
      {
        "uid": 456,
        "username": "fan456",
        "avatar_url": "https://example.com/avatar2.jpg",
        "follow_status": 1
      },
      ...
    ]
  }
}
```

**响应字段说明**:
- `user_list`: 用户列表
  - `uid`: 用户ID
  - `username`: 用户名
  - `avatar_url`: 头像URL
  - `follow_status`: 当前用户对该用户的关注状态（仅当提供token时返回）

**错误码**:
- `error_uid`: 用户ID无效
- `too_big_num`: 请求数量过大
- `error_type`: 参数类型错误
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 查询成功
- `400`: 参数错误
- `500`: 系统错误

---

## 时间线管理

### 5. 获取所有关注者的时间线

**请求**: `GET /api/following/timeline?offset={offset}&num={num}&token={token}`

**查询参数**:
- `offset` (int, 可选): 偏移量，默认为0
- `num` (int, 可选): 数量，默认为20，最大为24
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "timeline_list": [
      {
        "content_type": "video",
        "vid": 789,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 12:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "cover_url": "https://example.com/cover.jpg",
        "username": "user123",
        "avatar_url": "https://example.com/avatar.jpg"
      },
      {
        "content_type": "blog",
        "bid": 456,
        "uid": 789,
        "title": "动态标题",
        "content": "动态内容",
        "time": "2023-01-01 11:30:00",
        "like_count": 50,
        "favorite_count": 20,
        "view_count": 500,
        "username": "user789",
        "avatar_url": "https://example.com/avatar2.jpg",
        "thumbnails": ["https://example.com/thumb1.jpg"]
      },
      ...
    ]
  }
}
```

**响应字段说明**:
- `timeline_list`: 时间线列表
  - 视频类型 (`content_type: "video"`):
    - `vid`: 视频ID
    - `uid`: 用户ID
    - `title`: 视频标题
    - `time`: 发布时间
    - `like_count`: 点赞数
    - `favorite_count`: 收藏数
    - `view_count`: 观看数
    - `cover_url`: 封面URL
    - `username`: 用户名
    - `avatar_url`: 头像URL
  - 动态类型 (`content_type: "blog"`):
    - `bid`: 动态ID
    - `uid`: 用户ID
    - `title`: 动态标题
    - `content`: 动态内容
    - `time`: 发布时间
    - `like_count`: 点赞数
    - `favorite_count`: 收藏数
    - `view_count`: 观看数
    - `username`: 用户名
    - `avatar_url`: 头像URL
    - `thumbnails`: 缩略图URL列表

**错误码**:
- `error_token`: Token无效或已过期
- `too_big_num`: 请求数量过大
- `error_type`: 参数类型错误
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 查询成功
- `400`: 参数错误
- `401`: Token无效或未提供
- `500`: 系统错误

---

### 6. 获取某个用户的时间线

**请求**: `GET /api/following/timeline/{uid}?offset={offset}&num={num}`

**路径参数**:
- `uid` (int, 必需): 要查询的用户ID

**查询参数**:
- `offset` (int, 可选): 偏移量，默认为0
- `num` (int, 可选): 数量，默认为20，最大为24

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "timeline_list": [
      {
        "content_type": "video",
        "vid": 789,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 12:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "cover_url": "https://example.com/cover.jpg",
        "username": "user123",
        "avatar_url": "https://example.com/avatar.jpg"
      },
      ...
    ]
  }
}
```

**响应字段说明**:
- 同"获取所有关注者的时间线"接口

**错误码**:
- `error_uid`: 用户ID无效
- `too_big_num`: 请求数量过大
- `error_type`: 参数类型错误
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 查询成功
- `400`: 参数错误
- `500`: 系统错误

---

### 7. 获取活跃关注者列表

**请求**: `GET /api/following/active/{uid}?offset={offset}&num={num}`

**路径参数**:
- `uid` (int, 必需): 要查询的用户ID

**查询参数**:
- `offset` (int, 可选): 偏移量，默认为0
- `num` (int, 可选): 数量，默认为20，最大为24

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "user_list": [
      {
        "uid": 123,
        "username": "user123",
        "avatar_url": "https://example.com/avatar.jpg",
        "latest_activity_time": "2023-01-01 12:00:00"
      },
      ...
    ]
  }
}
```

**响应字段说明**:
- `user_list`: 用户列表
  - `uid`: 用户ID
  - `username`: 用户名
  - `avatar_url`: 头像URL
  - `latest_activity_time`: 最新活动时间

**错误码**:
- `error_uid`: 用户ID无效
- `too_big_num`: 请求数量过大
- `error_type`: 参数类型错误
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 查询成功
- `400`: 参数错误
- `500`: 系统错误

---

## 接口使用流程示例

### 关注用户流程

1. **检查是否已关注**
   ```
   GET /api/following/status/123?token=abc123def456...
   ```

2. **关注用户**
   ```
   POST /api/following/follow/123
   Body: { "token": "abc123def456..." }
   ```

3. **获取关注列表**
   ```
   GET /api/following/list/456?offset=0&num=20&token=abc123def456...
   ```

### 浏览时间线流程

1. **获取所有关注者的时间线**
   ```
   GET /api/following/timeline?offset=0&num=20&token=abc123def456...
   ```

2. **查看某个用户的时间线**
   ```
   GET /api/following/timeline/123?offset=0&num=20
   ```

3. **获取活跃关注者**
   ```
   GET /api/following/active/456?offset=0&num=20
   ```

---

## 安全说明

1. **Token安全**:
   - Token用于身份认证，应妥善保管
   - 避免在公共场合泄露Token
   - Token失效后需要重新登录获取

2. **参数验证**:
   - 所有用户ID参数都会经过验证，确保为有效用户
   - 关注操作会验证目标用户是否存在
   - 分页参数会被限制最大值，防止请求过多数据

3. **频率限制**:
   - 关注数量限制为888个用户
   - 每次请求最多获取24条时间线数据
   - 每次请求最多获取18个用户列表数据

4. **数据过滤**:
   - 时间线数据会自动过滤被屏蔽的用户内容
   - 会过滤包含敏感词的内容

---

## 常见问题

**Q: 为什么关注时提示"too_many_followings"？**
A: 每个用户最多只能关注888个用户，已达到上限。

**Q: 为什么时间线列表为空？**
A: 可能是因为您还没有关注任何用户，或者关注的用户还没有发布内容。

**Q: 为什么获取时间线时提示"error_token"？**
A: Token无效或已过期，请重新登录获取新的Token。

**Q: 为什么请求数量被限制？**
A: 为了保证系统性能，API对请求数量有上限限制：
   - 时间线接口：最多24条
   - 用户列表接口：最多18条

**Q: 如何判断我是否已关注某个用户？**
A: 使用"获取关注状态"接口，或在获取用户列表时携带token参数，接口会返回关注状态。