Optimizer mode/goal
设置SQL的执行优化模式
可选值
`ALL_ROWS`,默认值.基于CBO以最优方案操作所有记录
`FIRST_ROWS`,基于CBO以最优方案操作前Ｎ条记录
`RULE`


访问记录的方式
Full Table Scan(FTS,全表扫描)
Table Access by ROWID(rowid lookup, 通过ROWID访问)
Index Scan/Lookup(索引扫描)
1.Index unique scan
2.Index range scan
3.Index full scan
4.Index fast full scan
