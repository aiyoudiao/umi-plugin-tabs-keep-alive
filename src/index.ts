import { IApi } from 'umi';

export default (api: IApi) => {
  // 如果有插件自己的逻辑
  api.logger.info('[umi-plugin-tabs-keep-alive] plugin loaded');

  // 挂载 tabsLayout 插件
  api.registerPlugins([
    require.resolve('./tabsLayoutEx'),
    require.resolve('./keepaliveEx'),
  ]);
};
