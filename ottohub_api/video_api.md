# Video 视频模块 API 文档

## 概述

视频模块提供视频的获取、搜索、收藏、点赞、删除等功能。

**基础信息**:
- **基础路径**: `/api/video`
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

**列表类接口**：视频列表统一使用嵌套格式，`data` 内包含 `video_list` 数组；若接口带总数或分页信息，则同时包含 `total_count`、`favorite_video_count`、`manage_video_count` 等字段。

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
- `error_uid`: 用户ID无效
- `error_vid`: 视频ID无效

---

## 视频获取

### 1. 随机视频列表

**请求**: `GET /api/video/random?num={num}`

**请求参数** (Query):
- `num` (int, 可选): 视频数量，默认20

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `500`: 系统错误

---

### 2. 最新视频列表

**请求**: `GET /api/video/new?offset={offset}&num={num}&type={type}`

**请求参数** (Query):
- `offset` (int, 可选): 偏移量，默认0
- `num` (int, 可选): 视频数量，默认20
- `type` (string, 可选): 视频类型，默认all

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `500`: 系统错误

---

### 3. 热门视频列表

**请求**: `GET /api/video/popular?time_limit={time_limit}&offset={offset}&num={num}`

**请求参数** (Query):
- `time_limit` (int, 可选): 时间限制（天数），默认7
- `offset` (int, 可选): 偏移量，默认0
- `num` (int, 可选): 视频数量，默认20

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `500`: 系统错误

---

### 4. 分类视频列表

**请求**: `GET /api/video/category/{category}?num={num}`

**请求参数** (Path):
- `category` (string, 必需): 视频分类

**请求参数** (Query):
- `num` (int, 可选): 视频数量，默认20

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `500`: 系统错误

---

### 5. 搜索视频列表

**请求**: `GET /api/video/search?search_term={search_term}&offset={offset}&num={num}&...`

**请求参数** (Query):
- `search_term` (string, 可选): 搜索关键词
- `offset` (int, 可选): 偏移量，默认0
- `num` (int, 可选): 视频数量，默认20
- `vid_desc` (int, 可选): 按视频ID降序排序，默认0
- `view_count_desc` (int, 可选): 按观看次数降序排序，默认0
- `like_count_desc` (int, 可选): 按点赞次数降序排序，默认0
- `favorite_count_desc` (int, 可选): 按收藏次数降序排序，默认0
- `uid` (int, 可选): 用户ID
- `type` (string, 可选): 视频类型

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg",
        "intro": "简介",
        "tag": "标签",
        "collection": "合集",
        "type": 1,
        "category": "分类",
        "duration": 120
      }
    ],
    "total_count": 100
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `500`: 系统错误

---

### 6. 获取视频详情

**请求**: `GET /api/video/{vid}?token={token}`

**请求参数** (Path):
- `vid` (int, 必需): 视频ID

**请求参数** (Query):
- `token` (string, 可选): 用户Token

