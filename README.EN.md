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
pnpm i umi-plugin-tabs-keep-alive@latest
# Using npm
npm install umi-plugin-tabs-keep-alive@latest --save-dev
# Using yarn
yarn add umi-plugin-tabs-keep-alive@latest --dev
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

Replace the tab corresponding to a specified route and remove the original tab.  
The replacement is performed based on the exact path.  
Supports replacing without navigating to the new tab.

```tsx
import { replaceTab } from '@umijs/max';

// Replace the current tab with /new/path and remove the tab corresponding to /old/path
replaceTab('/old/path', '/new/path'); 

// Replace a tab without activating (navigating to) it
replaceTab('/test/path/123', '/new/path', true); 

// Replace the current tab with /path
replaceTab('/path'); 

// Replace a tab without activating (navigating to) it
replaceTab('/test/path/123', undefined, true);
````

### 2.`replaceTabByRouter`

Replace the tab corresponding to a specified route and remove the original tab.  
The replacement is based on the defined routing rules.  
Supports not navigating to the newly added tab.

```tsx
import { replaceTabByRouter } from '@umijs/max';

replaceTabByRouter('/test/path/123', '/test/path:id'); 
// Replace the tab matched by /test/path:id with /test/path/123
// and remove the original /test/path:id tab
// If you just want to add a tab without activating (navigating to) it, you can use this API
replaceTabByRouter('/test/path/123', '/test/path:id', true); 

replaceTabByRouter('/path'); 
// If the router parameter is not provided, /path will be opened directly
// If you just want to add a tab without activating (navigating to) it, you can use this API
replaceTabByRouter('/path', undefined, true);
```

### 3.`swapTab`

Swaps the positions of two tabs specified by their routes.  
This API is particularly useful when implementing tab drag-and-drop functionality, allowing you to easily update tab order.

```tsx
import { swapTab } from '@umijs/max';

swapTab('/test/path1', '/test/path2'); 
// Swaps the positions of the tabs for /test/path1 and /test/path2
// Common use case: update tab order after drag-and-drop interaction
```

### 4.`moveBeforeTab`

Moves the tab corresponding to the specified route **before** the tab of the target route.  
This API is useful for adjusting tab order after drag-and-drop operations.

```tsx
import { moveBeforeTab } from '@umijs/max';

moveBeforeTab('/test/path1', '/test/path2'); 
// Moves the tab for /test/path1 before the tab for /test/path2
// Common use case: update tab order after a drag-and-drop interaction
````


### 5.`moveAfterTab`

Moves the tab corresponding to the specified route **after** the tab of the target route.
This API is useful for adjusting tab order after drag-and-drop operations.

```tsx
import { moveAfterTab } from '@umijs/max';

moveAfterTab('/test/path1', '/test/path2'); 
// Moves the tab for /test/path1 after the tab for /test/path2
// Common use case: update tab order after a drag-and-drop interaction
```


### 6.`moveTab`

Moves the tab corresponding to the specified route **before or after** the tab of the target route (automatically determined).
If the source tab is currently positioned after the target, it will be moved before it.
If the source tab is currently positioned before the target, it will be moved after it.

```tsx
import { moveTab } from '@umijs/max';

moveTab('/test/path1', '/test/path2'); 
// If /test/path1 is currently after /test/path2, it will be moved before it
// If /test/path1 is currently before /test/path2, it will be moved after it
// Common use case: update tab order after a drag-and-drop interaction
```

### 7.`getTabList`

Get the list of all currently existing tab paths.

```tsx
import { getTabList } from '@umijs/max';

const tabs = getTabList();
console.log(tabs);
// Outputs the paths of all currently existing tabs
```
