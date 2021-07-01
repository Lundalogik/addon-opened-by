module.exports = {
    branches: ['main'],
    plugins: [
        ['@semantic-release/commit-analyzer', {
          preset: 'conventionalcommits',
        }],
        ['@semantic-release/release-notes-generator', {
          preset: 'conventionalcommits',
        }],
        '@semantic-release/changelog',
        // [
        //     "@semantic-release/exec",
        //     {
        //         "prepareCmd": "chmod +x ./scripts/replace_version.sh && ./scripts/replace_version.sh ${nextRelease.version}",
        //     },
        // ],
        [
            "@semantic-release/git",
            {
                "assets": ["CHANGELOG.md"],
            },
        ],
        '@semantic-release/github',
    ],
};
