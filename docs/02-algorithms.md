# 从正确目标函数到两种搜索方法

GA 和 SA 都是启发式算法。它们在有限预算下寻找好解，不提供“已找到全局最优”的通用证明。比较之前，二者必须调用相同的距离规则和闭环目标函数。

## 遗传算法 GA

```matlab
[route, length, info] = tsp.ga(coords, maxGenerations, populationSize, crossProb, mutationProb, options);
```

1. 生成若干随机排列，评价整个初始种群，选择其中的最优路线。
2. 二元锦标赛从两名不同个体中选择长度较小者；种群只有一个个体时直接返回它。
3. 顺序交叉 OX 保留一个父代的连续片段，按另一个父代的环绕次序补齐剩余城市。
4. 按给定概率反转一个片段，保持每个城市恰好出现一次。
5. 将父代和已评价的子代合并，按长度选出最好的固定数量个体。
6. 达到代数或评估预算时返回当前最优。

初始种群计入预算。零代仍会评价初始种群；两代恰好产生两批子代。最后预算不足一整代时只评价前面可容纳的子代，不隐藏超预算的目标函数调用。

已有个体的长度会缓存，选择和精英保留不再重新评价它们。内部直接比较长度，因此零长度路线不会产生无限大的适应度。兼容函数 `cal_fitness` 改为 `1/(1+length)`，保持“越短越好”的顺序，但其数值与旧倒数定义不同。

## 模拟退火 SA

```matlab
[route, length, info] = tsp.sa(coords, temperature, coolingRate, maxOuter, maxInner, options);
```

从随机路线开始，通过随机片段反转产生邻居。更短或等长的邻居直接接受；更长的邻居按 `exp(-delta/T)` 的概率接受。每完成一层内循环，温度乘以 coolingRate。

当前路线和历史最优路线是不同状态：接受一个更差解可能帮助跳出局部最优，但不能把历史最好结果丢掉。当前长度也会缓存，每个邻居仅评价一次。

初始温度必须有限且大于 0；降温率严格介于 0 与 1。温度在多次乘法后可能下溢为 0，此时只接受不更差的邻居，不进行除零计算。单城市反转直接返回原路线，不会等待抽到两个不同城市。

## 共同参数与返回值

第六个参数可以省略，也可以传入：

```matlab
options = struct('Seed', 42, 'DistanceType', 'ATT', 'MaxEvaluations', 2000);
```

| 字段 | 默认值 | 约束 |
| --- | --- | --- |
| Seed | [] | [] 使用调用者随机流；否则为 0 到 2^32-1 的整数 |
| DistanceType | ATT | ATT、EUC_2D、EUCLIDEAN |
| MaxEvaluations | Inf | 正整数或 Inf；GA 至少覆盖整个初始种群 |

未知字段直接报错，防止拼写错误悄悄改变实验。迭代次数为非负整数，种群和内循环次数为正整数，交叉/变异概率在 [0,1] 内。

合法的整数类型输入（例如 `uint8(50)`）先校验，再转换为 double 参与计数和降温。否则 MATLAB 的[整数混合运算](https://www.mathworks.com/help/matlab/matlab_prog/integers.html)会把结果转回整数，导致预算饱和或温度取整。计数不能超过 flintmax；int64/uint64 在转换前检查上限，避免先丢精度再校验。返回的 Options 中 Seed 和有限预算也统一为 double。

`route` 是最优排列，`length` 是该排列的闭环长度，`info` 包含 Algorithm、Evaluations、Iterations、BestHistory、EvaluationHistory 与 Options；SA 还包含 FinalTemperature。历史采样为 GA 每代、SA 每个温度层结束，不是逐邻居记录。用 EvaluationHistory 作横轴能展示评估预算，不能把曲线拐点当作每次改进的精确时刻。

## 源码导航

| 学习问题 | 入口 |
| --- | --- |
| 路径怎么算 | routeLength.m、costUnchecked.m |
| 输入哪里校验 | validateRoute.m、validateDistanceMatrix.m、validatePopulation.m |
| 为什么不会丢城市 | crossover.m、reverseSegment.m、mutate.m |
| 如何选父代 | selectParents.m |
| 怎样计数和停止 | ga.m、sa.m |
| 怎么复现随机行为 | options.m、seedScope.m |

以上文件均在 `+tsp/`。距离矩阵需要 O(N²) 内存，单次完整路线评价需要 O(N) 时间；目前没有为大实例实现增量 delta 评价。优化前先保留正确性测试，并统一新的预算定义。
