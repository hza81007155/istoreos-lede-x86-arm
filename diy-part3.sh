#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# 选择6.6内核
#sed -i 's/6.12/6.6/g' target/linux/x86/Makefile
# 设置默认ip
sed -i 's/192.168.1.1/192.168.10.12/g' package/base-files/luci/bin/config_generate
sed -i 's/192.168.1.1/192.168.10.12/g' package/base-files/files/bin/config_generate

# 移除要替换的包
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/packages/net/chinadns-ng
rm -rf feeds/packages/net/geoview
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/lucky
rm -rf feeds/packages/utils/coremark
rm -rf feeds/packages/net/ksmbd

#!/bin/bash

# ==============================================
# 【LEDE 专用】删除 Lean 源码自带的 Argon 主题
# ==============================================
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/luci-app-argon-config
rm -rf package/luci-theme-argon
rm -rf package/luci-app-argon-config

# 从 feeds 彻底卸载
./scripts/feeds uninstall luci-theme-argon
./scripts/feeds uninstall luci-app-argon-config

# ==============================================
# 拉取 【你自己的 Argon 主题】
# ==============================================
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon

# 拉取配套设置插件（原版）
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config

# ==============================================
# 更新依赖（必须）
# ==============================================
./scripts/feeds update -a
./scripts/feeds install -a

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by hza800755/g" package/lean/default-settings/files/zzz-default-settings

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加插件
git_sparse_clone openwrt-24.10 https://github.com/openwrt/packages utils/coremark
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall package/luci-app-passwall
git clone --depth=1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall2 package/openwrt-passwall2

# istore
git clone https://github.com/linkease/istore-ui.git package/istore/istore-ui
git clone https://github.com/linkease/istore.git package/istore/istore
git clone https://github.com/linkease/nas-packages.git package/nas
git clone https://github.com/linkease/nas-packages-luci.git package/luci-app-nas

# 设置默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-light/Makefile
