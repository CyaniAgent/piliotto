import { defineTeekConfig } from "vitepress-theme-teek/config";

export const teekConfig = defineTeekConfig({
    teekTheme: true,
    teekHome: false,
    vpHome: true,
    loading: false,
    homeCardListPosition: "right",
    anchorScroll: true,

    viewTransition: {
        enabled: true,
        mode: "out-in",
        duration: 300,
        easing: "ease-in",
    },

    themeSize: "default",

    backTop: {
        enabled: true,
        content: "progress",
        // done: TkMessage => TkMessage.success("返回顶部成功"),
    },

    toComment: {
        enabled: true,
        // done: TkMessage => TkMessage.success("滚动到评论区成功"),
    },

    codeBlock: {
        enabled: true,
        collapseHeight: 700,
        overlay: false,
        overlayHeight: 400,
        langTextTransform: "uppercase",
        copiedDone: TkMessage => TkMessage.success("复制成功！"),
    },

    sidebarTrigger: false,
    windowTransition: true,

    themeEnhance: {
        enabled: true,
        position: "top",
        layoutSwitch: {
            disabled: false,
            defaultMode: "original",
            disableHelp: false,
            disableAnimation: false,
            defaultDocMaxWidth: 90,
            disableDocMaxWidthHelp: false,
            defaultPageMaxWidth: 95,
            disablePageMaxWidthHelp: false,
        },
        themeColor: {
            disabled: false,
            defaultColorName: "vp-default",
            defaultSpread: false,
            disableHelp: false,
            disabledInMobile: false,
        },
        spotlight: {
            disabled: false,
            defaultStyle: "aside",
            disableHelp: false,
            defaultValue: true,
        },
    },

    author: {
        name: "SakuraCake",
        link: "https://github.com/SakuraCake",
    },

    post: {
        postStyle: "list",
        excerptPosition: "top",
        showMore: true,
        moreLabel: "阅读全文 >",
        emptyLabel: "暂无文章",
        coverImgMode: "default",
        showCapture: false,
        splitSeparator: false,
        transition: true,
        transitionName: "tk-slide-fade",
        listStyleTitleTagPosition: "right",
        cardStyleTitleTagPosition: "left",
        defaultCoverImg: [],
    },

    page: {
        disabled: false,
        pageSize: 20,
        pagerCount: 7,
        layout: "prev, pager, next, jumper, ->, total",
        size: "default",
        background: false,
        hideOnSinglePage: false,
    },

    homeCardSort: ["topArticle", "category", "tag", "friendLink", "docAnalysis"],

    tagColor: [
        { border: "#bfdbfe", bg: "#eff6ff", text: "#2563eb" },
        { border: "#e9d5ff", bg: "#faf5ff", text: "#9333ea" },
        { border: "#fbcfe8", bg: "#fdf2f8", text: "#db2777" },
        { border: "#a7f3d0", bg: "#ecfdf5", text: "#059669" },
        { border: "#fde68a", bg: "#fffbeb", text: "#d97706" },
        { border: "#a5f3fc", bg: "#ecfeff", text: "#0891b2" },
        { border: "#c7d2fe", bg: "#eef2ff", text: "#4f46e5" },
    ],

    topArticle: {
        enabled: true,
        title: "${icon}精选文章",
        emptyLabel: "暂无精选文章",
        limit: 5,
        autoPage: false,
        pageSpeed: 4000,
        dateFormat: "yyyy-MM-dd hh:mm:ss",
    },

    category: {
        enabled: true,
        path: "/categories",
        pageTitle: "${icon}全部分类",
        homeTitle: "${icon}文章分类",
        moreLabel: "更多 ...",
        emptyLabel: "暂无文章分类",
        limit: 5,
        autoPage: false,
        pageSpeed: 4000,
    },

    tag: {
        enabled: true,
        path: "/tags",
        pageTitle: "${icon}全部标签",
        homeTitle: "${icon}热门标签",
        moreLabel: "更多 ...",
        emptyLabel: "暂无标签",
        limit: 21,
        autoPage: false,
        pageSpeed: 4000,
    },

    friendLink: {
        enabled: false,
    },

    docAnalysis: {
        enabled: true,
        createTime: "2025-05-14",
        wordCount: true,
        readingTime: true,
        statistics: {
            provider: "busuanzi",
            siteView: true,
            pageView: true,
            tryRequest: false,
            tryCount: 5,
            tryIterationTime: 2000,
            permalink: true,
        },
        overrideInfo: [
            {
                key: "lastActiveTime",
                label: "活跃时间",
                value: (_, currentValue) => (currentValue + "").replace("前", ""),
                show: true,
            },
        ],
        appendInfo: [{ key: "index", label: "站点作者", value: "SakuraCake" }],
    },

    social: [
        {
            icon: "mdi:github",
            name: "GitHub",
            link: "https://github.com/CyaniAgent/piliotto",
        },
    ],

    footerGroup: [],

    footerInfo: {
        topMessage: [],
        bottomMessage: [],
        theme: {
            show: false,
            name: "",
            link: "",
        },
        copyright: {
            show: false,
            createYear: 2025,
            suffix: "PiliOtto",
        },
    },

    articleBanner: {
        enabled: true,
        showCategory: true,
        showTag: true,
        defaultCoverImg: "",
        defaultCoverBgColor: "",
    },

    articleAnalyze: {
        showIcon: true,
        dateFormat: "yyyy-MM-dd hh:mm:ss",
        showInfo: true,
        showAuthor: true,
        showCreateDate: true,
        showUpdateDate: false,
        showCategory: false,
        showTag: false,
    },

    breadcrumb: {
        enabled: true,
        showCurrentName: false,
        separator: "/",
        homeLabel: "首页",
    },

    pageStyle: "default",

    articleShare: {
        enabled: true,
        text: "分享此页面",
        copiedText: "链接已复制",
        query: false,
        hash: false,
    },

    articleTopTip: (frontmatter, _localeIndex, _page) => {
        const tip: Record<string, string> = {
            type: "warning",
            text: "文章发布较早，内容可能过时，阅读注意甄别。",
        };

        const longTime = 6 * 30 * 24 * 60 * 60 * 1000;
        if (frontmatter.date && Date.now() - new Date(frontmatter.date).getTime() > longTime) return tip;
    },

    articleBottomTip: frontmatter => {
        if (typeof window === "undefined") return;

        const hash = false;
        const query = false;
        const { origin, pathname, search } = window.location;
        const url = `${origin}${frontmatter.permalink ?? pathname}${query ? search : ""}${hash ? location.hash : ""}`;
        const author = "SakuraCake";

        return {
            type: "tip",
            text: `<p>作者：${author}</p>
             <p style="margin-bottom: 0">链接：<a href="${decodeURIComponent(url)}" target="_blank">${decodeURIComponent(url)}</a></p>
             <p>版权：此文章版权归 ${author} 所有，如有转载，请注明出处!</p>
            `,
        };
    },

    articleUpdate: {
        enabled: true,
        limit: 3,
    },

    comment: {
        provider: "giscus",
        options: {
            repo: "CyaniAgent/piliotto",
            repoId: "R_kgDOReW74A",
            category: "Announcements",
            categoryId: "DIC_kwDOReW74M4C9Dl3",
        },
    },

    vitePlugins: {
        sidebar: true,
        sidebarOption: {},
        permalink: false,
        permalinkOption: {},
        mdH1: true,
        catalogueOption: {},
        docAnalysis: true,
        docAnalysisOption: {},
        fileContentLoaderIgnore: ['**/guide/**'],
        autoFrontmatter: true,
        autoFrontmatterOption: {
            permalink: false,
            recoverTransform: false,
            categories: true,
            coverImg: false,
            forceCoverImg: false,
            coverImgList: [],
            permalinkRules: [],
        },
    },
});