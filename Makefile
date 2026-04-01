.PHONY: watch lint fmt build update docker-build docker-run docker-log gh-cache-clear backup

lint:
	cargo fmt --check
	cargo clippy --all-targets --all-features --locked -- -D warnings
	cargo check --release --locked

watch:
	watchexec --restart --watch src --watch assets --exts rs,css,js,svg -- cargo run

fmt:
	cargo fmt

build:
	cargo build --release --locked
	ls -lh target/release/$(shell basename $(CURDIR))

update:
	@# cargo install cargo-edit
	cargo upgrade -i

docker-build:
	docker build -t ghstats .
	docker images -q ghstats | xargs docker inspect -f '{{.Size}}' | xargs numfmt --to=iec

docker-run: docker-build
	docker rm --force ghstats || true
	docker run -p 8080:8080 -v ./data:/app/data --env-file .env --name ghstats ghstats

docker-log:
	docker logs ghstats --follow

gh-cache-clear:
	gh cache delete --all

# --- Deploy ---

HOST=srv
EXEC=ssh -tt $(HOST)

backup:
	mkdir -p data
	scp $(HOST):/root/data/ghstats.db data/backup-$(shell date -u +"%Y%m%d_%H%M").db
	cp $$(ls -1t data/*.db | head -n 1) data/backup.db
