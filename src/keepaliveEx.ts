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
  if (
    !['dev', 'build', 'dev-config', 'preview', 'setup', 'setup'].includes(
      api.name,
    )
  )
    return;

  const configStringify = (config: (string | RegExp)[]) => {
    return config.map((item) => {
      if (item instanceof RegExp) {
        return item;
      }
      return `'${item}'`;
    });
  };
  api.onGenerateFiles(() => {
    const contextTpl = readFileSync(
      join(__dirname, '.', 'templates', 'context.tpl'),
      'utf-8',
    );
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
    const runtimeTpl = readFileSync(
      join(__dirname, '.', 'templates', 'runtime.tpl'),
      'utf-8',
    );
    api.writeTmpFile({
      path: `${DIR_NAME}/runtime.tsx`,
      noPluginDir: true,
      content: Mustache.render(runtimeTpl, {
        hasTabsLayout: !!tabsLayoutEx,
        keepaliveEx: configStringify(
          (api.userConfig.keepaliveEx as KeepAliveType) || [],
        ),
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
export function replaceTab(path1: string, path2?: string) {
  keepaliveEmitter.emit({
    type: 'replaceTab',
    payload: { path1, path2 }
  });
}
export function replaceTabByRouter(path: string, myRouter: string) {
  keepaliveEmitter.emit({
    type: 'replaceTabByRouter',
    payload: { path, myRouter }
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
export { dropByCacheKey, closeTab, closeAllTabs, replaceTab, replaceTabByRouter } from './support';
`,
    });
  });

  api.addRuntimePlugin(() => [
    join(api.paths.absTmpPath!, `${DIR_NAME}/runtime.tsx`),
  ]);
};
