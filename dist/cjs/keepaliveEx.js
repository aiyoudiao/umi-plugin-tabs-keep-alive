var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/keepaliveEx.ts
var keepaliveEx_exports = {};
__export(keepaliveEx_exports, {
  default: () => keepaliveEx_default
});
module.exports = __toCommonJS(keepaliveEx_exports);
var import_utils = require("@umijs/utils");
var import_fs = require("fs");
var import_path = require("path");
var import_checkAntd = require("./utils/checkAntd");
var DIR_NAME = "plugin-keepaliveEx";
var keepaliveEx_default = (api) => {
  api.logger.info("Use umi plugin [umi-plugin-tabs-keep-alive] -> KeepAliveEx");
  const { tabsLayoutEx } = api.userConfig;
  api.describe({
    key: "keepaliveEx",
    config: {
      schema(Joi) {
        return Joi.array().items(Joi.alternatives(Joi.string(), Joi.any()));
      }
    },
    enableBy: api.EnableBy.config
  });
  api.addRuntimePluginKey(() => "getKeepAlive");
  if (!["dev", "build", "dev-config", "preview", "setup", "setup"].includes(
    api.name
  ))
    return;
  const configStringify = (config) => {
    return config.map((item) => {
      if (item instanceof RegExp) {
        return item;
      }
      return `'${item}'`;
    });
  };
  api.onGenerateFiles(() => {
    var _a;
    const contextTpl = (0, import_fs.readFileSync)(
      (0, import_path.join)(__dirname, ".", "templates", "context.tpl"),
      "utf-8"
    );
    const hasInitialStatePlugin = api.config.initialState;
    api.writeTmpFile({
      path: `${DIR_NAME}/context.tsx`,
      noPluginDir: true,
      content: import_utils.Mustache.render(contextTpl, {
        hasTabsLayout: !!tabsLayoutEx,
        hasCustomTabs: !!(tabsLayoutEx == null ? void 0 : tabsLayoutEx.hasCustomTabs),
        hasDropdown: !!(tabsLayoutEx == null ? void 0 : tabsLayoutEx.hasDropdown),
        hasFixedHeader: !!(tabsLayoutEx == null ? void 0 : tabsLayoutEx.hasFixedHeader),
        isPluginModelEnable: hasInitialStatePlugin,
        hasIntl: !!api.config.locale,
        isNewTabsAPISupported: (0, import_checkAntd.checkAntdVersion)(api, "4.22.8", "4.23.0"),
        isNewDropdownAPISupported: (0, import_checkAntd.checkAntdVersion)(api, "4.23.6", "4.24.0")
      })
    });
    const runtimeTpl = (0, import_fs.readFileSync)(
      (0, import_path.join)(__dirname, ".", "templates", "runtime.tpl"),
      "utf-8"
    );
    api.writeTmpFile({
      path: `${DIR_NAME}/runtime.tsx`,
      noPluginDir: true,
      content: import_utils.Mustache.render(runtimeTpl, {
        hasTabsLayout: !!tabsLayoutEx,
        keepaliveEx: configStringify(
          api.userConfig.keepaliveEx || []
        ),
        hasGetKeepalive: (_a = api.appData.appJS) == null ? void 0 : _a.exports.includes("getKeepAlive")
      })
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
export function replaceTab(path: string) {
  keepaliveEmitter.emit({
    type: 'replaceTab',
    payload: { path }
  });
}
`
    });
    api.writeTmpFile({
      noPluginDir: true,
      path: `${DIR_NAME}/index.tsx`,
      content: `
export { KeepAliveContext,useKeepOutlets, MaxTabsLayout } from './context';
export { dropByCacheKey, closeTab, closeAllTabs, replaceTab } from './support';
`
    });
  });
  api.addRuntimePlugin(() => [
    (0, import_path.join)(api.paths.absTmpPath, `${DIR_NAME}/runtime.tsx`)
  ]);
};
