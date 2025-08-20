import { IApi } from 'umi';
import { Mustache } from '@umijs/utils';

import { readFileSync } from 'fs';
import { join } from 'path';
import { checkAntdVersion } from './utils/checkAntd';

const DIR_NAME = 'plugin-keepaliveEx';
// keepaliveEx:['route path','route path']
// import { KeepAliveContext } from '@@/plugin-keepaliveEx/context';
// const { dropByCacheKey } = React.useContext<any>(KeepAliveContext);
// dropByCacheKey('/list');
type KeepAliveType = (string | RegExp)[];
export default (api: IApi) => {
  api.logger.info('Use umi plugin [umi-plugin-tabs-keep-alive] -> KeepAliveEx');
  // 和 tabsLayoutEx 插件组合使用
  const { tabsLayoutEx } = api.userConfig;

  api.describe({
    key: 'keepaliveEx',
    config: {
      schema(Joi) {
        return Joi.array().items(Joi.alternatives(Joi.string(), Joi.any()));
      },
    },
    enableBy: api.EnableBy.config,
  });
  api.addRuntimePluginKey(() => 'getKeepAlive');

  // only dev or build running
  if (!['dev', 'build', 'dev-config', 'preview', 'setup', 'setup'].includes(api.name)) return;

  const configStringify = (config: (string | RegExp)[]) => {
    return config.map((item) => {
      if (item instanceof RegExp) {
        return item;
      }
      return `'${item}'`;
    });
  };
  api.onGenerateFiles(() => {
    const contextTpl = readFileSync(join(__dirname, '.', 'templates', 'context.tpl'), 'utf-8');
    const hasInitialStatePlugin = api.config.initialState;

    api.writeTmpFile({
      path: `${DIR_NAME}/context.tsx`,
      noPluginDir: true,
      content: Mustache.render(contextTpl, {
        hasTabsLayout: !!tabsLayoutEx,
        hasCustomTabs: !!tabsLayoutEx?.hasCustomTabs,
        hasDropdown: !!tabsLayoutEx?.hasDropdown,
        hasFixedHeader: !!tabsLayoutEx?.hasFixedHeader,
        isPluginModelEnable: hasInitialStatePlugin,
        hasIntl: !!api.config.locale,
        isNewTabsAPISupported: checkAntdVersion(api, '4.22.8', '4.23.0'),
        isNewDropdownAPISupported: checkAntdVersion(api, '4.23.6', '4.24.0'),
      }),
    });
    const runtimeTpl = readFileSync(join(__dirname, '.', 'templates', 'runtime.tpl'), 'utf-8');
    api.writeTmpFile({
      path: `${DIR_NAME}/runtime.tsx`,
      noPluginDir: true,
      content: Mustache.render(runtimeTpl, {
        hasTabsLayout: !!tabsLayoutEx,
        keepaliveEx: configStringify((api.userConfig.keepaliveEx as KeepAliveType) || []),
        hasGetKeepalive: api.appData.appJS?.exports.includes('getKeepAlive'),
      }),
    });
    api.writeTmpFile({
      path: `${DIR_NAME}/support.tsx`,
      noPluginDir: true,
      content: `
import { keepaliveEmitter } from './context';

export function dropByCacheKey(path: string) {
  keepaliveEmitter.emit({type:'dropByCacheKey', payload: {
    path
  }});
}
export function closeTab(path: string) {
  keepaliveEmitter.emit({type:'closeTab', payload: {
    path
  }});
}
export function closeAllTabs() {
  keepaliveEmitter.emit({type:'closeAllTabs'});
}
/**
 * NOTE 新增一个替换路径的方法， 将指定路径替换成新路径，且保持原 tab 位置
 * @param path1 路径 1，可跳转的路径，必填
 * @param path2 路径 2，可选。
 *     - 如果不传，则对当前 tab 的路径进行替换，替换为 path 1
 *     - 如果传入，则将 path 1 tab 替换为 path 2，且保持原 tab 的位置
 */
export function replaceTab(path1: string, path2?: string) {
  keepaliveEmitter.emit({
    type: 'replaceTab',
    payload: { path1, path2 }
  });
}
/**
 * NOTE 根据路由的路径选择器去匹配替换的路径
 * @param path
 * @param myRouter
 */
export function replaceTabByRouter(path: string, myRouter: string) {
  keepaliveEmitter.emit({
    type: 'replaceTabByRouter',
    payload: { path, myRouter }
  });
}
/**
 * NOTE 将两个指定路径的 tab 互换位置
 * @param path1 的 Tab 路径
 * @param path2 的 Tab 路径
 */
export function swapTab(path1: string, path2: string) {
  keepaliveEmitter.emit({
    type: 'swapTab',
    payload: { path1, path2 }
  });
}
/**
 * NOTE 将指定路径的 tab 移动到目标路径前面或者后面（自动检测，待移动的 tab 位置大于目标位置时，说明往前移动，反之是往后移动）
 * @param sourcePath 待移动的 tab 路径
 * @param targetPath 目标 tab 路径
 */
export function moveTab(sourcePath: string, targetPath: string) {
  keepaliveEmitter.emit({
    type: 'moveTab',
    payload: { sourcePath, targetPath }
  });
}
/**
 * NOTE 将指定路径的 tab 移动到目标路径之前
 * @param sourcePath 待移动的 tab 路径
 * @param targetPath 目标 tab 路径
 */
export function moveBeforeTab(sourcePath: string, targetPath: string) {
  keepaliveEmitter.emit({
    type: 'moveBeforeTab',
    payload: { sourcePath, targetPath }
  });
}
/**
 * NOTE 将指定路径的 tab 移动到目标路径之后
 * @param sourcePath 待移动的 tab 路径
 * @param targetPath 目标 tab 路径
 */
export function moveAfterTab(sourcePath: string, targetPath: string) {
  keepaliveEmitter.emit({
    type: 'moveAfterTab',
    payload: { sourcePath, targetPath }
  });
}
`,
    });
    // index.ts for export
    api.writeTmpFile({
      noPluginDir: true,
      path: `${DIR_NAME}/index.tsx`,
      content: `
export { KeepAliveContext,useKeepOutlets, MaxTabsLayout } from './context';
export { dropByCacheKey, closeTab, closeAllTabs, replaceTab, replaceTabByRouter, swapTab, moveTab, moveBeforeTab, moveAfterTab } from './support';
`,
    });
  });

  api.addRuntimePlugin(() => [join(api.paths.absTmpPath!, `${DIR_NAME}/runtime.tsx`)]);
};
