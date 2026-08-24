# Builds the CSSWG editor's drafts exactly as .github/workflows/build-specs.yml
# does (Bikeshed specs, issues lists, markdown explainers, index + symlinks)
# and serves the result as a static site.
FROM python:3.13-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends git cmark-gfm \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir bikeshed && bikeshed update
WORKDIR /src
COPY . .
# The build context is a shallow checkout; the index needs each file's last
# commit date. A blobless clone carries commits + trees only (no file contents).
ARG HISTORY_REPO=https://github.com/stwrt/csswg-drafts.git
ARG HISTORY_BRANCH=mojave
RUN git clone --quiet --filter=blob:none --no-checkout --single-branch \
      --branch "$HISTORY_BRANCH" "$HISTORY_REPO" /hist
ENV GIT_DIR=/hist/.git GIT_WORK_TREE=/src
RUN sh bin/mojave-build.sh

FROM nginx:alpine
COPY --from=build /src /usr/share/nginx/html
EXPOSE 80
