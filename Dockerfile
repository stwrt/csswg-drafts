# Builds CSSWG editor's drafts with Bikeshed and serves them as a static site.
# Mirrors .github/workflows/build-specs.yml. SPECS selects which drafts to
# build ("all" builds every Overview.bs — takes a while).
FROM python:3.13-slim AS build
RUN pip install --no-cache-dir bikeshed && bikeshed update
WORKDIR /src
COPY . .
ARG SPECS="css-grid-3 css-anchor-position-1 css-view-transitions-2 css-values-5 css-color-5 css-conditional-5 css-nesting-1 css-scroll-snap-2"
ENV SPECS=$SPECS
RUN sh bin/mojave-build.sh /out

FROM nginx:alpine
COPY --from=build /out /usr/share/nginx/html
EXPOSE 80
