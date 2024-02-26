FROM node:20-slim as base

WORKDIR /app

# install dependencies into temp directory
# this will cache them and speed up future builds
FROM base AS install
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
RUN mkdir -p /temp/dev
COPY package.json package-lock.json /temp/dev/
RUN cd /temp/dev && npm install

# install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json package-lock.json /temp/prod/
RUN cd /temp/prod && npm ci --omit=dev

# copy node_modules from temp directory
# then copy all (non-ignored) project files into the image
FROM base AS prerelease
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

# [optional] tests & build
ENV NODE_ENV=production

RUN npm run build

# copy production dependencies and source code into final image
FROM base AS release
# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apt-get update && apt-get install curl gnupg xvfb -y \
  && curl --location --silent https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install google-chrome-stable -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /app/dist ./dist
COPY ./package.json /app/

CMD ["node", "dist/index.js"]
