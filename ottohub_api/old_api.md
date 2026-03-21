# 旧版api
## 请在使用前先确认是否需要使用旧版api，否则请使用新版api

# 一、auth
## 1.login(登录)
参数：uid_email、pw

正确返回值：uid(UID)、token(token)、avatar_url(头像URL)、cover_url(封面URL)、if_today_first_login(今日是否首次登录)、email(邮箱)、is_audit(是否是审核员)、is_admin(是否是管理员)

错误返回值：missing_argument(缺少参数)、error_password(密码错误)
## 2.register(注册)
参数：email(邮箱)、register_verification_code(验证码)、pw(密码)、confirm_pw(确认密码)

正确返回值：无

错误返回值：missing_argument(缺少参数)、mismatch_pw
(两次密码不一样)、error_pw(错误密码)、email_exist(邮箱已存在)、error_verification_code(验证码错误)、system_error(系统错误)
## 3.passwordreset(重置密码)
参数：email(邮箱)、passwordreset_verification_code(验证码)、pw(密码)、confirm_pw(确认密码)

正确返回值：无

错误返回值：missing_argument(缺少参数)、mismatch_pw
(两次密码不一样)、error_pw(错误密码)、email_unexist(邮箱不存在)、error_verification_code(验证码错误)、system_error(系统错误)
## 4.register_verification_code(发送注册验证码)
参数：email(邮箱)

正确返回值：无

错误返回值：missing_argument(缺少参数)、email_exist(邮箱已存在)、error_email(邮箱错误)、error_qq_email（非纯数字qq邮箱）、system_error(系统错误)
## 5.passwordreset_verification_code(发送重置密码验证码)
参数：email(邮箱)

正确返回值：无

错误返回值：missing_argument(缺少参数)、email_unexist(邮箱不存在)、system_error(系统错误)
## 6.sign_in(签到)
参数：token

正确返回值：if_today_first_login(今日是否首次登录)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)

# 二、video
## 1.random_video_list(随机视频)
参数：num(限制数量)

