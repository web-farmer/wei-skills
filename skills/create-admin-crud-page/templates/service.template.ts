import { type AxiosPromise } from 'axios'

import { request } from '@/utils'
import type { ApiPromise } from '@/utils/request/type'

/**
 * {{pageTitle}} 列表请求参数
 */
export interface {{listParamsTypeName}} {
  page?: number
  per_page?: number
  search_key?: string
}

/**
 * {{pageTitle}} 列表项
 */
export interface {{listItemTypeName}} {
  id?: number
  name?: string
}

/**
 * {{pageTitle}} 表单数据
 */
export interface {{formItemTypeName}} {
  id?: number
  name: string
}

/**
 * 获取{{pageTitle}}列表
 * @description 根据查询条件获取{{pageTitle}}分页数据
 */
export const {{serviceMethodListName}} = (data: {{listParamsTypeName}}): AxiosPromise => {
  return request.get({
    url: '{{listApiPath}}',
    data,
    timestamp: true
  })
}

/**
 * 获取{{pageTitle}}详情
 */
export const {{serviceMethodDetailName}} = (data: { id: number }): ApiPromise<{{formItemTypeName}}> => {
  return request.get({
    url: '{{detailApiPath}}',
    data,
    timestamp: true
  })
}

/**
 * 新增{{pageTitle}}
 */
export const {{serviceMethodCreateName}} = (data: {{formItemTypeName}}): AxiosPromise => {
  return request.post({
    url: '{{createApiPath}}',
    data
  })
}

/**
 * 编辑{{pageTitle}}
 */
export const {{serviceMethodUpdateName}} = (data: {{formItemTypeName}}): AxiosPromise => {
  return request.post({
    url: '{{updateApiPath}}',
    data
  })
}

/**
 * 删除{{pageTitle}}
 */
export const {{serviceMethodDeleteName}} = (data: { id: number }): AxiosPromise => {
  return request.post({
    url: '{{deleteApiPath}}',
    data
  })
}