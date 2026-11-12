# HENG 最终启动视觉（2026-11-12 定稿）

## 文件

- `launch.png` — 静态启动图，1320×2868（iPhone 6.9"）
- `launch_motion.mp4` — 冷启动动效 C（景深显影）预览，540×1174；正式实现输出 1080×1920
- `ui_palette.png` — Forest Paper UI Kit 色板（待应用到 App）
- `source/heng_oracle.svg` — 甲骨文「衡」轮廓矢量源文件
- `source/heng_reference.jpg` — 用户提供的甲骨文参考图

## 启动页规格

- 背景：`#063A2C → #0B1512` 深绿渐变 + 极淡顶部光晕
- 甲骨文字形：高 280px，居中，颜色 `#F4F3EE`
- HENG：Helvetica Neue Bold 130px，白色，字距 5px
- 中文主标：28px，`#CDEEE1`
- 副标：18px，`#96BEAF`
- 底部两行（Helvetica Neue Regular 26px，字距 3px）：
  - `PRIVATE LEDGER` — `#E8F1EC`
  - `DESIGNED BY ARCHINTERA` — `#8FA69B`

## 动效 C（景深显影）

- 时长 2.6s，单次播放，ease-out，不循环
- 甲骨 8px 模糊 → 清晰、1.04 → 1.0
- 0.8s HENG 淡入并收紧字距，1.7s 副标淡入
- footer 最后 0.4s 淡入，与静态图无缝衔接
- 可点击跳过；`reduce motion` 降级为 200ms 交叉淡入
- iOS LaunchScreen 本身是静态的，动效是冷启动后的 App 内品牌开场