正确返回值：
video_list(随机视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 2.new_video_list(最新视频)
参数：offset(偏移量)、num(限制数量)、type(版权类型)

正确返回值：
video_list(最新视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 3.popular_video_list(热门视频)
参数：time_limit(时间范围)、offset(偏移量)、num(限制数量)

正确返回值：
video_list(热门视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 4.category_video_list(分区视频)
参数：category(分区)、num(限制数量)

正确返回值：
video_list(分区视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 5.search_video_list(搜索视频)
参数：search_term(搜索词)、num(限制数量)

正确返回值：
video_list(搜索视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 6.id_video_list(指定视频)
参数：vid(VID)

正确返回值：
video_list(指定视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_vid(错误VID)、system_error(系统错误)
## 7.user_video_list(用户视频)
参数：uid(UID)、offset(偏移量)、num(限制数量)

正确返回值：
video_list(用户视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 8.audit_video_list(审核视频)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
video_list(用户视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、intro(简介)、tag(标签)、cover_url(视频封面)、video_url(视频URL)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、not_reviewer(不是审核员)、system_error(系统错误)
## 9.get_video_detail(视频详情)
参数：vid(VID)、token(可忽视)

正确返回值：vid(动态编号)、uid(作者UID)、title(标题)、intro(简介)、type(版权)、category(分区)、tag(标签)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、cover_url(视频封面)、video_url(视频URL)、audio_url(音频URL)、username(作者昵称)、userintro(作者简介)、avatar_url(作者头像)、if_like(我是否点赞)、if_favorite(我是否收藏)、video_width(视频宽度像素)、video_height(视频高度像素)、video_sar(视频采样纵横比)、video_dar(视频显示宽高比)、duration(视频时长)、comment_count(评论数)、video_m3u8_url(HLS视频流URL)、channel_id(频道ID)、channel_detail(可选 频道信息对象)[channel_detail.channel_id(频道ID)、channel_detail.channel_name(频道名)、channel_detail.channel_title(频道显示名称)、channel_detail.description(频道描述)、channel_detail.cover_url(频道封面URL)]、last_watch_second(可选 最后观看到的秒数 -1表示已看完)

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_vid(错误VID)、system_error(系统错误)
## 10.related_video_list(相关视频)
参数：vid、num(限制数量)、offset(偏移量)

正确返回值：
video_list(相关视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 11.save_video_watch_history(记录视频观看进度)
参数：vid(VID)、last_watch_second(最后观看到的秒数，-1表示已看完)、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、system_error(系统错误)

# 三、blog
## 1.random_blog_list(随机动态)
参数：num(限制数量)

正确返回值：
blog_list(随机动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 2.new_blog_list(最新动态)
参数：offset(偏移量)、num(限制数量)

正确返回值：
blog_list(最新动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 3.popular_blog_list(热门动态)
参数：time_limit(时间范围)、offset(偏移量)、num(限制数量)

正确返回值：
blog_list(热门动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 4.search_blog_list(搜索动态)
参数：search_term(搜索词)、num(限制数量)

正确返回值：
blog_list(搜索动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 5.id_blog_list(指定动态)
参数：bid(BID)

正确返回值：
blog_list(指定动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_bid(错误BID)、system_error(系统错误)
## 6.user_blog_list(用户动态)
参数：uid(UID)、offset(偏移量)、num(限制数量)

正确返回值：
blog_list(用户动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 7.audit_blog_list(审核动态)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
blog_list(用户动态列表数组)
[bid(动态编号)、title(标题)、content(内容)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、not_reviewer(不是审核员)、system_error(系统错误)
## 8.get_blog_detail(动态详情)
参数：bid(BID)、token(可忽视)

正确返回值：bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(作者头像)、username(作者昵称)、comment_count(评论数)、if_like(我是否点赞)、if_favorite(我是否收藏)、thumbnails(缩略图URL数组)、channel_id(频道ID)、channel_detail(可选 频道信息对象)[channel_detail.channel_id(频道ID)、channel_detail.channel_name(频道名)、channel_detail.channel_title(频道显示名称)、channel_detail.description(频道描述)、channel_detail.cover_url(频道封面URL)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_bid(错误BID)、system_error(系统错误)
## 9.related_blog_list(相关动态)
参数：bid(BID)、num(限制数量)、offset(偏移量)

正确返回值：
blog_list(相关动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(作者头像)、username(作者昵称)、comment_count(评论数)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)

# 四、user
## 1.select_user_list(搜索用户列表)
参数：search_term(搜索词)、num(限制数量)

正确返回值：
user_list(搜索用户列表数组)
[uid(UID)、username(昵称)、intro(简介)、time(时间)、avatar_url(头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 2.id_user_list(指定用户列表)
参数：uid(UID)

正确返回值：
user_list(搜索用户列表数组)
[uid(UID)、username(昵称)、intro(简介)、time(时间)、avatar_url(头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_uid(错误UID)、system_error(系统错误)
## 3.get_user_detail(用户详情)
参数：uid(UID)

正确返回值：uid(UID)、username(用户名)、intro(简介)、time(注册时间)、sex(性别)、honour(荣誉)、experience(经验值)、avatar_url(头像)、cover_url(封面)、video_num(上传视频数量)、blog_num(上传动态数量)、media_num(上传媒体数量)、followings_count(关注数)、fans_count(粉丝数)

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_uid(错误UID)、system_error(系统错误)

# 五、following
## 1.follow(关注用户)
参数：following_uid(关注对象UID)、token

正确返回值：new_fans_count(新的粉丝数)、follow_status(当前关注状态)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_following_uid(错误关注对象)、too_many_followings(关注者超过888人)、system_error(系统错误)
## 2.follow_status(关注状态)
参数：following_uid(关注对象UID)、token

正确返回值：follow_status(关注状态)：0(这是我自己)、1(互相未关注)、2(我关注对方)、3(对方关注我)、4(互相关注)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_following_uid(错误关注对象)、system_error(系统错误)
## 3.following_list(关注列表)
参数：uid、offset(偏移量)、num(限制数量)、token(可忽略)

正确返回值：user_list(搜索用户列表数组)
[uid(UID)、username(昵称)、intro(简介)、avatar_url(头像)、follow_status(相互关注关系)]

错误返回值：missing_argument(缺少参数)、error_uid(错误UID)、too_big_num(数量太大)、system_error(系统错误)
## 4.fan_list(粉丝列表)
参数：uid、offset(偏移量)、num(限制数量)、token(可忽略)

正确返回值：user_list(搜索用户列表数组)
[uid(UID)、username(昵称)、intro(简介)、avatar_url(头像)、follow_status(相互关注关系)]

错误返回值：missing_argument(缺少参数)、error_uid(错误UID)、too_big_num(数量太大)、system_error(系统错误)
## 5.following_all_timeline(所有关注者内容列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
timeline_list(所有关注者内容列表数组)
[content_type(内容类型)、vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]
[content_type(内容类型)、bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_uid(错误UID)、too_big_num(数量太大)、system_error(系统错误)
## 6.following_user_timeline(某个关注者内容列表)
参数：uid、offset(偏移量)、num(限制数量)

正确返回值：
timeline_list(某个关注者内容列表数组)
[content_type(内容类型)、vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]
[content_type(内容类型)、bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(发送者头像)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_uid(错误UID)、too_big_num(数量太大)、system_error(系统错误)
## 7.following_active_list(关注者活跃列表)
参数：uid、offset(偏移量)、num(限制数量)

正确返回值：user_list(搜索用户列表数组)
[uid(UID)、username(昵称)、avatar_url(头像)、latest_activity_time(最后活跃时间)]

错误返回值：missing_argument(缺少参数)、error_uid(错误UID)、too_big_num(数量太大)、system_error(系统错误)

# 六、im
## 1.new_message_num(未读消息数)
参数：token

正确返回值：new_message_num(未读消息数)

错误返回值：missing_argument(缺少参数)、error_token(错误token)
## 2.read_message_list(已读消息列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
read_message_list(已读消息列表数组)
[msg_id(消息编号)、sender(发送者UID)、receiver(接收者UID)、content(内容)、time(时间)、sender_name(发送者昵称)、receiver_name(接收者昵称)、sender_avatar_url(发送者头像)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 3.unread_message_list(未读消息列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
unread_message_list(未读消息列表数组)
[msg_id(消息编号)、sender(发送者UID)、receiver(接收者UID)、content(内容)、time(时间)、sender_name(发送者昵称)、receiver_name(接收者昵称)、sender_avatar_url(发送者头像)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 4.sent_message_list(已发消息列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
sent_message_list(已发消息列表数组)
[msg_id(消息编号)、sender(发送者UID)、receiver(接收者UID)、content(内容)、time(时间)、sender_name(发送者昵称)、receiver_name(接收者昵称)、receiver_avatar_url(接收者头像)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 5.send_message(发送消息)
参数：token、receiver(接收者UID)、message(信息内容)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_receiver(错误的接收者)、too_short_message(信息太短)、too_long_message(信息太长)、warn(触发敏感词)、blocked(存在拉黑关系)、system_error(系统错误)
## 6.read_message(读取消息)
参数：token、msg_id(消息编号)

正确返回值：sender(发送者UID)、receiver(接收者UID)、content(内容)、sender_name(发送者昵称)、receiver_name(接收者昵称)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_msg_id(错误的消息编号)、system_error(系统错误)
## 7.read_all_system_message(系统消息一键已读)
参数：token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)
## 8.delete_message(删除消息)
参数：token、msg_id(消息编号)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、no_permission(没有权限)、system_error(系统错误)
## 9.friend_list(好友列表)
参数：token、offset(偏移量)、num(限制数量)、if_time_desc(是否按照时间倒序 默认1)

正确返回值：user_list(好友列表数组)
[uid(UID)、username(昵称)、intro(简介)、avatar_url(头像)、last_time(最后沟通时间)、last_message(最后沟通内容)、new_message_num(未读消息数)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、too_big_num(数量太大)、system_error(系统错误)
## 10.friend_message(好友消息)
参数：token、friend_uid(好友UID)、offset(偏移量)、num(限制数量)、if_time_desc(是否按照时间倒序 默认1)

正确返回值：
message_list(好友消息列表数组)
[msg_id(消息编号)、sender(发送者UID)、receiver(接收者UID)、content(内容)、time(时间)、sender_name(发送者昵称)、sender_avatar_url(发送者头像)、receiver_name(接收者昵称)、receiver_avatar_url(接收者头像)、is_read(是否已读)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_friend_uid(错误好友UID)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)

# 七、engagement
## 1.like_blog(点赞动态)
参数：bid、token

正确返回值：if_like(当前是否点赞)、like_count(当前点赞数)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、system_error(系统错误)
## 2.favorite_blog(收藏动态)
参数：bid、token

正确返回值：if_favorite(当前是否收藏)、like_favorite(当前收藏数)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、blog_deleted(动态已被删除)、system_error(系统错误)
## 3.like_video(点赞视频)
参数：vid、token

正确返回值：if_like(当前是否点赞)、like_count(当前点赞数)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、system_error(系统错误)
## 4.favorite_video(收藏视频)
参数：vid、token

正确返回值：if_favorite(当前是否收藏)、like_favorite(当前收藏数)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、video_deleted(视频已被删除)、system_error(系统错误)

# 八、manage
## 1.delete_blog(删除动态)
参数：bid、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、system_error(系统错误)
## 2.appeal_blog(申诉动态)
参数：bid、token、reason(必填 申诉理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 3.delete_video(删除视频)
参数：vid、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、system_error(系统错误)
## 4.appeal_video(申诉视频)
参数：vid、token、reason(必填 申诉理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、reason_too_long(reason字数超过50字)、system_error(系统错误)

# 九、moderation
## 1.report_blog(举报动态)
参数：bid、token、reason(必填 举报理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 2.approve_blog(过审动态)
参数：bid、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、not_reviewer(不是审核员)、system_error(系统错误)
## 3.reject_blog(打回动态)
参数：bid、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bid(错误BID)、not_reviewer(不是审核员)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 4.report_video(举报视频)
参数：vid、token、reason(必填 举报理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 5.approve_video(过审视频)
参数：vid、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、not_reviewer(不是审核员)、system_error(系统错误)
## 6.reject_video(打回视频)
参数：vid、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vid(错误VID)、not_reviewer(不是审核员)、reason_too_long(reason字数超过50字)、system_error(系统错误)

# 十、comment
## 1.blog_comment_list(动态评论列表)
参数：bid、parent_bcid、token(可忽视)、offset(偏移量)、num(限制数量)、cid_asc(可忽略 1为升序 0或无此参数为降序)

正确返回值：
comment_list(动态评论列表数组)
[bcid(动态评论编号)、parent_bcid(父动态评论编号)、uid(UID)、content(内容)、time(时间)、child_comment_num(子评论数量)、if_my_comment(是否是我的评论)、username(用户昵称)、honour(用户荣誉)、avatar_url(用户头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 2.video_comment_list(视频评论列表)
参数：vid、parent_vcid、token(可忽视)、offset(偏移量)、num(限制数量)、cid_asc(可忽略 1为升序 0或无此参数为降序)

正确返回值：
comment_list(视频评论列表数组)
[vcid(视频评论编号)、parent_vcid(父视频评论编号)、uid(UID)、content(内容)、time(时间)、child_comment_num(子评论数量)、if_my_comment(是否是我的评论)、username(用户昵称)、honour(用户荣誉)、avatar_url(用户头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 3.comment_blog(评论动态或评论动态评论)
参数：bid、parent_bcid、token、content(评论内容，\n表示换行)

正确返回值：if_get_experience(是否获得经验)、if_warn(是否含有敏感词)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、content_too_long(评论太长)、content_too_short(评论太短)、error_type(错误数值类型)、error_bid(错误BID)、error_parent_bcid(错误BCID)、error_parent(楼中楼中楼)、warn(触发敏感词)、blocked(存在拉黑关系)、system_error(系统错误)
## 4.comment_video(评论视频或评论视频评论)
参数：vid、parent_vcid(父视频评论编号，0 代表顶级评论)、token、content(评论内容，\n表示换行)

正确返回值：if_get_experience(是否获得经验)、if_warn(是否含有敏感词)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、content_too_long(评论太长)、content_too_short(评论太短)、error_type(错误数值类型)、error_vid(错误VID)、error_parent_vcid(错误VCID)、error_parent(楼中楼中楼)、warn(触发敏感词)、blocked(存在拉黑关系)、system_error(系统错误)
## 5.delete_blog_comment(删除动态评论)
参数：bcid、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bcid(错误BCID)、no_permission(没有权限)、system_error(系统错误)
## 6.delete_video_comment(删除视频评论)
参数：vcid、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vcid(错误VCID)、no_permission(没有权限)、system_error(系统错误)
## 7.report_blog_comment(举报动态评论)
参数：bcid、token、reason(必填 举报理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bcid(错误BCID)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 8.report_video_comment(举报视频评论)
参数：vcid、token、reason(必填 举报理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vcid(错误VCID)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 9.audit_blog_comment_list(审核动态评论列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
comment_list(动态评论列表数组)
[bcid(视频评论编号)、parent_bcid(父视频评论编号)、uid(UID)、content(内容)、time(时间)、username(用户昵称)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、no_permission(没有权限)、system_error(系统错误)
## 10.audit_video_comment_list(审核视频评论列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
comment_list(视频评论列表数组)
[vcid(视频评论编号)、parent_vcid(父视频评论编号)、uid(UID)、content(内容)、time(时间)、child_comment_num(子评论数量)、if_my_comment(是否是我的评论)、username(用户昵称)、honour(用户荣誉)、avatar_url(用户头像)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、no_permission(没有权限)、system_error(系统错误)
## 11.approve_blog_comment(通过动态评论)
参数：bcid(动态评论编号)、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bcid(错误动态评论编号)、no_permission(没有权限)、system_error(系统错误)
## 12.approve_video_comment(通过视频评论)
参数：vcid(视频评论编号)、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vcid(错误视频评论编号)、no_permission(没有权限)、system_error(系统错误)
## 13.reject_blog_comment(退回动态评论)
参数：bcid(动态评论编号)、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_bcid(错误动态评论编号)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 14.reject_video_comment(退回视频评论)
参数：vcid(视频评论编号)、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_vcid(错误视频评论编号)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)

# 十一、profile
## 1.favorite_blog_list(收藏动态列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
favorite_blog_count(收藏动态总数)、
blog_list(收藏动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、is_deleted(是否删除)、audit_status(审核状态)、avatar_url(发送者头像)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 2.favorite_video_list(收藏视频列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
favorite_video_count(收藏视频总数)、
video_list(收藏视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、is_deleted(是否删除)、audit_status(审核状态)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 3.history_video_list(视频历史记录)
参数：token

正确返回值：
video_list(热门视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)
## 4.user_profile(用户资料)
参数：token

正确返回值：profile(资料)
[uid(UID)、email(邮箱)、phone(电话)、qq(QQ)、username(昵称)、time(注册时间)、sex(性别)、intro(简介)、honour(荣誉)、experience(经验)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)
## 5.update_username(更新昵称)
参数：token、username(昵称)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_username(非法昵称)、username_exist(昵称已存在)、warn(触发敏感词)、system_error(系统错误)
## 6.update_pw(更新密码)
参数：token、pw(密码)

正确返回值：new_token(新的token)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_pw(非法密码)、system_error(系统错误)
## 7.update_phone(更新手机号)
参数：token、pw(密码)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_phone(非法手机号)、system_error(系统错误)
## 8.update_qq(更新QQ)
参数：token、qq(QQ)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_qq(非法QQ号)、system_error(系统错误)
## 9.update_sex(更新性别)
参数：token、sex(性别)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_sex(非法性别)、warn(触发敏感词)、system_error(系统错误)
## 10.update_intro(更新简介)
参数：token、intro(简介)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_intro(非法简介)、warn(触发敏感词)、system_error(系统错误)
## 11.approve_avatar(通过头像)
参数：uid_of_avatar、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_uid(错误UID)、not_reviewer(不是审核员)、system_error(系统错误)
## 12.reject_avatar(退回头像)
参数：uid_of_avatar、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_uid(错误UID)、not_reviewer(不是审核员)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 13.approve_cover(通过封面)
参数：uid_of_cover、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_uid(错误UID)、not_reviewer(不是审核员)、system_error(系统错误)
## 14.reject_cover(退回封面)
参数：uid_of_cover、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_uid(错误UID)、not_reviewer(不是审核员)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 15.user_data(用户数据)
参数：token

正确返回值：video_num(上传视频数量)、blog_num(上传动态数量)、followings_count(关注数)、fans_count(粉丝数)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)
## 16.manage_blog_list(管理动态列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
manage_blog_count(收藏动态总数)、
blog_list(管理动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、is_deleted(是否删除)、audit_status(审核状态)、avatar_url(发送者头像)、thumbnails(缩略图URL数组)、collection(所属合集名称)、collection_sort_order(所属合集排序)、channel_id(频道ID)、channel_detail(可选 频道信息对象)[channel_detail.channel_id(频道ID)、channel_detail.channel_name(频道名)、channel_detail.channel_title(频道显示名称)、channel_detail.description(频道描述)、channel_detail.cover_url(频道封面URL)]]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 17.manage_video_list(管理视频列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
manage_video_count(收藏视频总数)、
video_list(管理视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、is_deleted(是否删除)、audit_status(审核状态)、cover_url(视频封面)、collection(所属合集名称)、collection_sort_order(所属合集排序)、channel_id(频道ID)、channel_detail(可选 频道信息对象)[channel_detail.channel_id(频道ID)、channel_detail.channel_name(频道名)、channel_detail.channel_title(频道显示名称)、channel_detail.description(频道描述)、channel_detail.cover_url(频道封面URL)]]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 18.audit_avatar_list(审核头像列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
avatar_list(审核头像列表数组)
[uid(用户UID)、username(用户名)、avatar_url(头像URL)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、not_reviewer(不是审核员)、system_error(系统错误)
## 19.audit_cover_list(审核封面列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
cover_list(审核封面列表数组)
[uid(用户UID)、username(用户名)、cover_url(封面URL)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、not_reviewer(不是审核员)、system_error(系统错误)
## 18.is_audit(是否是审核)
参数：token

正确返回值：is_audit(是否是审核)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)

# 十二、creator
## 1.submit_blog(发布动态)
参数：token、title(标题)、content(内容)、channel_id(可选 频道ID)、channel_section_id(可选 频道二级分区ID)

正确返回值：if_add_experience(是否增加经验)、if_warn(是否含有敏感词)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、title_too_long
(标题过长)、content_too_long(内容过长)、title_too_short(标题过短)、content_too_short(内容过短)、warn(触发敏感词)、channel_not_found(频道不存在或已被删除)、not_channel_member(不是该频道成员)、channel_section_not_found(二级分区不存在或已被删除)、channel_section_not_belong_to_channel(二级分区不属于该频道)、system_error(系统错误)
## 2.submit_video(发布视频)
参数：token、title(标题)、intro(简介)、type(版权)、category(分区)、tag(标签)、file_mp4(视频文件)、file_jpg(头像文件)、channel_id(可选 频道ID)、channel_section_id(可选 频道二级分区ID)

正确返回值：if_add_experience(是否增加经验)

错误返回值：missing_argument_token(缺少参数)、missing_argument_title(缺少参数)、missing_argument_intro(缺少参数)、missing_argument_type(缺少参数)、missing_argument_category(缺少参数)、missing_argument_tag(缺少参数)、missing_argument_file_mp4(缺少参数)、missing_argument_file_jpg(缺少参数)、error_token(错误token)、title_too_long(标题过长)、title_too_short(标题过短)、intro_too_long(简介过长)、intro_too_short(简介过短)、tag_too_few(标签太少)、tag_too_many(标签太多)、error_type(错误版权)、error_category(错误分区)、error_tag(错误标签)、warn(触发敏感词)、error_file(错误文件格式)、too_big_file(文件太大)、channel_not_found(频道不存在或已被删除)、not_channel_member(不是该频道成员)、channel_section_not_found(二级分区不存在或已被删除)、channel_section_not_belong_to_channel(二级分区不属于该频道)、system_error(系统错误)
## 3.update_avatar(更新头像)
参数：token、file_jpg(头像文件)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_file(错误文件格式)、file_not_found(缺少文件)、too_big_file(文件太大)、system_error(系统错误)
## 4.update_cover(更新封面)
参数：token、file_jpg(封面文件)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_file(错误文件格式)、file_not_found(缺少文件)、too_big_file(文件太大)、system_error(系统错误)
## 5.save_blog(保存动态草稿)
参数：token、content(动态草稿内容)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、content_too_long(内容过长)、warn(触发敏感词)、system_error(系统错误)
## 6.load_blog(加载动态草稿)
参数：token

正确返回值：content(动态草稿内容)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、system_error(系统错误)
## 7.submit_image(上传图片)
参数：token、file_img(图片文件)

正确返回值：image_url(图片url)

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_file(错误文件格式)、file_not_found(缺少文件)、too_big_file(文件太大)、system_error(系统错误)
## 8.update_video(修改视频信息)
参数：token、vid、title(可选)、intro(可选)、tag(可选)、category(可选)、file_jpg(可选 封面文件)、file_mp4(可选 视频文件)

正确返回值：无

错误返回值：missing_argument_token(缺少token)、missing_argument_vid(缺少vid)、error_token(错误token)、error_vid(错误vid)、title_too_long(标题过长)、title_too_short(标题过短)、intro_too_long(简介过长)、intro_too_short(简介过短)、tag_too_few(标签太少)、tag_too_many(标签太多)、error_tag(错误标签)、error_category(错误分区)、video_not_found_or_not_owned(视频不存在或非所有者)、error_file(错误文件)、too_big_file(文件太大)、system_error(系统错误)

# 十三、system
## 1.version(api版本号)
参数：无

正确返回值：version(版本号)

错误返回值：system_error(系统错误)
## 2.slideshow(幻灯片)
参数：无

正确返回值：
slides(幻灯片数组)
[img_url(图片url)、title(标题)、href(链接)]

错误返回值：system_error(系统错误)
## 3.launch_screen(开屏动画)
参数：无

正确返回值：launch_screen_url(开屏动画url)、dark_launch_screen_url(深色模式开屏动画url)

错误返回值：system_error(系统错误)
## 4.legal_documents(法律文档)
参数：无

正确返回值：documents(法律文档数组)
[terms_of_service_url(用户协议md文档的url)、privacy_policy_url(隐私政策md文档的url)、platform_content_review_specification_url(平台内容审核规范md文档的url)]

错误返回值：system_error(系统错误)

# 十四、danmaku
## 1.get_danmaku(获取弹幕)
参数：vid

正确返回值：
data(弹幕列表数组)
[text(文本)、time(弹幕出现的时间)、mode(弹幕类型)、color(文字颜色)、font_size(字体大小)、render(高级弹幕渲染语句)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、system_error(系统错误)
## 2.send_danmaku(发送弹幕)
参数：vid、token、text(弹幕文本)、time(弹幕出现的时间)、mode(弹幕类型)、color(颜色)、font_size(字号)、render(高级弹幕渲染方式)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_time(错误时间)、error_mode(错误弹幕类型)、error_color(错误颜色)、error_font_size(错误字号)、warn(触发敏感词)、text_too_long(弹幕太长)、text_too_short(弹幕太短)、render_too_long(渲染语句太长)、no_permission(没有权限)、system_error(系统错误)
## 3.delete_danmaku(删除弹幕)
参数：danmaku_id(弹幕编号)、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_danmaku_id(错误弹幕编号)、no_permission(没有权限)、system_error(系统错误)
## 4.report_danmaku(举报弹幕)
参数：danmaku_id(弹幕编号)、token、reason(必填 举报理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_danmaku_id(错误弹幕编号)、reason_too_long(reason字数超过50字)、system_error(系统错误)
## 5.audit_danmaku_list(审核弹幕列表)
参数：token、offset(偏移量)、num(限制数量)

正确返回值：
danmaku_list(弹幕列表数组)
[text(文本)、time(弹幕出现的时间)、mode(弹幕类型)、color(文字颜色)、font_size(字体大小)、render(高级弹幕渲染语句)]

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、too_big_num(数量太大)、no_permission(没有权限)、system_error(系统错误)
## 6.approve_danmaku(通过弹幕)
参数：danmaku_id(弹幕编号)、token

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_danmaku_id(错误弹幕编号)、no_permission(没有权限)、system_error(系统错误)
## 7.reject_danmaku(退回弹幕)
参数：danmaku_id(弹幕编号)、token、reason(必填 退回理由 字数不超过50字)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_danmaku_id(错误弹幕编号)、no_permission(没有权限)、reason_too_long(reason字数超过50字)、system_error(系统错误)

# 十五、collection
## 1.set_video_collection(设置视频所属合集)
参数：vid、token、collection(合集名称)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_collection(错误合集)、warn(触发敏感词)、text_too_long(合集名称太长)、no_permission(没有权限)、system_error(系统错误)
## 2.get_video_collection(获取视频所属合集列表)
参数：vid

正确返回值：
collection(视频所属合集名称)、
video_list(合集视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)、collection_sort_order(排序值)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、video_not_in_collection(视频不属于某个合集)、system_error(系统错误)
## 3.get_user_video_collection(用户拥有的视频合集)
参数：uid

正确返回值：
collection_list(视频合集列表数组)
[collection(合集名称)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、system_error(系统错误)
## 4.video_collection_list(视频合集详细列表)
参数：uid、collection(合集名称)

正确返回值：
collection(视频所属合集名称)、
video_list(合集视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)、collection_sort_order(排序值)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_collection(错误合集)、system_error(系统错误)
## 5.set_video_collection_sort_order(设置视频合集排序值)
参数：vid、token、collection_sort_order(排序值)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_vid(错误vid)、error_token(错误token)、no_collection(视频不属于某个合集)、system_error(系统错误)
## 6.delete_video_collection(解散视频合集)
参数：token、collection(合集名称)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、no_collection(无此合集)、system_error(系统错误)

## 7.set_blog_collection(设置动态所属合集)
参数：bid、token、collection(合集名称)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、error_type(错误数值类型)、error_collection(错误合集)、warn(触发敏感词)、text_too_long(合集名称太长)、no_permission(没有权限)、system_error(系统错误)

## 8.get_blog_collection(获取动态所属合集列表)
参数：bid

正确返回值：
collection(动态所属合集名称)、
blog_list(合集动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(作者头像)、username(作者昵称)、thumbnails(缩略图URL数组)、collection_sort_order(排序值)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、blog_not_in_collection(动态不属于某个合集)、system_error(系统错误)

## 9.get_user_blog_collection(用户拥有的动态合集)
参数：uid

正确返回值：
collection_list(动态合集列表数组)
[collection(合集名称)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、system_error(系统错误)

## 10.blog_collection_list(动态合集详细列表)
参数：uid、collection(合集名称)

正确返回值：
collection(动态所属合集名称)、
blog_list(合集动态列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、avatar_url(作者头像)、username(作者昵称)、thumbnails(缩略图URL数组)、collection_sort_order(排序值)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_collection(错误合集)、system_error(系统错误)

## 11.set_blog_collection_sort_order(设置动态合集排序值)
参数：bid、token、collection_sort_order(排序值)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、error_bid(错误bid)、error_token(错误token)、no_collection(动态不属于某个合集)、system_error(系统错误)

## 12.delete_blog_collection(解散动态合集)
参数：token、collection(合集名称)

正确返回值：无

错误返回值：missing_argument(缺少参数)、error_token(错误token)、no_collection(无此合集)、system_error(系统错误)

# 十六、search
## 1.video_search(搜索视频)
参数：search_term(搜索词)、offset(偏移量)、num(限制数量)、vid_desc(是否按从新到旧排序)、view_count_desc(是否按观看量排序)、like_count(是否按点赞量排序)、favorite_count(是否按收藏量排序)、uid(是否限定UID)、type(是否限定版权类型)

正确返回值：
total_count(匹配结果总数)、
video_list(视频列表数组)
[vid(视频编号)、uid(作者UID)、title(标题)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、duration(视频时长)、cover_url(视频封面)、username(作者昵称)、avatar_url(作者头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 2.blog_search(搜索动态)
参数：search_term(搜索词)、offset(偏移量)、num(限制数量)、bid_desc(是否按从新到旧排序)、view_count_desc(是否按观看量排序)、like_count(是否按点赞量排序)、favorite_count(是否按收藏量排序)、uid(是否限定UID)

正确返回值：
total_count(匹配结果总数)、
blog_list(视频列表数组)
[bid(动态编号)、uid(作者UID)、title(标题)、content(内容)、time(时间)、like_count(点赞数)、favorite_count(收藏数)、view_count(浏览量)、username(作者昵称)、avatar_url(发送者头像)、thumbnails(缩略图URL数组)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)
## 3.user_search(搜索用户)
参数：search_term(搜索词)、offset(偏移量)、num(限制数量)、uid_desc(是否按从新到旧排序)、fans_count_desc(是否按粉丝数量排序)、experience_desc(是否按经验高低排序)

正确返回值：
total_count(匹配结果总数)、
user_list(搜索用户列表数组)
[uid(UID)、username(昵称)、intro(简介)、honour(荣誉)、fans_count(粉丝数)、level(等级)、avatar_url(头像)]

错误返回值：missing_argument(缺少参数)、error_type(错误数值类型)、too_big_num(数量太大)、system_error(系统错误)

# 全局报错
system_error(系统错误)、too_many_requests(请求频率过高)