**成功响应**:
```json
{
    "status": "success",
    "data": {
        "vid": "1",
        "uid": "1",
        "title": "视频标题",
        "intro": "视频简介",
        "type": "3",
        "category": "3",
        "tag": "#标签1#标签2",
        "time": "2023-01-01 00:00:00",
        "like_count": "100",
        "favorite_count": "50",
        "view_count": "1000",
        "cover_url": "https://example.com/cover.jpg",
        "video_url": "https://example.com/video.mp4",
        "audio_url": "https://example.com/audio.mp3",
        "username": "用户昵称",
        "userintro": "用户个性签名",
        "avatar_url": "https://example.com/avatar.jpg",
        "if_like": 0,
        "if_favorite": 0,
        "video_width": "1440",
        "video_height": "1080",
        "video_sar": "0:1",
        "video_dar": "0:1",
        "duration": "223",
        "comment_count": "5",
        "video_m3u8_url": "",
        "channel_id": 0,
        "channel_detail": {
            "channel_id": "",
            "channel_name": "",
            "channel_title": "",
            "channel_description": "",
            "channel_cover_url": ""
        }
    }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `400`: 参数错误
- `500`: 系统错误

---

### 7. 用户视频列表

**请求**: `GET /api/video/user/{uid}?offset={offset}&num={num}`

**请求参数** (Path):
- `uid` (int, 必需): 用户ID

**请求参数** (Query):
- `offset` (int, 可选): 偏移量，默认0
- `num` (int, 可选): 视频数量，默认20

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `400`: 参数错误
- `500`: 系统错误

---

### 8. 相关视频列表

**请求**: `GET /api/video/related/{vid}?num={num}&offset={offset}`

**请求参数** (Path):
- `vid` (int, 必需): 视频ID

**请求参数** (Query):
- `num` (int, 可选): 视频数量，默认20
- `offset` (int, 可选): 偏移量，默认0

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `500`: 系统错误

---

### 9. 收藏视频列表

**请求**: `GET /api/video/favorite-list?offset={offset}&num={num}`

**请求参数** (Query):
- `offset` (int, 可选): 偏移量，默认0
- `num` (int, 可选): 视频数量，默认20
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ],
    "favorite_video_count": 10
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `401`: Token无效或未提供
- `500`: 系统错误

---

### 10. 管理视频列表

**请求**: `GET /api/video/manage-list?offset={offset}&num={num}`

**请求参数** (Query):
- `offset` (int, 可选): 偏移量，默认0
- `num` (int, 可选): 视频数量，默认20
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "is_deleted": 0,
        "audit_status": 1,
        "cover_url": "https://example.com/cover.jpg",
        "collection": "合集名称",
        "collection_sort_order": 0,
        "channel_id": 1,
        "channel_detail": {
          "channel_id": 1,
          "channel_name": "频道名称",
          "channel_title": "频道标题",
          "description": "频道描述",
          "cover_url": "https://example.com/channel_cover.jpg"
        }
      }
    ],
    "manage_video_count": 20
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `401`: Token无效或未提供
- `500`: 系统错误

---

### 11. 历史视频列表

**请求**: `GET /api/video/history-list`

**请求参数** (Query):
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "video_list": [
      {
        "vid": 1,
        "uid": 123,
        "title": "视频标题",
        "time": "2023-01-01 00:00:00",
        "like_count": 100,
        "favorite_count": 50,
        "view_count": 1000,
        "cover_url": "https://example.com/cover.jpg",
        "username": "用户名",
        "avatar_url": "https://example.com/avatar.jpg"
      }
    ]
  }
}
```

**HTTP状态码**:
- `200`: 获取成功
- `401`: Token无效或未提供
- `500`: 系统错误

---

## 视频操作

### 12. 保存视频观看历史

**请求**: `POST /api/video/watch-history`

**请求参数** (Body，JSON 或 form)：
- `token` (string, 必需): 用户 Token
- `vid` (int, 必需): 视频 ID（VID）
- `last_watch_second` (int, 必需): 最后观看到的秒数；**-1 表示已看完**，0 表示从头开始，正整数表示当前播放到的秒数

**成功响应**:
```json
{
  "status": "success"
}
```

**错误码**:
- `missing_argument`: 缺少 vid 或 last_watch_second 或 token
- `error_token`: Token 无效或已过期
- `error_type`: vid / last_watch_second 非数字
- `error_vid`: 视频不存在

**HTTP状态码**:
- `200`: 保存成功
- `400`: 参数错误（缺少参数、类型错误、视频不存在）
- `401`: Token 无效或未提供
- `500`: 系统错误

---

### 13. 收藏/取消收藏视频

**请求**: `POST /api/video/favorite/{vid}`

**请求参数** (Path):
- `vid` (int, 必需): 视频ID

