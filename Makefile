NAME=gateway_ui

docker:
	docker build --build-arg FOLDERS_TO_REMOVE="spec node_modules app/assets vendor/assets lib/assets" \
				--build-arg BUNDLE_WITHOUT="development:test" \
				--build-arg EXECJS_RUNTIME=Disabled \
				--build-arg RAILS_ENV=production \
				--build-arg NODE_ENV=production \
				--build-arg APP_ROOT="/opt/gateway_ui" \
				-t $(NAME):`date +%Y%m%d%H%M` \
				--rm .
