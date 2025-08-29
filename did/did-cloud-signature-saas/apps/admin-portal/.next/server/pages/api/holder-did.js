"use strict";
/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
(() => {
var exports = {};
exports.id = "pages/api/holder-did";
exports.ids = ["pages/api/holder-did"];
exports.modules = {

/***/ "@stablelib/ed25519":
/*!*************************************!*\
  !*** external "@stablelib/ed25519" ***!
  \*************************************/
/***/ ((module) => {

module.exports = require("@stablelib/ed25519");

/***/ }),

/***/ "@veramo/core":
/*!*******************************!*\
  !*** external "@veramo/core" ***!
  \*******************************/
/***/ ((module) => {

module.exports = require("@veramo/core");

/***/ }),

/***/ "@veramo/credential-w3c":
/*!*****************************************!*\
  !*** external "@veramo/credential-w3c" ***!
  \*****************************************/
/***/ ((module) => {

module.exports = require("@veramo/credential-w3c");

/***/ }),

/***/ "@veramo/did-manager":
/*!**************************************!*\
  !*** external "@veramo/did-manager" ***!
  \**************************************/
/***/ ((module) => {

module.exports = require("@veramo/did-manager");

/***/ }),

/***/ "@veramo/did-provider-key":
/*!*******************************************!*\
  !*** external "@veramo/did-provider-key" ***!
  \*******************************************/
/***/ ((module) => {

module.exports = require("@veramo/did-provider-key");

/***/ }),

/***/ "@veramo/did-provider-web":
/*!*******************************************!*\
  !*** external "@veramo/did-provider-web" ***!
  \*******************************************/
/***/ ((module) => {

module.exports = require("@veramo/did-provider-web");

/***/ }),

/***/ "@veramo/did-resolver":
/*!***************************************!*\
  !*** external "@veramo/did-resolver" ***!
  \***************************************/
/***/ ((module) => {

module.exports = require("@veramo/did-resolver");

/***/ }),

/***/ "@veramo/key-manager":
/*!**************************************!*\
  !*** external "@veramo/key-manager" ***!
  \**************************************/
/***/ ((module) => {

module.exports = require("@veramo/key-manager");

/***/ }),

/***/ "@veramo/kms-local":
/*!************************************!*\
  !*** external "@veramo/kms-local" ***!
  \************************************/
/***/ ((module) => {

module.exports = require("@veramo/kms-local");

/***/ }),

/***/ "next/dist/compiled/next-server/pages-api.runtime.dev.js":
/*!**************************************************************************!*\
  !*** external "next/dist/compiled/next-server/pages-api.runtime.dev.js" ***!
  \**************************************************************************/
/***/ ((module) => {

module.exports = require("next/dist/compiled/next-server/pages-api.runtime.dev.js");

/***/ }),

/***/ "varint":
/*!*************************!*\
  !*** external "varint" ***!
  \*************************/
/***/ ((module) => {

module.exports = require("varint");

/***/ }),

/***/ "crypto":
/*!*************************!*\
  !*** external "crypto" ***!
  \*************************/
/***/ ((module) => {

module.exports = require("crypto");

/***/ }),

/***/ "did-resolver":
/*!*******************************!*\
  !*** external "did-resolver" ***!
  \*******************************/
/***/ ((module) => {

module.exports = import("did-resolver");;

/***/ }),

/***/ "nist-weierstrauss":
/*!************************************!*\
  !*** external "nist-weierstrauss" ***!
  \************************************/
/***/ ((module) => {

module.exports = import("nist-weierstrauss");;

/***/ }),

/***/ "web-did-resolver":
/*!***********************************!*\
  !*** external "web-did-resolver" ***!
  \***********************************/
/***/ ((module) => {

module.exports = import("web-did-resolver");;

/***/ }),

/***/ "(api)/../../node_modules/next/dist/build/webpack/loaders/next-route-loader/index.js?kind=PAGES_API&page=%2Fapi%2Fholder-did&preferredRegion=&absolutePagePath=.%2Fpages%2Fapi%2Fholder-did.ts&middlewareConfigBase64=e30%3D!":
/*!******************************************************************************************************************************************************************************************************************************!*\
  !*** ../../node_modules/next/dist/build/webpack/loaders/next-route-loader/index.js?kind=PAGES_API&page=%2Fapi%2Fholder-did&preferredRegion=&absolutePagePath=.%2Fpages%2Fapi%2Fholder-did.ts&middlewareConfigBase64=e30%3D! ***!
  \******************************************************************************************************************************************************************************************************************************/
/***/ ((module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.a(module, async (__webpack_handle_async_dependencies__, __webpack_async_result__) => { try {\n__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   config: () => (/* binding */ config),\n/* harmony export */   \"default\": () => (__WEBPACK_DEFAULT_EXPORT__),\n/* harmony export */   routeModule: () => (/* binding */ routeModule)\n/* harmony export */ });\n/* harmony import */ var next_dist_server_future_route_modules_pages_api_module_compiled__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! next/dist/server/future/route-modules/pages-api/module.compiled */ \"(api)/../../node_modules/next/dist/server/future/route-modules/pages-api/module.compiled.js\");\n/* harmony import */ var next_dist_server_future_route_modules_pages_api_module_compiled__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(next_dist_server_future_route_modules_pages_api_module_compiled__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var next_dist_server_future_route_kind__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! next/dist/server/future/route-kind */ \"(api)/../../node_modules/next/dist/server/future/route-kind.js\");\n/* harmony import */ var next_dist_build_templates_helpers__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! next/dist/build/templates/helpers */ \"(api)/../../node_modules/next/dist/build/templates/helpers.js\");\n/* harmony import */ var _pages_api_holder_did_ts__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./pages/api/holder-did.ts */ \"(api)/./pages/api/holder-did.ts\");\nvar __webpack_async_dependencies__ = __webpack_handle_async_dependencies__([_pages_api_holder_did_ts__WEBPACK_IMPORTED_MODULE_3__]);\n_pages_api_holder_did_ts__WEBPACK_IMPORTED_MODULE_3__ = (__webpack_async_dependencies__.then ? (await __webpack_async_dependencies__)() : __webpack_async_dependencies__)[0];\n\n\n\n// Import the userland code.\n\n// Re-export the handler (should be the default export).\n/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = ((0,next_dist_build_templates_helpers__WEBPACK_IMPORTED_MODULE_2__.hoist)(_pages_api_holder_did_ts__WEBPACK_IMPORTED_MODULE_3__, \"default\"));\n// Re-export config.\nconst config = (0,next_dist_build_templates_helpers__WEBPACK_IMPORTED_MODULE_2__.hoist)(_pages_api_holder_did_ts__WEBPACK_IMPORTED_MODULE_3__, \"config\");\n// Create and export the route module that will be consumed.\nconst routeModule = new next_dist_server_future_route_modules_pages_api_module_compiled__WEBPACK_IMPORTED_MODULE_0__.PagesAPIRouteModule({\n    definition: {\n        kind: next_dist_server_future_route_kind__WEBPACK_IMPORTED_MODULE_1__.RouteKind.PAGES_API,\n        page: \"/api/holder-did\",\n        pathname: \"/api/holder-did\",\n        // The following aren't used in production.\n        bundlePath: \"\",\n        filename: \"\"\n    },\n    userland: _pages_api_holder_did_ts__WEBPACK_IMPORTED_MODULE_3__\n});\n\n//# sourceMappingURL=pages-api.js.map\n__webpack_async_result__();\n} catch(e) { __webpack_async_result__(e); } });//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi4vLi4vbm9kZV9tb2R1bGVzL25leHQvZGlzdC9idWlsZC93ZWJwYWNrL2xvYWRlcnMvbmV4dC1yb3V0ZS1sb2FkZXIvaW5kZXguanM/a2luZD1QQUdFU19BUEkmcGFnZT0lMkZhcGklMkZob2xkZXItZGlkJnByZWZlcnJlZFJlZ2lvbj0mYWJzb2x1dGVQYWdlUGF0aD0uJTJGcGFnZXMlMkZhcGklMkZob2xkZXItZGlkLnRzJm1pZGRsZXdhcmVDb25maWdCYXNlNjQ9ZTMwJTNEISIsIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7Ozs7OztBQUFzRztBQUN2QztBQUNMO0FBQzFEO0FBQ3NEO0FBQ3REO0FBQ0EsaUVBQWUsd0VBQUssQ0FBQyxxREFBUSxZQUFZLEVBQUM7QUFDMUM7QUFDTyxlQUFlLHdFQUFLLENBQUMscURBQVE7QUFDcEM7QUFDTyx3QkFBd0IsZ0hBQW1CO0FBQ2xEO0FBQ0EsY0FBYyx5RUFBUztBQUN2QjtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsS0FBSztBQUNMLFlBQVk7QUFDWixDQUFDOztBQUVELHFDIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vQHNhYXMvYWRtaW4tcG9ydGFsLz8wMDRjIl0sInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IFBhZ2VzQVBJUm91dGVNb2R1bGUgfSBmcm9tIFwibmV4dC9kaXN0L3NlcnZlci9mdXR1cmUvcm91dGUtbW9kdWxlcy9wYWdlcy1hcGkvbW9kdWxlLmNvbXBpbGVkXCI7XG5pbXBvcnQgeyBSb3V0ZUtpbmQgfSBmcm9tIFwibmV4dC9kaXN0L3NlcnZlci9mdXR1cmUvcm91dGUta2luZFwiO1xuaW1wb3J0IHsgaG9pc3QgfSBmcm9tIFwibmV4dC9kaXN0L2J1aWxkL3RlbXBsYXRlcy9oZWxwZXJzXCI7XG4vLyBJbXBvcnQgdGhlIHVzZXJsYW5kIGNvZGUuXG5pbXBvcnQgKiBhcyB1c2VybGFuZCBmcm9tIFwiLi9wYWdlcy9hcGkvaG9sZGVyLWRpZC50c1wiO1xuLy8gUmUtZXhwb3J0IHRoZSBoYW5kbGVyIChzaG91bGQgYmUgdGhlIGRlZmF1bHQgZXhwb3J0KS5cbmV4cG9ydCBkZWZhdWx0IGhvaXN0KHVzZXJsYW5kLCBcImRlZmF1bHRcIik7XG4vLyBSZS1leHBvcnQgY29uZmlnLlxuZXhwb3J0IGNvbnN0IGNvbmZpZyA9IGhvaXN0KHVzZXJsYW5kLCBcImNvbmZpZ1wiKTtcbi8vIENyZWF0ZSBhbmQgZXhwb3J0IHRoZSByb3V0ZSBtb2R1bGUgdGhhdCB3aWxsIGJlIGNvbnN1bWVkLlxuZXhwb3J0IGNvbnN0IHJvdXRlTW9kdWxlID0gbmV3IFBhZ2VzQVBJUm91dGVNb2R1bGUoe1xuICAgIGRlZmluaXRpb246IHtcbiAgICAgICAga2luZDogUm91dGVLaW5kLlBBR0VTX0FQSSxcbiAgICAgICAgcGFnZTogXCIvYXBpL2hvbGRlci1kaWRcIixcbiAgICAgICAgcGF0aG5hbWU6IFwiL2FwaS9ob2xkZXItZGlkXCIsXG4gICAgICAgIC8vIFRoZSBmb2xsb3dpbmcgYXJlbid0IHVzZWQgaW4gcHJvZHVjdGlvbi5cbiAgICAgICAgYnVuZGxlUGF0aDogXCJcIixcbiAgICAgICAgZmlsZW5hbWU6IFwiXCJcbiAgICB9LFxuICAgIHVzZXJsYW5kXG59KTtcblxuLy8jIHNvdXJjZU1hcHBpbmdVUkw9cGFnZXMtYXBpLmpzLm1hcCJdLCJuYW1lcyI6W10sInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///(api)/../../node_modules/next/dist/build/webpack/loaders/next-route-loader/index.js?kind=PAGES_API&page=%2Fapi%2Fholder-did&preferredRegion=&absolutePagePath=.%2Fpages%2Fapi%2Fholder-did.ts&middlewareConfigBase64=e30%3D!\n");

/***/ }),

/***/ "(api)/./pages/api/holder-did.ts":
/*!*********************************!*\
  !*** ./pages/api/holder-did.ts ***!
  \*********************************/
/***/ ((module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.a(module, async (__webpack_handle_async_dependencies__, __webpack_async_result__) => { try {\n__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (/* binding */ handler)\n/* harmony export */ });\n/* harmony import */ var _saas_agent__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @saas/agent */ \"(api)/../../packages/agent/dist/index.js\");\nvar __webpack_async_dependencies__ = __webpack_handle_async_dependencies__([_saas_agent__WEBPACK_IMPORTED_MODULE_0__]);\n_saas_agent__WEBPACK_IMPORTED_MODULE_0__ = (__webpack_async_dependencies__.then ? (await __webpack_async_dependencies__)() : __webpack_async_dependencies__)[0];\n // ⬅️ use ESM import\nasync function handler(_req, res) {\n    try {\n        const a = (0,_saas_agent__WEBPACK_IMPORTED_MODULE_0__.createDIDAgent)();\n        const id = await a.didManagerCreate({\n            provider: \"did:key\",\n            alias: \"holder-ui\"\n        });\n        res.json({\n            did: id.did\n        });\n    } catch (e) {\n        res.status(500).json({\n            error: String(e?.message || e)\n        });\n    }\n}\n\n__webpack_async_result__();\n} catch(e) { __webpack_async_result__(e); } });//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi9wYWdlcy9hcGkvaG9sZGVyLWRpZC50cyIsIm1hcHBpbmdzIjoiOzs7Ozs7OztBQUM2QyxDQUFDLG9CQUFvQjtBQUVuRCxlQUFlQyxRQUFRQyxJQUFvQixFQUFFQyxHQUFvQjtJQUM5RSxJQUFJO1FBQ0YsTUFBTUMsSUFBSUosMkRBQWNBO1FBQ3hCLE1BQU1LLEtBQUssTUFBTUQsRUFBRUUsZ0JBQWdCLENBQUM7WUFBRUMsVUFBVTtZQUFXQyxPQUFPO1FBQVk7UUFDOUVMLElBQUlNLElBQUksQ0FBQztZQUFFQyxLQUFLTCxHQUFHSyxHQUFHO1FBQUM7SUFDekIsRUFBRSxPQUFPQyxHQUFRO1FBQ2ZSLElBQUlTLE1BQU0sQ0FBQyxLQUFLSCxJQUFJLENBQUM7WUFBRUksT0FBT0MsT0FBT0gsR0FBR0ksV0FBV0o7UUFBRztJQUN4RDtBQUNGIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vQHNhYXMvYWRtaW4tcG9ydGFsLy4vcGFnZXMvYXBpL2hvbGRlci1kaWQudHM/ZjAwMiJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgdHlwZSB7IE5leHRBcGlSZXF1ZXN0LCBOZXh0QXBpUmVzcG9uc2UgfSBmcm9tICduZXh0JztcbmltcG9ydCB7IGNyZWF0ZURJREFnZW50IH0gZnJvbSAnQHNhYXMvYWdlbnQnOyAvLyDirIXvuI8gdXNlIEVTTSBpbXBvcnRcblxuZXhwb3J0IGRlZmF1bHQgYXN5bmMgZnVuY3Rpb24gaGFuZGxlcihfcmVxOiBOZXh0QXBpUmVxdWVzdCwgcmVzOiBOZXh0QXBpUmVzcG9uc2UpIHtcbiAgdHJ5IHtcbiAgICBjb25zdCBhID0gY3JlYXRlRElEQWdlbnQoKTtcbiAgICBjb25zdCBpZCA9IGF3YWl0IGEuZGlkTWFuYWdlckNyZWF0ZSh7IHByb3ZpZGVyOiAnZGlkOmtleScsIGFsaWFzOiAnaG9sZGVyLXVpJyB9KTtcbiAgICByZXMuanNvbih7IGRpZDogaWQuZGlkIH0pO1xuICB9IGNhdGNoIChlOiBhbnkpIHtcbiAgICByZXMuc3RhdHVzKDUwMCkuanNvbih7IGVycm9yOiBTdHJpbmcoZT8ubWVzc2FnZSB8fCBlKSB9KTtcbiAgfVxufVxuIl0sIm5hbWVzIjpbImNyZWF0ZURJREFnZW50IiwiaGFuZGxlciIsIl9yZXEiLCJyZXMiLCJhIiwiaWQiLCJkaWRNYW5hZ2VyQ3JlYXRlIiwicHJvdmlkZXIiLCJhbGlhcyIsImpzb24iLCJkaWQiLCJlIiwic3RhdHVzIiwiZXJyb3IiLCJTdHJpbmciLCJtZXNzYWdlIl0sInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///(api)/./pages/api/holder-did.ts\n");

/***/ }),

/***/ "(api)/../../packages/agent/dist/index.js":
/*!******************************************!*\
  !*** ../../packages/agent/dist/index.js ***!
  \******************************************/
/***/ ((__webpack_module__, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.a(__webpack_module__, async (__webpack_handle_async_dependencies__, __webpack_async_result__) => { try {\n__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   createDIDAgent: () => (/* binding */ createDIDAgent)\n/* harmony export */ });\n/* harmony import */ var _veramo_core__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @veramo/core */ \"@veramo/core\");\n/* harmony import */ var _veramo_credential_w3c__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @veramo/credential-w3c */ \"@veramo/credential-w3c\");\n/* harmony import */ var _veramo_did_manager__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @veramo/did-manager */ \"@veramo/did-manager\");\n/* harmony import */ var _veramo_did_provider_web__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @veramo/did-provider-web */ \"@veramo/did-provider-web\");\n/* harmony import */ var _veramo_did_provider_key__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @veramo/did-provider-key */ \"@veramo/did-provider-key\");\n/* harmony import */ var _veramo_key_manager__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @veramo/key-manager */ \"@veramo/key-manager\");\n/* harmony import */ var _veramo_kms_local__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! @veramo/kms-local */ \"@veramo/kms-local\");\n/* harmony import */ var _veramo_did_resolver__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! @veramo/did-resolver */ \"@veramo/did-resolver\");\n/* harmony import */ var did_resolver__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! did-resolver */ \"did-resolver\");\n/* harmony import */ var web_did_resolver__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! web-did-resolver */ \"web-did-resolver\");\n/* harmony import */ var key_did_resolver__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! key-did-resolver */ \"(api)/../../packages/agent/node_modules/key-did-resolver/dist/index.js\");\n/* harmony import */ var _types_js__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./types.js */ \"(api)/../../packages/agent/dist/types.js\");\n/* harmony reexport (unknown) */ var __WEBPACK_REEXPORT_OBJECT__ = {};\n/* harmony reexport (unknown) */ for(const __WEBPACK_IMPORT_KEY__ in _types_js__WEBPACK_IMPORTED_MODULE_11__) if([\"default\",\"createDIDAgent\"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) __WEBPACK_REEXPORT_OBJECT__[__WEBPACK_IMPORT_KEY__] = () => _types_js__WEBPACK_IMPORTED_MODULE_11__[__WEBPACK_IMPORT_KEY__]\n/* harmony reexport (unknown) */ __webpack_require__.d(__webpack_exports__, __WEBPACK_REEXPORT_OBJECT__);\n/* harmony import */ var _utils_js__WEBPACK_IMPORTED_MODULE_12__ = __webpack_require__(/*! ./utils.js */ \"(api)/../../packages/agent/dist/utils.js\");\n/* harmony reexport (unknown) */ var __WEBPACK_REEXPORT_OBJECT__ = {};\n/* harmony reexport (unknown) */ for(const __WEBPACK_IMPORT_KEY__ in _utils_js__WEBPACK_IMPORTED_MODULE_12__) if([\"default\",\"createDIDAgent\"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) __WEBPACK_REEXPORT_OBJECT__[__WEBPACK_IMPORT_KEY__] = () => _utils_js__WEBPACK_IMPORTED_MODULE_12__[__WEBPACK_IMPORT_KEY__]\n/* harmony reexport (unknown) */ __webpack_require__.d(__webpack_exports__, __WEBPACK_REEXPORT_OBJECT__);\nvar __webpack_async_dependencies__ = __webpack_handle_async_dependencies__([did_resolver__WEBPACK_IMPORTED_MODULE_8__, web_did_resolver__WEBPACK_IMPORTED_MODULE_9__, key_did_resolver__WEBPACK_IMPORTED_MODULE_10__]);\n([did_resolver__WEBPACK_IMPORTED_MODULE_8__, web_did_resolver__WEBPACK_IMPORTED_MODULE_9__, key_did_resolver__WEBPACK_IMPORTED_MODULE_10__] = __webpack_async_dependencies__.then ? (await __webpack_async_dependencies__)() : __webpack_async_dependencies__);\n\n\n\n\n\n\n\n\n\n\n\nconst createDIDAgent = ()=>{\n    // Support did:web and did:key resolution\n    const resolver = new did_resolver__WEBPACK_IMPORTED_MODULE_8__.Resolver({\n        ...(0,web_did_resolver__WEBPACK_IMPORTED_MODULE_9__.getResolver)(),\n        ...(0,key_did_resolver__WEBPACK_IMPORTED_MODULE_10__.getResolver)()\n    });\n    return (0,_veramo_core__WEBPACK_IMPORTED_MODULE_0__.createAgent)({\n        plugins: [\n            new _veramo_key_manager__WEBPACK_IMPORTED_MODULE_5__.KeyManager({\n                store: new _veramo_key_manager__WEBPACK_IMPORTED_MODULE_5__.MemoryKeyStore(),\n                kms: {\n                    local: new _veramo_kms_local__WEBPACK_IMPORTED_MODULE_6__.KeyManagementSystem(new _veramo_key_manager__WEBPACK_IMPORTED_MODULE_5__.MemoryPrivateKeyStore())\n                }\n            }),\n            new _veramo_did_manager__WEBPACK_IMPORTED_MODULE_2__.DIDManager({\n                store: new _veramo_did_manager__WEBPACK_IMPORTED_MODULE_2__.MemoryDIDStore(),\n                defaultProvider: \"did:key\",\n                providers: {\n                    \"did:key\": new _veramo_did_provider_key__WEBPACK_IMPORTED_MODULE_4__.KeyDIDProvider({\n                        defaultKms: \"local\"\n                    }),\n                    \"did:web\": new _veramo_did_provider_web__WEBPACK_IMPORTED_MODULE_3__.WebDIDProvider({\n                        defaultKms: \"local\"\n                    })\n                }\n            }),\n            new _veramo_did_resolver__WEBPACK_IMPORTED_MODULE_7__.DIDResolverPlugin({\n                resolver\n            }),\n            new _veramo_credential_w3c__WEBPACK_IMPORTED_MODULE_1__.CredentialPlugin()\n        ]\n    });\n};\n\n\n\n__webpack_async_result__();\n} catch(e) { __webpack_async_result__(e); } });//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi4vLi4vcGFja2FnZXMvYWdlbnQvZGlzdC9pbmRleC5qcyIsIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7OztBQUEyQztBQUNlO0FBQ087QUFDUDtBQUNBO0FBQzhCO0FBQ2hDO0FBQ0M7QUFDakI7QUFDeUI7QUFDQTtBQUMxRCxNQUFNZSxpQkFBaUI7SUFDMUIseUNBQXlDO0lBQ3pDLE1BQU1DLFdBQVcsSUFBSUwsa0RBQVFBLENBQUM7UUFDMUIsR0FBR0UsNkRBQWNBLEVBQUU7UUFDbkIsR0FBR0MsOERBQWNBLEVBQUU7SUFDdkI7SUFDQSxPQUFPZCx5REFBV0EsQ0FBQztRQUNmaUIsU0FBUztZQUNMLElBQUlYLDJEQUFVQSxDQUFDO2dCQUNYWSxPQUFPLElBQUlYLCtEQUFjQTtnQkFDekJZLEtBQUs7b0JBQUVDLE9BQU8sSUFBSVgsa0VBQW1CQSxDQUFDLElBQUlELHNFQUFxQkE7Z0JBQUk7WUFDdkU7WUFDQSxJQUFJTiwyREFBVUEsQ0FBQztnQkFDWGdCLE9BQU8sSUFBSWYsK0RBQWNBO2dCQUN6QmtCLGlCQUFpQjtnQkFDakJDLFdBQVc7b0JBQ1AsV0FBVyxJQUFJakIsb0VBQWNBLENBQUM7d0JBQUVrQixZQUFZO29CQUFRO29CQUNwRCxXQUFXLElBQUluQixvRUFBY0EsQ0FBQzt3QkFBRW1CLFlBQVk7b0JBQVE7Z0JBQ3hEO1lBQ0o7WUFDQSxJQUFJYixtRUFBaUJBLENBQUM7Z0JBQUVNO1lBQVM7WUFDakMsSUFBSWYsb0VBQWdCQTtTQUN2QjtJQUNMO0FBQ0osRUFBRTtBQUN5QjtBQUNBIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vQHNhYXMvYWRtaW4tcG9ydGFsLy4uLy4uL3BhY2thZ2VzL2FnZW50L2Rpc3QvaW5kZXguanM/ZjY4MyJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBjcmVhdGVBZ2VudCB9IGZyb20gJ0B2ZXJhbW8vY29yZSc7XG5pbXBvcnQgeyBDcmVkZW50aWFsUGx1Z2luIH0gZnJvbSAnQHZlcmFtby9jcmVkZW50aWFsLXczYyc7XG5pbXBvcnQgeyBESURNYW5hZ2VyLCBNZW1vcnlESURTdG9yZSB9IGZyb20gJ0B2ZXJhbW8vZGlkLW1hbmFnZXInO1xuaW1wb3J0IHsgV2ViRElEUHJvdmlkZXIgfSBmcm9tICdAdmVyYW1vL2RpZC1wcm92aWRlci13ZWInO1xuaW1wb3J0IHsgS2V5RElEUHJvdmlkZXIgfSBmcm9tICdAdmVyYW1vL2RpZC1wcm92aWRlci1rZXknO1xuaW1wb3J0IHsgS2V5TWFuYWdlciwgTWVtb3J5S2V5U3RvcmUsIE1lbW9yeVByaXZhdGVLZXlTdG9yZSB9IGZyb20gJ0B2ZXJhbW8va2V5LW1hbmFnZXInO1xuaW1wb3J0IHsgS2V5TWFuYWdlbWVudFN5c3RlbSB9IGZyb20gJ0B2ZXJhbW8va21zLWxvY2FsJztcbmltcG9ydCB7IERJRFJlc29sdmVyUGx1Z2luIH0gZnJvbSAnQHZlcmFtby9kaWQtcmVzb2x2ZXInO1xuaW1wb3J0IHsgUmVzb2x2ZXIgfSBmcm9tICdkaWQtcmVzb2x2ZXInO1xuaW1wb3J0IHsgZ2V0UmVzb2x2ZXIgYXMgd2ViRGlkUmVzb2x2ZXIgfSBmcm9tICd3ZWItZGlkLXJlc29sdmVyJztcbmltcG9ydCB7IGdldFJlc29sdmVyIGFzIGtleURpZFJlc29sdmVyIH0gZnJvbSAna2V5LWRpZC1yZXNvbHZlcic7XG5leHBvcnQgY29uc3QgY3JlYXRlRElEQWdlbnQgPSAoKSA9PiB7XG4gICAgLy8gU3VwcG9ydCBkaWQ6d2ViIGFuZCBkaWQ6a2V5IHJlc29sdXRpb25cbiAgICBjb25zdCByZXNvbHZlciA9IG5ldyBSZXNvbHZlcih7XG4gICAgICAgIC4uLndlYkRpZFJlc29sdmVyKCksXG4gICAgICAgIC4uLmtleURpZFJlc29sdmVyKCksXG4gICAgfSk7XG4gICAgcmV0dXJuIGNyZWF0ZUFnZW50KHtcbiAgICAgICAgcGx1Z2luczogW1xuICAgICAgICAgICAgbmV3IEtleU1hbmFnZXIoe1xuICAgICAgICAgICAgICAgIHN0b3JlOiBuZXcgTWVtb3J5S2V5U3RvcmUoKSwgLy8gZGV2LW9ubHk7IHJlcGxhY2Ugd2l0aCBwZXJzaXN0ZW50IHN0b3JlIGxhdGVyXG4gICAgICAgICAgICAgICAga21zOiB7IGxvY2FsOiBuZXcgS2V5TWFuYWdlbWVudFN5c3RlbShuZXcgTWVtb3J5UHJpdmF0ZUtleVN0b3JlKCkpIH1cbiAgICAgICAgICAgIH0pLFxuICAgICAgICAgICAgbmV3IERJRE1hbmFnZXIoe1xuICAgICAgICAgICAgICAgIHN0b3JlOiBuZXcgTWVtb3J5RElEU3RvcmUoKSwgLy8gZGV2LW9ubHk7IHJlcGxhY2Ugd2l0aCBwZXJzaXN0ZW50IHN0b3JlIGxhdGVyXG4gICAgICAgICAgICAgICAgZGVmYXVsdFByb3ZpZGVyOiAnZGlkOmtleScsIC8vIGRldiBkZWZhdWx0IChubyBob3N0aW5nIHJlcXVpcmVkKVxuICAgICAgICAgICAgICAgIHByb3ZpZGVyczoge1xuICAgICAgICAgICAgICAgICAgICAnZGlkOmtleSc6IG5ldyBLZXlESURQcm92aWRlcih7IGRlZmF1bHRLbXM6ICdsb2NhbCcgfSksXG4gICAgICAgICAgICAgICAgICAgICdkaWQ6d2ViJzogbmV3IFdlYkRJRFByb3ZpZGVyKHsgZGVmYXVsdEttczogJ2xvY2FsJyB9KVxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH0pLFxuICAgICAgICAgICAgbmV3IERJRFJlc29sdmVyUGx1Z2luKHsgcmVzb2x2ZXIgfSksXG4gICAgICAgICAgICBuZXcgQ3JlZGVudGlhbFBsdWdpbigpXG4gICAgICAgIF1cbiAgICB9KTtcbn07XG5leHBvcnQgKiBmcm9tICcuL3R5cGVzLmpzJztcbmV4cG9ydCAqIGZyb20gJy4vdXRpbHMuanMnO1xuIl0sIm5hbWVzIjpbImNyZWF0ZUFnZW50IiwiQ3JlZGVudGlhbFBsdWdpbiIsIkRJRE1hbmFnZXIiLCJNZW1vcnlESURTdG9yZSIsIldlYkRJRFByb3ZpZGVyIiwiS2V5RElEUHJvdmlkZXIiLCJLZXlNYW5hZ2VyIiwiTWVtb3J5S2V5U3RvcmUiLCJNZW1vcnlQcml2YXRlS2V5U3RvcmUiLCJLZXlNYW5hZ2VtZW50U3lzdGVtIiwiRElEUmVzb2x2ZXJQbHVnaW4iLCJSZXNvbHZlciIsImdldFJlc29sdmVyIiwid2ViRGlkUmVzb2x2ZXIiLCJrZXlEaWRSZXNvbHZlciIsImNyZWF0ZURJREFnZW50IiwicmVzb2x2ZXIiLCJwbHVnaW5zIiwic3RvcmUiLCJrbXMiLCJsb2NhbCIsImRlZmF1bHRQcm92aWRlciIsInByb3ZpZGVycyIsImRlZmF1bHRLbXMiXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///(api)/../../packages/agent/dist/index.js\n");

/***/ }),

/***/ "(api)/../../packages/agent/dist/types.js":
/*!******************************************!*\
  !*** ../../packages/agent/dist/types.js ***!
  \******************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi4vLi4vcGFja2FnZXMvYWdlbnQvZGlzdC90eXBlcy5qcyIsIm1hcHBpbmdzIjoiO0FBQVUiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9Ac2Fhcy9hZG1pbi1wb3J0YWwvLi4vLi4vcGFja2FnZXMvYWdlbnQvZGlzdC90eXBlcy5qcz9iMTE5Il0sInNvdXJjZXNDb250ZW50IjpbImV4cG9ydCB7fTtcbiJdLCJuYW1lcyI6W10sInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///(api)/../../packages/agent/dist/types.js\n");

/***/ }),

/***/ "(api)/../../packages/agent/dist/utils.js":
/*!******************************************!*\
  !*** ../../packages/agent/dist/utils.js ***!
  \******************************************/
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   generateDID: () => (/* binding */ generateDID),\n/* harmony export */   parseDID: () => (/* binding */ parseDID)\n/* harmony export */ });\nfunction generateDID(method, identifier) {\n    return `did:${method}:${identifier}`;\n}\nfunction parseDID(did) {\n    const parts = did.split(\":\");\n    return {\n        method: parts[1],\n        identifier: parts.slice(2).join(\":\")\n    };\n}\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi4vLi4vcGFja2FnZXMvYWdlbnQvZGlzdC91dGlscy5qcyIsIm1hcHBpbmdzIjoiOzs7OztBQUFPLFNBQVNBLFlBQVlDLE1BQU0sRUFBRUMsVUFBVTtJQUMxQyxPQUFPLENBQUMsSUFBSSxFQUFFRCxPQUFPLENBQUMsRUFBRUMsV0FBVyxDQUFDO0FBQ3hDO0FBQ08sU0FBU0MsU0FBU0MsR0FBRztJQUN4QixNQUFNQyxRQUFRRCxJQUFJRSxLQUFLLENBQUM7SUFDeEIsT0FBTztRQUFFTCxRQUFRSSxLQUFLLENBQUMsRUFBRTtRQUFFSCxZQUFZRyxNQUFNRSxLQUFLLENBQUMsR0FBR0MsSUFBSSxDQUFDO0lBQUs7QUFDcEUiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9Ac2Fhcy9hZG1pbi1wb3J0YWwvLi4vLi4vcGFja2FnZXMvYWdlbnQvZGlzdC91dGlscy5qcz81MDk5Il0sInNvdXJjZXNDb250ZW50IjpbImV4cG9ydCBmdW5jdGlvbiBnZW5lcmF0ZURJRChtZXRob2QsIGlkZW50aWZpZXIpIHtcbiAgICByZXR1cm4gYGRpZDoke21ldGhvZH06JHtpZGVudGlmaWVyfWA7XG59XG5leHBvcnQgZnVuY3Rpb24gcGFyc2VESUQoZGlkKSB7XG4gICAgY29uc3QgcGFydHMgPSBkaWQuc3BsaXQoJzonKTtcbiAgICByZXR1cm4geyBtZXRob2Q6IHBhcnRzWzFdLCBpZGVudGlmaWVyOiBwYXJ0cy5zbGljZSgyKS5qb2luKCc6JykgfTtcbn1cbiJdLCJuYW1lcyI6WyJnZW5lcmF0ZURJRCIsIm1ldGhvZCIsImlkZW50aWZpZXIiLCJwYXJzZURJRCIsImRpZCIsInBhcnRzIiwic3BsaXQiLCJzbGljZSIsImpvaW4iXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///(api)/../../packages/agent/dist/utils.js\n");

/***/ })

};
;

// load runtime
var __webpack_require__ = require("../../webpack-api-runtime.js");
__webpack_require__.C(exports);
var __webpack_exec__ = (moduleId) => (__webpack_require__(__webpack_require__.s = moduleId))
var __webpack_exports__ = __webpack_require__.X(0, ["vendor-chunks/next","vendor-chunks/uint8arrays","vendor-chunks/key-did-resolver","vendor-chunks/multiformats"], () => (__webpack_exec__("(api)/../../node_modules/next/dist/build/webpack/loaders/next-route-loader/index.js?kind=PAGES_API&page=%2Fapi%2Fholder-did&preferredRegion=&absolutePagePath=.%2Fpages%2Fapi%2Fholder-did.ts&middlewareConfigBase64=e30%3D!")));
module.exports = __webpack_exports__;

})();