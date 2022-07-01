# humanoid sim

### choreonoidの立ち上げ
- ```./run_sim_local.sh rtmlaunch hrpsys_choreonoid_tutorials jaxon_jvrc_choreonoid.launch LOAD_OBJECTS:=true```

### choreonoidの立ち上げ(hrpsysをソースからインストールしているものを使う)
- ```DOCKER_IMAGE=irslrepo/humanoid_sim_source:melodic ./run_sim_local.sh rtmlaunch hrpsys_choreonoid_tutorials jaxon_jvrc_choreonoid.launch LOAD_OBJECTS:=true```

### 操作用のコンソール立ち上げ (console B)
- ```docker exec -it  docker_humanoid_sim bash```

### 以下 console B にて
### ROSの設定
- ```source /irsl_entryrc```

### ディレクトリ移動
- ```roscd hrpsys_choreonoid_tutorials/euslisp```

### EusLispの立ち上げ
- ```roseus jaxon_jvrc-interface.l```

### EusLispの立ち上げ
- ```(jaxon_jvrc-init)```
- ```(setq *robot* (jaxon_jvrc))```

### モデルの表示
- ```(objects (list *robot*))```

### モデルの関節角度を返す
- ```(send *robot* :angle-vector)```

### モデルの関節角度をデフォルトにする
- ```(send *robot* :reset-pose)```

### モデルの脚先を移動させる #f(x y z)
- ```(send *robot* :legs :move-end-pos #f(0 0 -5))```

### モデルを指定座標に移動させる
- ```(send *robot* :fix-leg-to-coords (make-coords))```

### モデルの重心位置を移動させる
- ```(send *robot* :move-centroid-on-foot :both (list :rleg :lleg))```

### モデルの関節角度を実機に反映させる / 1000msで移行
- ```(send *ri* :angle-vector (send *robot* :angle-vector) 1000)```

### 実機の動作完了を待つ
- ```(send *ri* :wait-interpolation)```

### 実機の手順/センサのオフセットを除去(ロボットを浮かせて行う)
- ```(send *ri* :remove-force-sensor-offset-rmfo)```
- ```;; (send *ri* :set-auto-balancer-param :default-zmp-offsets '(#F(10 0 0) #F(10 0 0)))```

### 実機の手順/auto-balancerを動作させる
- ```(send *ri* :start-auto-balancer)```

### 実機の手順/stabilizerを動作させる
- ```(send *ri* :start-st)```

### 実機の手順/歩く x[m] y[m] theta[deg]
- ```(send *ri* :go-pos 1.0 0 0)```
