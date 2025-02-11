import type { CapacitorConfig } from '@capacitor/cli';
import dotenv from 'dotenv';
dotenv.config();

const config: CapacitorConfig = {
	appId: 'com.tertius.todo',
	appName: 'ToDo App',
	webDir: 'build',
	android: {
		buildOptions: {
			keystorePath: './tertius.keystore',
			keystorePassword: process.env.PUBLIC_KEYSTORE_PASSWORD,
			keystoreAlias: process.env.PUBLIC_KEYSTORE_ALIAS,
			keystoreAliasPassword: process.env.PUBLIC_KEYSTORE_PASSWORD,
			releaseType: 'APK',
			signingType: 'apksigner'
		}
	},
	server: {
		androidScheme: 'http',
		url: process.env.PUBLIC_CAPACITOR_DOMAIN
	}
};

export default config;
