'use client';

import { createTheme } from '@mui/material/styles';

const fontFamily = [
  '-apple-system',
  'BlinkMacSystemFont',
  '"Segoe UI"',
  'Roboto',
  '"Helvetica Neue"',
  '"Hiragino Sans"',
  '"Noto Sans JP"',
  'Arial',
  'sans-serif',
].join(',');

const monoFontFamily = ['"SF Mono"', '"Roboto Mono"', 'Menlo', 'Consolas', 'monospace'].join(',');

/**
 * 配色。`AuthWithWebView/AppTheme.swift` の `WebPalette` と同じ値を持たせ、
 * セーフエリアの余白と WebView の背景を継ぎ目なく見せる。値を変えたら両方を直すこと。
 */
const theme = createTheme({
  cssVariables: { colorSchemeSelector: 'class' },
  colorSchemes: {
    light: {
      palette: {
        primary: { main: '#00695f' },
        secondary: { main: '#3f6cb4' },
        success: { main: '#2e7d32' },
        warning: { main: '#b26a00' },
        error: { main: '#c62828' },
        background: { default: '#f2f6f5', paper: '#ffffff' },
      },
    },
    dark: {
      palette: {
        primary: { main: '#5fd4c0' },
        secondary: { main: '#9dbdf5' },
        success: { main: '#7bd88f' },
        warning: { main: '#e6b25a' },
        error: { main: '#ef9a9a' },
        background: { default: '#0e1414', paper: '#161d1d' },
      },
    },
  },
  shape: { borderRadius: 14 },
  typography: {
    fontFamily,
    h1: { fontSize: '1.15rem', fontWeight: 700, letterSpacing: '-0.01em' },
    h2: { fontSize: '0.975rem', fontWeight: 700, letterSpacing: '-0.01em' },
    subtitle2: { fontWeight: 600 },
    button: { textTransform: 'none', fontWeight: 600 },
    caption: { letterSpacing: 0 },
  },
  components: {
    MuiCard: {
      defaultProps: { variant: 'outlined' },
      styleOverrides: { root: { overflow: 'visible' } },
    },
    MuiButton: {
      defaultProps: { disableElevation: true },
      styleOverrides: { root: { borderRadius: 999 } },
    },
    MuiChip: {
      styleOverrides: { root: { fontWeight: 600 } },
    },
    MuiTextField: {
      defaultProps: { fullWidth: true },
    },
    MuiAppBar: {
      defaultProps: { elevation: 0, color: 'transparent' },
    },
  },
});

export { monoFontFamily };
export default theme;