**请求参数** (Body):
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "if_favorite": 1,
    "favorite_count": 51
  }
}
```

**HTTP状态码**:
- `200`: 操作成功
- `400`: 参数错误
- `401`: Token无效或未提供
- `500`: 系统错误

---

### 14. 点赞/取消点赞视频

**请求**: `POST /api/video/like/{vid}`

**请求参数** (Path):
- `vid` (int, 必需): 视频ID

**请求参数** (Body):
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "if_like": 1,
    "like_count": 101
  }
}
```

**HTTP状态码**:
- `200`: 操作成功
- `400`: 参数错误
- `401`: Token无效或未提供
- `500`: 系统错误

---

### 15. 删除视频

**请求**: `DELETE /api/video/{vid}`

**请求参数** (Path):
- `vid` (int, 必需): 视频ID

**请求参数** (Body):
- `token` (string, 必需): 用户Token

**成功响应**:
```json
{
  "status": "success"
}
```

**HTTP状态码**:
- `200`: 删除成功
- `401`: Token无效或未提供
- `403`: 无权限删除该视频
- `500`: 系统错误

---

### 16. 投稿视频

**请求**: `POST /api/video/submit`

**Content-Type**: `multipart/form-data`

**请求参数** (Body):
- `token` (string, 必需): 用户Token
- `title` (string, 必需): 视频标题，最长 100 字
- `intro` (string, 必需): 简介，最长 2000 字
- `type` (int, 必需): 视频类型，1/2/3
- `category` (int, 必需): 分区，0–7（2 会转为 1）
- `tag` (string, 必需): 标签，以 # 分隔，最多 10 个
- `file_mp4` (file, 必需): 视频文件，仅支持 mp4，最大 400MB
- `file_jpg` (file, 必需): 封面图，支持 jpg/jpeg/png/gif/webp，最大 3MB
- `channel_id` (int, 可选): 所属频道 ID，默认 0
- `channel_section_id` (int, 可选): 频道二级分区 ID，默认 0

**成功响应**:
```json
{
  "status": "success",
  "data": {
    "vid": 123,
    "if_add_experience": 1
  }
}
```

**响应字段说明**:
- `vid`: 新创建的视频 ID
- `if_add_experience`: 本次是否增加经验（1=是，0=今日已达上限 150）

**错误码**:
- `missing_argument_token` / `missing_argument_title` / `missing_argument_intro` / `missing_argument_type` / `missing_argument_category` / `missing_argument_tag` / `missing_argument_file_mp4` / `missing_argument_file_jpg`: 缺少对应参数
- `error_token`: Token 无效或已过期
- `title_too_long` / `intro_too_long`: 标题或简介超长
- `tag_too_many`: 标签超过 10 个
- `error_type`: type 非法
- `error_category`: category 非法
- `error_tag`: 标签格式不合法
- `error_file`: 文件格式不支持
- `too_big_file`: 文件过大
- `channel_not_found`: 频道不存在或已删除
- `not_channel_member`: 非该频道成员
- `channel_section_not_found` / `channel_section_not_belong_to_channel`: 二级分区非法
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 投稿成功
- `400`: 参数错误
- `401`: Token 无效或未提供
- `500`: 系统错误

---

### 17. 更新视频

**请求**: `POST /api/video/update/{vid}`

**Content-Type**: `multipart/form-data`

**请求参数** (Path):
- `vid` (int, 必需): 视频 ID

**请求参数** (Body):
- `token` (string, 必需): 用户 Token
- `title` (string, 可选): 新标题，最长 100 字
- `intro` (string, 可选): 新简介，最长 2000 字
- `tag` (string, 可选): 新标签
- `category` (int, 可选): 新分区 0–7
- `file_jpg` (file, 可选): 新封面图，jpg/png/gif/webp，最大 3MB
- `file_mp4` (file, 可选): 新视频文件，mp4，最大 400MB

**成功响应**:
```json
{
  "status": "success"
}
```

**说明**:
- 仅视频作者可更新；若上传新封面或新视频，会同步上传至腾讯云 COS，并更新封面/视频版本号；更新标题/简介/标签/视频文件后，视频会进入待审核（audit_status=0）。
- 仅修改分区（category）时不会触发重新审核。

