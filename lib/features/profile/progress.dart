/// Kurva XP KAGE.
///
/// Level 1 dimulai dari 0 XP. Untuk naik ke level berikutnya, selisih XP yang
/// dibutuhkan bertambah 50 setiap level:
///
/// - Level 2: 100 XP
/// - Level 3: 250 XP (tambahan 150)
/// - Level 4: 450 XP (tambahan 200)
/// - Level 5: 700 XP (tambahan 250)
///
/// Ambang bersifat kumulatif dan tidak memiliki batas level. Level selalu
/// dihitung ulang dari total XP, tidak disimpan terpisah.
int xpForLevel(int level) {
  if (level <= 1) return 0;
  var total = 0;
  var step = 100;
  for (var current = 2; current <= level; current++) {
    total += step;
    step += 50;
  }
  return total;
}

int levelFromXp(int xp) {
  final safeXp = xp < 0 ? 0 : xp;
  var level = 1;
  while (safeXp >= xpForLevel(level + 1)) {
    level++;
  }
  return level;
}

/// Sisa XP yang dibutuhkan untuk mencapai level berikutnya.
int xpToNextLevel(int xp) {
  final safeXp = xp < 0 ? 0 : xp;
  return xpForLevel(levelFromXp(safeXp) + 1) - safeXp;
}

/// XP awal level saat ini, dipakai untuk menghitung progres bar.
int xpAtLevelStart(int xp) => xpForLevel(levelFromXp(xp));
