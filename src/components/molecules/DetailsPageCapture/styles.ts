import {COLORS, FONTS_STYLES} from 'assets';

export const themeStyles = {
  container: {},
  title: {
    ...FONTS_STYLES.semibold20,
    color: {
      light: COLORS.logCabin,
      dark: COLORS.silver,
    },
    marginBottom: 4,
  },

  subtitle: {
    ...FONTS_STYLES.regular13,
    color: {
      light: COLORS.logCabin,
      dark: COLORS.silver,
    },
  },

  location: {
    ...FONTS_STYLES.regular13,
    color: {
      light: COLORS.cornflowerBlue,
      dark: COLORS.silver,
    },
  },
};
