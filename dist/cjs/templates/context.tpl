// Mustache的 tpl 语法，安装 Mustache Templates - Syntax Highlighting, Snippets & Autocomplete 可高亮
import React, { ReactNode, useEffect } from 'react';
import { useOutlet, useLocation, matchPath, useNavigate } from 'react-router-dom'
{{^hasCustomTabs}}
{{#hasTabsLayout}}
import { Tabs, message, Dropdown, Button, Menu, TabPaneProps } from "antd";
import { EllipsisOutlined, VerticalRightOutlined, VerticalLeftOutlined, CloseOutlined, ReloadOutlined } from "@ant-design/icons";
{{/hasTabsLayout}}
{{/hasCustomTabs}}
{{#hasTabsLayout}}
import { getPluginManager } from '../core/plugin';
{{/hasTabsLayout}}
{{#hasCustomTabs}}
import { getCustomTabs } from '@/app';
{{/hasCustomTabs}}
{{#isPluginModelEnable}}
import { useModel } from '@@/plugin-model';
{{/isPluginModelEnable}}
import { useAppData } from '../exports';
{{#hasIntl}}
import { useIntl } from '../exports';
{{/hasIntl}}
{{^hasCustomTabs}}
{{#hasTabsLayout}}
{{^isNewTabsAPISupported}}
const { TabPane } = Tabs;
{{/isNewTabsAPISupported}}

export interface TabConfig extends TabPaneProps{
  icon?: ReactNode;
  name?: string;
  closable?: boolean;
}

{{/hasTabsLayout}}
{{/hasCustomTabs}}


export interface KeepAliveContextProps {
  keepalive: RegExp[],
  setKeepalive: React.Dispatch<React.SetStateAction<RegExp[]>>,
  keepElements: React.MutableRefObject<any>,
  dropByCacheKey: (path: string) => void,
  cacheKeyMap: Record<string, number>,
{{#hasTabsLayout}}
  tabNameMap: Record<string, number>,
  dropLeftTabs: (path: string) => void,
  dropRightTabs: (path: string) => void,
  dropOtherTabs: (path: string) => void,
  refreshTab: (path: string) => void,
  updateTab: (path: string, config: TabConfig) => void,
  replaceTab: (newPath: string) => void,
{{/hasTabsLayout}}
}

export const KeepAliveContext = React.createContext<KeepAliveContextProps>({});
type Subscription<T> = (val: T) => void;
class EventEmitter<T> {
  private subscriptions = new Set<Subscription<T>>();

  emit = (val: T) => {
    for (const subscription of this.subscriptions) {
      subscription(val);
    }
  };

  useSubscription = (callback: Subscription<T>) => {
    function subscription(val: T) {
      if (callback) {
        callback(val);
      }
    }
    this.subscriptions.add(subscription);
  };
}
export const keepaliveEmitter = new EventEmitter();

// 兼容非全路径的 path
const getFullPath = (currPath = '', parentPath = '') => {
  if (currPath.startsWith('/')) {
    return currPath;
  }
  return `${parentPath.replace(/\/$/, '')}/${currPath}`;
};
const findRouteByPath = (path, routes) => {
    let route = {};
    const find = (routess, parentPath) => {
        for(let i = 0; i < routess.length; i++){
            const item = routess[i];
            const fullPath = getFullPath(item.path, parentPath);
            // path:'*' 404 page
            if (matchPath(fullPath?.toLowerCase(), path?.toLowerCase())&&!item.isLayout&& item.path !=='*') {
                route = item;
                break;
            }
            if(item.children){
                find(item.children, fullPath);
            }
        }
    }
    find(routes);
    return route;
}
const isKeepPath = (aliveList: any[], path: string, route:any) => {
    let isKeep = false;
    aliveList.map(item => {
        if (item === path) {
            isKeep = true;
        }
        if (item instanceof RegExp && item.test(path)) {
            isKeep = true;
        }
        if (typeof item === 'string' && item?.toLowerCase() === path?.toLowerCase()) {
            isKeep = true;
        }
    })
    if(isKeep === false){
        isKeep = !!route.isKeepalive;
    }
    if(route?.redirect) {
        console.log('redirect')
        isKeep = false;
    }
    return isKeep;
}

{{#hasTabsLayout}}
const getMatchPathName = (pathname: string, local: Record<string, string>={}) => {
    const tabs = Object.entries(local);
    let tabName = pathname;

    for (const [key, value] of tabs) {
        // /* 404 page
        if (matchPath(key?.toLowerCase(), pathname?.toLowerCase()) && key !== '/*') {
            tabName = value;
            break;
        }
    }
    return tabName;
}

const getLocalFromClientRoutes = (data,routesConfig) => {
    const config = {
        local: {},
        icon:{}
    };
    const getLocalFromRoutes = (routes, parentPath) => {
        routes.forEach(item => {
            const fullPath = getFullPath(item.path?.toLowerCase(), parentPath?.toLowerCase());
            if(item.routes){
                getLocalFromRoutes(item.routes, fullPath);
            }else{
                const routeConfig = {...item,...(routesConfig[item?.id]||{})};
                config.local[fullPath] = routeConfig.name;
                config.icon[fullPath] = routeConfig.icon;
            }
        })
    }
    getLocalFromRoutes(data,'');
    return config;
}
{{/hasTabsLayout}}
// this error
let pathname = '';
export function useKeepOutlets() {
    const location = useLocation();
    pathname = location.pathname?.toLowerCase();
    const element = useOutlet();
{{#hasIntl}}
    const intl = useIntl();
{{/hasIntl}}
{{^hasIntl}}
    const intl = {
        formatMessage:({defaultMessage})=>defaultMessage
    };
{{/hasIntl}}
{{#isPluginModelEnable}}
    const {initialState} = useModel('@@initialState');
{{/isPluginModelEnable}}

    const { clientRoutes, routes} = useAppData();
    const route = findRouteByPath(location.pathname?.toLowerCase(),clientRoutes);
    const routeConfig = {...route,...(routes[route?.id]||{})};

    // 通过这个 flag 来完成 tabs 的强制刷新
    const [updateFlag, setUpdateFlag] = React.useState(null);

{{#hasTabsLayout}}
    const closeTab = (targetKey:string) => {
      const pathList = Object.keys(keepElements.current)
          if (pathList.length === 1) {
            message?.info?.('至少要保留一个窗口')
            return
          }
          dropByCacheKey(targetKey?.toLowerCase())
          if (targetKey?.toLowerCase() === pathname?.toLowerCase()) {
            // 删除当前选中的tab时:
            // 1.如果当前tab是第一个时自动选中后一个
            // 2.不是第一个时自动选中前一个
            const i = pathList.indexOf(targetKey?.toLowerCase())
            const {pathname, hash, search } = keepElements.current[pathList[i === 0 ? i + 1 : i - 1]?.toLowerCase()].location;
            navigate(`${pathname}${search}${hash}`);
          }
    };
    const closeAllTabs = () => {
      const pathList = Object.keys(keepElements.current);
      pathList.forEach(targetKey => {
        dropByCacheKey(targetKey?.toLowerCase());
      });
    };

    /**
     * NOTE 新增一个替换路径的方法， 将指定路径替换成新路径，且保持原 tab 位置
     * @param path1 路径 1，可跳转的路径，必填
     * @param path2 路径 2，可选。
     *     - 如果不传，则对当前 tab 的路径进行替换，替换为 path 1
     *     - 如果传入，则将 path 1 tab 替换为 path 2，且保持原 tab 的位置
     */
    const replaceTab = (path1: string, path2?: string) => {
      let oldTabPath = path1;
      let newTabPath = path2;

      if(!oldTabPath) {
        throw new Error('replaceTab 方法必须传入 path1，否则无法跳转');
      }

      // 如果没有传入 newPath，则 oldTabPath 使用当前路径, newTabPath 使用 oldPath
      if (!newTabPath) {
        newTabPath = oldTabPath
        oldTabPath = window.location?.pathname?.toLowerCase();
      }

      const oldIndex = keepElements.current?.[oldTabPath]?.index;

      if(oldIndex === undefined) {
        throw new Error('replaceTab 方法传入 path1 不在 tab 列表中，无法进行替换');
      }

      if (oldTabPath) {
        dropByCacheKey(oldTabPath); // 先关闭当前 tab
      }

      window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__ = oldIndex;

      try {
        navigate(newTabPath);
      } catch (e){
        window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__ = undefined;
        throw e;
      }
    };

    /**
     * NOTE 根据路由的路径选择器去匹配替换的路径
     * @param path
     * @param myRouter
     */
    const replaceTabByRouter = (path: string, myRouter?: string) => {
      let newPath = path, newMyRouter = myRouter;
      // 如果没有 router，则使用当前路径为 router
      if(!newMyRouter) {
        newMyRouter = path;
      }

      // 开始遍历匹配
      const pathList = Object.keys(keepElements.current);
      const matchedPath = pathList.find(item => {
        return matchPath(newMyRouter, item);
      });

      // 如果两个路径相同，则直接跳转旧的路由
      if (matchedPath === newPath) {
        navigate(newPath);
        return;
      }

      // 如果未能匹配成功，则新增一个跳转路由
      if (!matchedPath) {
        navigate(newPath);
        return;
      }

      // 如果匹配成功，则进行替换
      replaceTab(matchedPath, newPath);
    }

    /**
     * NOTE 根据每个 tab 的索引来进行排序
     */
    const sortTabsByIndex = () => {
      // 根据索引，重新排列 keepElements.current 的键值对位置，从而实现替换路径时对应 tab 的位置得到保持
      const newKeepElements = Object.entries(keepElements.current).sort(
          ([, a], [, b]) => a.index - b.index,
      );

      keepElements.current = Object.fromEntries(newKeepElements);
    }

    /**
     * NOTE 将两个指定路径的 tab 互换位置
     * @param path1 的 Tab 路径
     * @param path2 的 Tab 路径
     */
    const swapTab = (path1: string, path2: string) => {
      const path1Index = keepElements.current?.[path1]?.index;
      const path2Index = keepElements.current?.[path2]?.index;

      if ([path1Index, path2Index].includes(undefined)) {
        throw new Error('swapTab 方法传入的路径不在 tab 列表中，无法进行交换');
      }

      keepElements.current[path1].index = path2Index;
      keepElements.current[path2].index = path1Index;

      sortTabsByIndex();

      setUpdateFlag(Date.now()); // 更新状态，触发重新渲染
    }


    /**
     * NOTE 将指定路径的 tab 移动到目标路径之前
     * @param sourcePath 待移动的 tab 路径
     * @param targetPath 目标 tab 路径
     */
    const moveBeforeTab = (sourcePath: string, targetPath: string) => {
      const sourcePathIndex = keepElements.current?.[sourcePath]?.index;
      const targetPathIndex = keepElements.current?.[targetPath]?.index;

      if ([sourcePathIndex, targetPathIndex].includes(undefined)) {
        throw new Error('moveBeforeTab 方法传入的路径不在 tab 列表中，无法进行移动');
      }

      // 如果 sourcePathIndex 在 targetPathIndex 之前，则不需要移动
      if (sourcePathIndex < targetPathIndex) {
        return;
      }

      // 将 sourcePathIndex 移动到 targetPathIndex 之前
      const newSourceIndex = targetPathIndex;
      Object.keys(keepElements.current).slice(newSourceIndex).forEach((key, index) => {
          keepElements.current[key].index = newSourceIndex + index + 1
      });
      keepElements.current[sourcePath].index = newSourceIndex;

      sortTabsByIndex();
      setUpdateFlag(Date.now()); // 更新状态，触发重新渲染
    }

    /**
     * NOTE 将指定路径的 tab 移动到目标路径之后
     * @param sourcePath 待移动的 tab 路径
     * @param targetPath 目标 tab 路径
     */
    const moveAfterTab = (sourcePath: string, targetPath: string) => {
      const sourcePathIndex = keepElements.current?.[sourcePath]?.index;
      const targetPathIndex = keepElements.current?.[targetPath]?.index;

      if ([sourcePathIndex, targetPathIndex].includes(undefined)) {
        throw new Error('moveAfterTab 方法传入的路径不在 tab 列表中，无法进行移动');
      }

      // 如果 sourcePathIndex 在 targetPathIndex 之后，则不需要移动
      if (sourcePathIndex > targetPathIndex) {
        return;
      }

       // 将 sourcePathIndex 移动到 targetPathIndex 之后
      const newSourceIndex = targetPathIndex + 1;
      Object.keys(keepElements.current).slice(newSourceIndex).forEach((key, index) => {
          keepElements.current[key].index = newSourceIndex + index + 1
      });
      keepElements.current[sourcePath].index = newSourceIndex;

      sortTabsByIndex();
      setUpdateFlag(Date.now()); // 更新状态，触发重新渲染
    }

    /**
     * NOTE 将指定路径的 tab 移动到目标路径前面或者后面（自动检测，待移动的 tab 位置大于目标位置时，说明往前移动，反之是往后移动）
     * @param sourcePath 待移动的 tab 路径
     * @param targetPath 目标 tab 路径
     */
    const moveTab = (sourcePath: string, targetPath: string) => {
      const sourcePathIndex = keepElements.current?.[sourcePath]?.index;
      const targetPathIndex = keepElements.current?.[targetPath]?.index;

      if ([sourcePathIndex, targetPathIndex].includes(undefined)) {
        throw new Error('moveTab 方法传入的路径不在 tab 列表中，无法进行移动');
      }

      // 如果 sourcePathIndex > targetPathIndex，说明往前移动，反之是往后移动
      const isForward = sourcePathIndex > targetPathIndex;

      if(isForward) {
        moveBeforeTab(sourcePath, targetPath);
      } else {
        moveAfterTab(sourcePath, targetPath);
      }
    };

    const navigate = useNavigate();
    {{#isPluginModelEnable}}
    const localConfig = React.useMemo(() => {
        const runtime = getPluginManager().applyPlugins({
          key: 'tabsLayoutEx',
          type: 'modify',
          initialValue: {initialState},
        });
        if(runtime?.local) return runtime;
        return getLocalFromClientRoutes(clientRoutes,routes);
    }, [initialState]);
    {{/isPluginModelEnable}}
    {{^isPluginModelEnable}}
      const localConfig = React.useMemo(() => {
        const runtime = getPluginManager().applyPlugins({
          key: 'tabsLayoutEx',
          type: 'modify',
          initialValue: {initialState:{}},
        });
        if(runtime?.local) return runtime;
        return getLocalFromClientRoutes(clientRoutes,routes);
      }, []);
    {{/isPluginModelEnable}}

    const selectAction = React.useCallback(({ key }) => {
      switch (key) {
        case "left":
          dropLeftTabs(location.pathname?.toLowerCase());
          break;

        case "right":
          dropRightTabs(location.pathname?.toLowerCase());
          break;

        case "others":
          dropOtherTabs(location.pathname?.toLowerCase());
          break;

        case "refresh":
          refreshTab(location.pathname?.toLowerCase());
          break;

        default:
          break;
      }
    },
    [location.pathname]
  );
  const {icon:localConfigIcon ,local, initialState: _initialState, ...tabProps} = localConfig;
{{/hasTabsLayout}}

    const {
      cacheKeyMap,
      keepElements,
      keepalive,
      dropByCacheKey,
{{#hasTabsLayout}}
      tabNameMap,
      dropLeftTabs,
      dropRightTabs,
      dropOtherTabs,
      refreshTab,
      updateTab,
{{/hasTabsLayout}}
    } = React.useContext(KeepAliveContext);

    useEffect(()=>{
      keepaliveEmitter?.useSubscription?.((event) => {
        const { type = '', payload = {} } = event;
        switch(type){
          case 'dropByCacheKey':
            dropByCacheKey(payload?.path?.toLowerCase());
            break;
{{#hasTabsLayout}}
            case 'closeTab':
              closeTab(payload?.path?.toLowerCase());
              break;
            case 'closeAllTabs':
              closeAllTabs();
              break;
            case 'replaceTab':
              replaceTab(payload?.path1?.toLowerCase(), payload?.path2?.toLowerCase());
              break;
            case 'replaceTabByRouter':
              replaceTabByRouter(payload?.path?.toLowerCase(), payload?.myRouter);
              break;
            case 'swapTab':
              swapTab(payload?.path1?.toLowerCase(), payload?.path2?.toLowerCase());
              break;
            case 'moveTab':
              moveTab(payload?.sourcePath?.toLowerCase(), payload?.targetPath?.toLowerCase());
              break;
            case 'moveBeforeTab':
              moveBeforeTab(payload?.sourcePath?.toLowerCase(), payload?.targetPath?.toLowerCase());
              break;
            case 'moveAfterTab':
              moveAfterTab(payload?.sourcePath?.toLowerCase(), payload?.targetPath?.toLowerCase());
              break;
{{/hasTabsLayout}}
          default:
            break;
        }
      });
    },[])
    const isKeep = isKeepPath(keepalive, location.pathname?.toLowerCase(), routeConfig);
    try {
      // NOTE 每一次路径变更，都将缓存的路径索引进行重新梳理
      if (isKeep) {
        let open = false;
        Object.keys(keepElements.current).forEach((key, index) => {
          if (index === window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__) {
            open = true;
          }
          keepElements.current[key].index = open ? index + 1 : index;
        });
      }

      if (isKeep && !keepElements.current[location.pathname?.toLowerCase()]) {
        // NOTE 检测一下是否需要进行 tab 替换的操作
        let currentIndex = Object.keys(keepElements.current).length;
        if (window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__ !== undefined) {
          currentIndex = window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__;
          window.replaceTabMode = undefined;
          window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__ = undefined;
        }
        let icon = getMatchPathName(location.pathname, localConfigIcon);
        if (typeof icon === 'string') icon = '';

        const defaultName = getMatchPathName(location.pathname, local);
        // 国际化使用 pro 的约定
        const name = intl.formatMessage({
          id: `menu${location.pathname.replaceAll('/', '.')}`,
          defaultMessage: defaultName,
        });
        keepElements.current[location.pathname?.toLowerCase()] = {
          children: element,
          index: currentIndex,
          name,
          icon,
          closable: true, // 默认是true
          location,
        };

        sortTabsByIndex();
      }
    } finally {
      window.__UMI_MAX_KEEP_ALIVE_TAB_INDEX__ = undefined;
    }
{{^hasCustomTabs}}
{{#hasTabsLayout}}

    const items = [
      {
        label: intl.formatMessage({
          id: `tabs.close.left`,
          defaultMessage: "关闭左侧",
        }),
        icon: <VerticalRightOutlined />,
        key: "left",
      },
      {
        label: intl.formatMessage({
          id: `tabs.close.right`,
          defaultMessage: "关闭右侧",
        }),
        icon: <VerticalLeftOutlined />,
        key: "right",
      },
      {
        label: intl.formatMessage({
          id: `tabs.close.others`,
          defaultMessage: "关闭其他",
        }),
        icon: <CloseOutlined />,
        key: "others",
      },
      {
        type: "divider",
      },
      {
        label: intl.formatMessage({
          id: `tabs.refresh`,
          defaultMessage: "刷新",
        }),
        icon: <ReloadOutlined />,
        key: "refresh",
      },
    ];
{{/hasTabsLayout}}
{{/hasCustomTabs}}
{{#hasCustomTabs}}
    const CustomTabs = React.useMemo(()=>getCustomTabs(), []);
    const tabsProps = {
        isKeep,
        keepElements,
        navigate,
        dropByCacheKey,
        dropLeftTabs,
        dropRightTabs,
        dropOtherTabs,
        refreshTab,
        updateTab,
        closeTab,
        local: localConfig.local,
        icons: localConfig.icon,
        activeKey: location.pathname?.toLowerCase(),
        tabProps,
        tabNameMap,
        updateFlag
    }
{{/hasCustomTabs}}
    return <>
{{#hasCustomTabs}}
        <CustomTabs {...tabsProps}/>
{{/hasCustomTabs}}
{{^hasCustomTabs}}
{{#hasTabsLayout}}
        <div
          className="runtime-keep-alive-tabs-layout"
          hidden={!isKeep}
          {{#hasFixedHeader}}
          style={ {height:'40px',marginBottom:'12px'} }
          {{/hasFixedHeader}}
        >
            <Tabs
{{#hasDropdown}}
              tabBarExtraContent={
{{#hasFixedHeader}}
                <div style={ { position: 'fixed', right: 0,transform:'translateY(-50%)' } }>
{{/hasFixedHeader}}
                  <Dropdown
                    {{^isNewDropdownAPISupported}}
                    overlay={
                      <Menu
                        items={items}
                        onClick={selectAction}
                      />
                    }
                    {{/isNewDropdownAPISupported}}
                    {{#isNewDropdownAPISupported}}
                    menu={ {items, onClick: selectAction} }
                    {{/isNewDropdownAPISupported}}
                    trigger={["click"]}
                  >
                    <Button size="small" icon={<EllipsisOutlined />} style={ { marginRight: 12 } } />
                  </Dropdown>
{{#hasFixedHeader}}
                </div>
{{/hasFixedHeader}}
              }
{{/hasDropdown}}
              hideAdd
              onChange={(key: string) => {
                const path = key.split('::')[0];
                const { pathname, hash, search } = keepElements.current[path?.toLowerCase()].location;
                navigate(`${pathname}${search}${hash}`);
              }}
{{#hasFixedHeader}}
              renderTabBar={(props, DefaultTabBar) => (
                <div style={ {
                  position: 'fixed', zIndex: 1, padding: 0, width: '100%',
                  background: 'white'
                } }>
                  <DefaultTabBar {...props} style={ {
                    marginBottom: 0,
                  } } />
                </div>
              )}
{{/hasFixedHeader}}
              activeKey={`${location.pathname?.toLowerCase()}::${tabNameMap[location.pathname?.toLowerCase()]}`}
              type="editable-card"
              onEdit={(key: string) => {
                // 因为下方的 key 拼接了 tabNameMap[location.pathname]
                const targetKey = key.split('::')[0];
                closeTab(targetKey?.toLowerCase());
            }}
            {...tabProps}
            {{#isNewTabsAPISupported}}
            items={Object.entries(keepElements.current).map(([pathname, {name, icon, closable, children, ...other}]: any) => ({
              label: <>{icon}{name}</>,
              key: `${pathname?.toLowerCase()}::${tabNameMap[pathname?.toLowerCase()]}`,
              closable: Object.entries(keepElements.current).length === 1 ? false : closable,
              {{#hasFixedHeader}}
              style: { paddingTop: '20px' },
              {{/hasFixedHeader}}
              ...other
            }))}
            {{/isNewTabsAPISupported}}
            >
            {{^isNewTabsAPISupported}}
                {Object.entries(keepElements.current).map(([pathname, {name, icon, closable, children, ...other}]: any) => {
                    return (
                      <TabPane
                        {{#hasFixedHeader}}
                        style={ {
                          paddingTop:"20px"
                        } }
                        {{/hasFixedHeader}}
                        key={`${pathname?.toLowerCase()}::${tabNameMap[pathname?.toLowerCase()]}`}
                        tab={<>{icon}{name}</>}
                        closable={Object.entries(keepElements.current).length === 1?false:closable}
                        {...other}
                      />
                    );
                })}
                {{/isNewTabsAPISupported}}
            </Tabs>
        </div>
{{/hasTabsLayout}}
{{/hasCustomTabs}}
        {
            Object.entries(keepElements.current).map(([pathname, { children }]: any) => (
                <div
                  key={`${pathname?.toLowerCase()}:${cacheKeyMap[pathname?.toLowerCase()] || '_'}`}
                  className="runtime-keep-alive-layout"
                  style={ {
                    height: '100%', width: '100%', position: 'relative', overflow: 'hidden auto',
                  } }
                  hidden={!matchPath(location.pathname?.toLowerCase(), pathname?.toLowerCase())}>
                    {children}
                </div>
            ))
        }
        <div hidden={isKeep} style={ { height: '100%', width: '100%', position: 'relative', overflow: 'hidden auto' } } className="runtime-keep-alive-layout-no">
            {!isKeep && element}
        </div>
    </>
}

// NOTE keep alive tabs layout，必须使用这个组件，否则 tabs 和 layout 不会生效
export const MaxTabsLayout = () => {
  const element = useKeepOutlets();
  return <>{element}</>;
};
