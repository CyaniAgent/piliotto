import { defineConfig } from 'vitepress'
import { teekConfig } from "./teekConfig.mts";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  extends: teekConfig,
  title: "PiliOtto",
  description: "By SakuraCake",
  head: [
    [
      'script',
      {
        async: '',
        src: 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3483226632276812',
        crossorigin: 'anonymous'
      }
    ]
  ],
  themeConfig: {
    logo: '/logo.png',
    siteTitle: 'PiliOtto',
    nav: [
      { text: '首页', link: '/' },
      { text: '用户指南', link: '/user-guide' },
      { text: '开发文档', link: '/guide/' }
    ],

    sidebar: {
      '/guide/': [
        {
          text: '开发文档',
          items: [
            { text: '开发入门', link: '/guide/dev-start' },
            { text: '项目总览', link: '/guide/' },
            {
              text: '核心分层',
              collapsed: false,
              items: [
                { text: '数据模型层', link: '/guide/core/models' },
                { text: '仓储层', link: '/guide/core/repositories' },
                { text: '服务层', link: '/guide/core/services' },
                { text: '工具函数层', link: '/guide/core/utils' },
                { text: '通用组件层', link: '/guide/core/common' },
                { text: '路由系统', link: '/guide/core/router' },
                { text: 'OttoHub API', link: '/guide/core/ottohub' },
                { text: '自定义插件', link: '/guide/core/plugin' },
              ]
            },
            {
              text: '页面模块',
              collapsed: false,
              items: [
                { text: '首页 (Home)', link: '/guide/pages/home' },
                { text: '主框架 (Main)', link: '/guide/pages/main' },
                { text: '视频详情 (Video)', link: '/guide/pages/video-detail' },
                { text: '搜索 (Search)', link: '/guide/pages/search' },
                { text: '动态 (Dynamics)', link: '/guide/pages/dynamics' },
                { text: '用户主页 (Member)', link: '/guide/pages/member' },
                { text: '设置 (Setting)', link: '/guide/pages/setting' },
                { text: '登录 (Login)', link: '/guide/pages/login' },
                { text: '消息 (Message)', link: '/guide/pages/message' },
                { text: '收藏 (Fav)', link: '/guide/pages/fav' },
                { text: '历史记录 (History)', link: '/guide/pages/history' },
                { text: '关注/粉丝 (Follow)', link: '/guide/pages/follow' },
                { text: '热门 (Hot)', link: '/guide/pages/hot' },
                { text: '排行 (Rank)', link: '/guide/pages/rank' },
                { text: '媒体 (Media)', link: '/guide/pages/media' },
                { text: '个人中心 (Mine)', link: '/guide/pages/mine' },
                { text: '关于 (About)', link: '/guide/pages/about' },
                { text: '网页浏览 (Webview)', link: '/guide/pages/webview' },
                { text: '弹幕 (Danmaku)', link: '/guide/pages/danmaku' },
              ]
            }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/CyaniAgent/piliotto' }
    ]
  }
})
