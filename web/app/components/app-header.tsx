'use client';

import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Toolbar from '@mui/material/Toolbar';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useColorScheme } from '@mui/material/styles';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LightModeIcon from '@mui/icons-material/LightMode';
import LockIcon from '@mui/icons-material/Lock';
import SmartphoneIcon from '@mui/icons-material/Smartphone';
import LanguageIcon from '@mui/icons-material/Language';

import { useBridge } from '../bridge-provider';

function ColorSchemeToggle() {
  // mode は 'system' を取りうるため、実際に適用されている colorScheme で判定する。
  const { colorScheme, setMode } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <Tooltip title={isDark ? 'ライトモードに切り替え' : 'ダークモードに切り替え'}>
      <IconButton
        color="inherit"
        aria-label="カラーテーマを切り替える"
        onClick={() => setMode(isDark ? 'light' : 'dark')}
      >
        {isDark ? <LightModeIcon /> : <DarkModeIcon />}
      </IconButton>
    </Tooltip>
  );
}

export function AppHeader() {
  const { hydrated, connected } = useBridge();

  return (
    <AppBar
      position="sticky"
      sx={{
        backdropFilter: 'blur(12px)',
        backgroundColor: 'rgba(var(--mui-palette-background-defaultChannel) / 0.8)',
        borderBottom: 1,
        borderColor: 'divider',
      }}
    >
      <Toolbar sx={{ gap: 1.5 }}>
        <Box
          sx={{
            display: 'grid',
            placeItems: 'center',
            width: 38,
            height: 38,
            borderRadius: 2,
            bgcolor: 'primary.main',
            color: 'primary.contrastText',
            flexShrink: 0,
          }}
        >
          <LockIcon fontSize="small" />
        </Box>
        <Stack sx={{ minWidth: 0, flexGrow: 1 }}>
          <Typography variant="h1" component="h1" noWrap>
            SMS 認証サンプル
          </Typography>
          <Typography variant="caption" color="text.secondary" noWrap>
            電話番号 → 6 桁コード → 結果確認
          </Typography>
        </Stack>
        <Chip
          size="small"
          variant={connected ? 'filled' : 'outlined'}
          color={connected ? 'success' : 'default'}
          icon={connected ? <SmartphoneIcon /> : <LanguageIcon />}
          label={!hydrated ? '確認中' : connected ? 'WebView' : 'ブラウザ'}
        />
        <ColorSchemeToggle />
      </Toolbar>
    </AppBar>
  );
}
