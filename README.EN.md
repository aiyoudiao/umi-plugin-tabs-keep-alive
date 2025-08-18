# umi-plugin-tabs-keep-alive

English | [简体中文](./README.md)


The built-in `keepalive` and `tabsLayout` in Umi Max are not very user-friendly.  
They occasionally throw errors in the console, have some silly bugs, and are experimental features.  
The source code is also heavy and complex.  

This plugin extracts the core logic of these features, simplifies and optimizes them, and will continue to improve usability over time.

## ✨ Features

- 📦 Fully integrated with Umi Max
- ⚡ Lightweight and fast
- 🔧 Supports custom configuration

## 📥 Installation

Install via your preferred package manager:

```bash
# Using pnpm
pnpm i umi-plugin-tabs-keep-alive
# Using npm
npm install umi-plugin-tabs-keep-alive --save-dev
# Using yarn
yarn add umi-plugin-tabs-keep-alive --dev
````

## 🔨 Usage

Add the plugin in your `.umirc.ts` or `config/config.ts`:

```ts
export default {
  plugins: [
    'umi-plugin-tabs-keep-alive', // Add plugin here
  ],
  keepaliveEx: {}, // Plugin configuration
  tabsLayoutEx: {
    // Use a custom tabs component (requires getCustomTabs in runtime config)
    hasCustomTabs: true,
    // Enable right-side tabs manager: close left, close right, close others, refresh, etc.
    hasDropdown: true,
    hasFixedHeader: false,
  }
};
```

In your `app.ts`, add your custom TabsLayout:

```ts
/**
 * @description: Completely overrides the built-in multi-Tabs component. Requires hasCustomTabs: true
 * @doc https://alitajs.com/en-US/docs/guides/tabs#getcustomtabs
 */
export const getCustomTabs = () => (props: TabsLayoutProps) => <TabsLayout {...props} />
```

In your layout component or container component, use the MaxTabsLayout component — you no longer need to write children.

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


## 📬 Feedback & Support

* Found a bug? Open an issue on [GitHub](https://github.com/aiyoudiao/umi-plugin-tabs-keep-alive/issues)
* Questions? Contact us or ask in the Umi community
* Like this plugin? Give it a ⭐️ on [GitHub](https://github.com/aiyoudiao/umi-plugin-tabs-keep-alive)

---

🌟 Thanks for using `umi-plugin-tabs-keep-alive`! Enjoy coding! 🎉

Thanks also to the original open-source project for the Umi built-in plugin: [@alita/plugins](https://github.com/alitajs/alita/tree/master/packages/plugins)

好的，我帮你润色成更正式、更符合技术文档风格的英文版本：


## New Features

### 1.`replaceTab`
Replaces the tab corresponding to a specified route and removes the original tab.  
The replacement is performed using the exact path.

```tsx
replaceTab('/old/path', '/new/path'); 
// Replaces the current tab with /new/path and removes the tab for /old/path

replaceTab('/path'); 
// Replaces the current tab with /path
````

### 2.`replaceTabByRouter`

Replaces the tab corresponding to a specified route and removes the original tab.
The replacement is performed using the defined router.

```tsx
replaceTabByRouter('/test/path/123', '/test/path:id'); 
// Replaces the tab matched by /test/path:id with /test/path/123 
// and removes the original /test/path:id tab

replaceTabByRouter('/path'); 
// If no router is provided, the route /path is opened directly
```
