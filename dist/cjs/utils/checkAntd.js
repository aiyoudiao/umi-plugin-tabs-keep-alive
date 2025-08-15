var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
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
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/utils/checkAntd.ts
var checkAntd_exports = {};
__export(checkAntd_exports, {
  checkAntdVersion: () => checkAntdVersion
});
module.exports = __toCommonJS(checkAntd_exports);
var import_semver = __toESM(require("semver"));
var import_resolveProjectDep = require("./resolveProjectDep");
var checkAntdVersion = (api, unsupportVersion, minVersion) => {
  if (
    // @ts-ignore
    api.pkg.dependencies && api.pkg.dependencies["antd"] || // @ts-ignore
    api.pkg.devDependencies && api.pkg.devDependencies["antd"] || // egg project using `clientDependencies` in ali tnpm
    // @ts-ignore
    api.pkg.clientDependencies && api.pkg.clientDependencies["antd"]
  ) {
    let version = minVersion;
    try {
      const nodeModulesPath = (0, import_resolveProjectDep.resolveProjectDep)({
        pkg: api.pkg,
        cwd: api.cwd,
        dep: "antd"
      }) || `${api.cwd}/node_modules/antd`;
      version = require(`${nodeModulesPath}/package.json`).version;
    } catch (error) {
    }
    return import_semver.default.lt(unsupportVersion, version);
  }
  return true;
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  checkAntdVersion
});