**错误码**:
- `missing_argument_vid` / `missing_argument_token`: 缺少参数
- `error_token`: Token 无效或已过期
- `error_vid`: 视频 ID 非法
- `video_not_found_or_not_owned`: 视频不存在或非本人
- `title_too_long` / `intro_too_long` / `tag_too_many`: 内容超长或标签过多
- `error_category` / `error_tag` / `error_file` / `too_big_file`: 参数非法
- `system_error`: 系统错误

**HTTP状态码**:
- `200`: 更新成功
- `400`: 参数错误
- `401`: Token 无效或未提供
- `403`: 无权限（非本人视频）
- `500`: 系统错误

---

## 接口使用流程示例

### 获取视频列表流程

1. **获取最新视频**
   ```
   GET /api/video/new?offset=0&num=20
   ```

2. **获取热门视频**
   ```
   GET /api/video/popular?time_limit=7&offset=0&num=20
   ```

3. **搜索视频**
   ```
   GET /api/video/search?search_term=关键词&offset=0&num=20&like_count_desc=1
   ```

### 视频交互流程

1. **获取视频详情**
   ```
   GET /api/video/123?token=abc123def456...
   ```

2. **点赞视频**
   ```
   POST /api/video/like/123
   Body: { "token": "abc123def456..." }
   ```

3. **收藏视频**
   ```
   POST /api/video/favorite/123
   Body: { "token": "abc123def456..." }
   ```

4. **保存观看历史**
   ```
   POST /api/video/watch-history
   Body: { "token": "abc123def456...", "vid": 123, "last_watch_second": 65 }
   ```
   （`last_watch_second` 为 -1 表示已看完）

### 视频投稿与更新流程

1. **投稿视频**（multipart/form-data）
   ```
   POST /api/video/submit
   Body: token, title, intro, type, category, tag, file_mp4, file_jpg（可选 channel_id, channel_section_id）
   ```

2. **更新视频信息或封面/视频文件**
   ```
   POST /api/video/update/123
   Body: token，以及要修改的 title / intro / tag / category / file_jpg / file_mp4
   ```

### 视频管理流程

1. **获取管理视频列表**
   ```
   GET /api/video/manage-list?offset=0&num=20&token=abc123def456...
   ```

2. **删除视频**
   ```
   DELETE /api/video/123
   Body: { "token": "abc123def456..." }
   ```

3. **获取收藏视频列表**
   ```
   GET /api/video/favorite-list?offset=0&num=20&token=abc123def456...
   ```

4. **获取历史视频列表**
   ```
   GET /api/video/history-list?token=abc123def456...
   ```

---

## 安全说明

1. **认证安全**:
   - 部分接口需要提供有效的 `token` 进行身份认证
   - Token应妥善保管，不要泄露
   - Token失效后需要重新登录获取

2. **权限控制**:
   - 删除视频操作只能删除自己的视频

3. **参数验证**:
   - 所有接口都会对输入参数进行验证
   - 无效参数会返回相应的错误信息

4. **速率限制**:
   - 部分接口可能有请求频率限制
   - 超过限制会返回相应的错误信息

---

## 常见问题

**Q: 为什么获取视频详情时需要提供token？**
A: 提供token可以获取用户对该视频的点赞和收藏状态。

**Q: 为什么删除视频失败？**
A: 可能的原因包括：
   - Token无效或未提供
   - 视频不存在或已被删除
   - 无权限删除该视频（只能删除自己的视频）

**Q: 为什么收藏/点赞视频失败？**
A: 可能的原因包括：
   - Token无效或未提供
   - 视频不存在或已被删除
   - 系统错误

**Q: 如何获取更多视频？**
A: 使用 `offset` 和 `num` 参数进行分页查询。

**Q: 如何排序搜索结果？**
A: 使用 `vid_desc`、`view_count_desc`、`like_count_desc`、`favorite_count_desc` 参数进行排序。
