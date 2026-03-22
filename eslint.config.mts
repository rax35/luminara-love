import * as eslint from "@eslint/js";
import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig(
  { ignores: ["eslint.config.mts"] },
  eslint.configs.recommended,
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        allowDefaultProject: true,
      },
    },
  },
  {
    linterOptions: {
      reportUnusedInlineConfigs: "error",
    },
  },
  {
    rules: {
      eqeqeq: "error",
      "@typescript-eslint/strict-boolean-expressions": "error",
    },
  },
);
