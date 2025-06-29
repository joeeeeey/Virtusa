build:
	pushd app && docker build -t nodejs-crud-app:1.0 . && popd

load:
	kind load docker-image nodejs-crud-app:1.0 --name symbiosis

deploy:
	pushd k8s && helm upgrade --install nodejs-mysql . --namespace nodejs-crud --create-namespace && popd

clean:
	helm uninstall nodejs-mysql -n nodejs-crud 2>/dev/null || true
	kubectl delete namespace mysql nodejs-crud 2>/dev/null || true

init:
	kind create cluster --name symbiosis --config kind-cluster.yaml || true
	make build load

	pushd k8s && chmod +x deploy-all.sh && ./deploy-all.sh && popd

destroy:
	make clean
	kind delete cluster --name symbiosis

all: build load deploy