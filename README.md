# umi-plugin-tabs-keep-alive

[English](./README.EN.md) | 简体中文


umi max 中自带的 keepalive 和 tabsLayout 不好用，时不时在控制台报错并出现低级错误，很烦很抓马，源码很重也很复杂，而且该功能还是试验性的。  
所以从源码提取出该部分的核心功能代码，并对其进行精简和优化，之后会在使用过程中逐渐人性化。

## ✨ 特性

- 📦 与 Umi Max 深度集成
- ⚡ 轻量且快速
- 🔧 支持自定义配置

## 📥 安装

使用你喜欢的包管理器安装插件：

```bash
# 使用 pnpm
pnpm i umi-plugin-tabs-keep-alive@latest
# 或使用 npm
npm install umi-plugin-tabs-keep-alive@latest --save-dev
# 或使用 yarn
yarn add umi-plugin-tabs-keep-alive@latest --dev
````

## 🔨 使用

在你的 Umi 项目中使用该插件，配置 `.umirc.ts` 或 `config/config.ts` 文件：

```ts
export default {
  plugins: [
    'umi-plugin-tabs-keep-alive', // 在此添加插件
  ],
  keepaliveEx: {}, // 使用插件的配置选项
  tabsLayoutEx: {
    // 是否使用自定义的 tabs 组件，需要搭配运行时配置 getCustomTabs 使用
    hasCustomTabs: true,
    // 是否开启右侧的 tabs 管理器，可以实现“关闭左侧”，“关闭右侧”，“关闭其他”和“刷新”等功能。
    hasDropdown: true,
    hasFixedHeader: false,
  }
};
```

在 `app.ts` 中添加自定义 TabsLayout，也就是自定义的 tabs 组件：

```ts
/**
 * @description: 完全覆盖内置的多 Tabs 组件，需要搭配配置 hasCustomTabs:true 使用
 * @doc https://alitajs.com/zh-CN/docs/guides/tabs#getcustomtabs
 */
export const getCustomTabs = () => (props: TabsLayoutProps) => <TabsLayout {...props} />
```

在 你的 layout 组件 或 容器组件中使用 `MaxTabsLayout` 组件，不用再写 children 了。

```tsx
import { MaxTabsLayout } from '@umijs/max';

export const BasicLayout: RunTimeLayoutConfig = ({ initialState }: InitDataType) => {
  return {
    // ...
    childrenRender: () => <MaxTabsLayout />,
    // ...
  }
}
```

## 📬 反馈与支持

* 发现了 bug？请在 [GitHub Issues](https://github.com/aiyoudiao/umi-plugin-tabs-keep-alive/issues) 提交
* 有问题？可随时联系我们或在 Umi 社区提问
* 喜欢这个插件？请在 [GitHub](https://github.com/aiyoudiao/umi-plugin-tabs-keep-alive) 给它 ⭐️

---

🌟 感谢使用 `umi-plugin-tabs-keep-alive`！祝您使用愉快！🎉

感谢原 umi 内置插件的开源项目：[@alita/plugins](https://github.com/alitajs/alita/tree/master/packages/plugins)


## 新增功能

### 1.`replaceTab`
替换指定路由对应的标签页，并移除原有的标签页。  
替换操作基于精确路径进行。

```tsx
import { replaceTab } from '@umijs/max';

replaceTab('/old/path', '/new/path'); 
// 将当前标签页替换为 /new/path，并移除 /old/path 对应的标签页

replaceTab('/path'); 
// 将当前标签页替换为 /path
````

### 2.`replaceTabByRouter`

替换指定路由对应的标签页，并移除原有的标签页。
替换操作基于定义的路由规则进行。

```tsx
import { replaceTabByRouter } from '@umijs/max';

replaceTabByRouter('/test/path/123', '/test/path:id'); 
// 将 /test/path:id 匹配到的标签页替换为 /test/path/123
// 并移除原有的 /test/path:id 标签页

replaceTabByRouter('/path'); 
// 如果未传递 router 参数，则直接打开 /path
```

