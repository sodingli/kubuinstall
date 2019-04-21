

#### 调整自动
```shell
$source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
$echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.


$alias k=kubectl
$complete -F __start_kubectl k

```


#### 配置
使用 kubectl 的第一步是配置 Kubernetes 集群以及认证方式，包括

* cluster 信息：Kubernetes server 地址
* 用户信息：用户名、密码或密钥
* Context：cluster、用户信息以及 Namespace 的组合

**示例**
```bash
kubectl config set-credentials myself --username=admin --password=secret
kubectl config set-cluster local-server --server=http://localhost:8080
kubectl config set-context default-context --cluster=local-server --user=myself --namespace=default
kubectl config use-context default-context
kubectl config view
```

#### 例子

```bash
kubectl -h 查看子命令列表

kubectl -n namespace

kubectl -f  Labelname

kubectl options 查看全局选项

kubectl <command> --help 查看子命令的帮助

kubectl [command] [PARAMS] -o=<format> 设置输出格式（如 json、yaml、jsonpath 等）

kubectl explain [RESOURCE] 查看资源的定义
```


#### 常用命令格式

* 创建：kubectl run <name> --image=<image> 或者 kubectl create -f manifest.yaml
* 查看 kubectl describe 

* 导出配置：kubectl get deployments.apps *deploymentsname*  -o yaml > nginx2_yaml
* 
* 查询：kubectl get deployments. *deploymentsname*   -o json
* 
* 更新 kubectl set 或者 kubectl patch
* `kubectl patch pod nodename -p '{"metadata":{"labels":{"app":"newname"}}}'`
* 
* 删除：kubectl delete <resource> <name> 或者 kubectl delete -f manifest.yaml
* `kubectl  delete pods --field-selector=status.phase=Pending`
* `delete pods --field-selector=status.phase=Pending --grace-period=0 --force=true` #强制杀掉
* 
* 查询 Pod IP：kubectl get pod <pod-name> -o jsonpath='{.status.podIP}'
* 
* 容器内执行命令：kubectl exec -ti <pod-name> sh
* 
* 容器日志：kubectl logs [-f] <pod-name>
* 
* `kubectl  describe pod|node  podname|nodename`
* 
* 
* 导出服务：kubectl expose deploy <name> --port=80
* 
* 在线扩容服务:kubectl scale --replicas=3 deployment/*deploymentsname* 
* 

Base64 解码：

```kubectl get secret SECRET -o go-template='{{ .data.KEY | base64decode}}'```
注意，kubectl run 仅支持 Pod、Replication Controller、Deployment、Job 和 CronJob 等几种资源。具体的资源类型是由参数决定的，默认为 Deployment：




![1b32ee60fc156966f57c570a9739bd0a.png](evernotecid://CF28A078-1096-40A0-9ACD-0DAA8CE64AC7/appyinxiangcom/6208230/ENResource/p761)

