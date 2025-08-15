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

// src/tabsLayoutEx.ts
var tabsLayoutEx_exports = {};
__export(tabsLayoutEx_exports, {
  default: () => tabsLayoutEx_default
});
module.exports = __toCommonJS(tabsLayoutEx_exports);
var import_utils = require("@umijs/utils");
var tabsLayoutEx_default = (api) => {
  api.logger.info(
    "Use umi plugin [umi-plugin-tabs-keep-alive] -> tabsLayoutEx"
  );
  api.describe({
    key: "tabsLayoutEx",
    config: {
      schema(Joi) {
        return Joi.alternatives(
          Joi.boolean(),
          Joi.object({
            hasCustomTabs: Joi.boolean(),
            hasDropdown: Joi.boolean(),
            hasFixedHeader: Joi.boolean()
          })
        );
      },
      onChange: api.ConfigChangeType.regenerateTmpFiles
    },
    enableBy: api.EnableBy.config
  });
  api.addRuntimePluginKey(() => ["tabsLayoutEx", "getCustomTabs"]);
  if (!["dev", "build", "dev-config", "preview", "setup"].includes(api.name))
    return;
  api.onStart(() => {
    import_utils.logger.info("Using TabsLayout Plugin");
  });
};
