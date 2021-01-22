import {COLORS, FONTS_STYLES} from 'assets';

export const themeStyles = {
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  text: {
    ...FONTS_STYLES.regular15,
    color: {
      light: COLORS.logCabin,
      dark: COLORS.silver,
    },
    marginLeft: 12,
    marginRight: 'auto',
  },
};
