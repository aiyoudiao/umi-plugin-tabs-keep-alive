import { IApi } from 'umi';

export default (api: IApi) => {
  // 如果有插件自己的逻辑
  api.logger.info('keepaliveEx plugin loaded');

  // 挂载 tabsLayout 插件
  api.registerPlugins([
    require.resolve('./tabsLayoutEx'),
    require.resolve('./keepaliveEx'),
  ]);
};
