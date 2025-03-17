import replace from "@rollup/plugin-replace";
import typescript from "@rollup/plugin-typescript";

/** @type {(_: any) => import('rollup').RollupOptions} */
export default (_cliArgs) => {
  const isProduction =
    process.env.NODE_ENV && process.env.NODE_ENV === "production";
  return {
    input: "./src/index.tsx",
    output: {
      dir: "../.lake/build/js",
      format: "es",
      sourcemap: isProduction ? false : "inline",
      plugins: isProduction ? [terser()] : [],
      compact: isProduction,
    },
    external: [
      "react",
      "react-dom",
      "react/jsx-runtime",
      "@leanprover/infoview",
    ],
    plugins: [
      typescript(),
      replace({
        "typeof window": JSON.stringify("object"),
        "process.env.NODE_ENV": JSON.stringify(process.env.NODE_ENV),
        preventAssignment: true,
      }),
    ],
  };
};
