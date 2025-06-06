import { SportsData } from './types';

export const sportsData: SportsData = {
  sports: {
    football: {
      name: { en: 'Football', ru: 'Футбол' },
      max_players: 15,
      max_active_players: 11,
      max_team_players: 3,
      free_transfers_per_week: 1,
      points_per_transfer: 4,
      changes: true,
    },
    basketball: {
      name: { en: 'Basketball', ru: 'Баскетбол' },
      max_players: 10,
      max_active_players: 10,
      max_team_players: 2,
      free_transfers_per_week: 1,
      points_per_transfer: 4,
      changes: false,
    },
    hockey: {
      name: { en: 'Hockey', ru: 'Хоккей' },
      max_players: 21,
      max_active_players: 17,
      max_team_players: 2,
      free_transfers_per_week: 1,
      points_per_transfer: 4,
      changes: true,
    },
  },
  positions: {
    football: {
      football_goalkeeper: {
        name: { en: 'Goalkeeper', ru: 'Вратарь' },
        short_name: { en: 'GKP', ru: 'ВРТ' },
        total_amount: 2,
        default_amount: 1,
        min_game_amount: 1,
        max_game_amount: 1,
      },
      football_defender: {
        name: { en: 'Defender', ru: 'Защитник' },
        short_name: { en: 'DEF', ru: 'ЗАЩ' },
        total_amount: 5,
        default_amount: 4,
        min_game_amount: 3,
        max_game_amount: 5,
      },
      football_midfielder: {
        name: { en: 'Midfielder', ru: 'Полузащитник' },
        short_name: { en: 'MID', ru: 'ПЗАЩ' },
        total_amount: 5,
        default_amount: 4,
        min_game_amount: 2,
        max_game_amount: 5,
      },
      football_forward: {
        name: { en: 'Forward', ru: 'Нападающий' },
        short_name: { en: 'FWD', ru: 'НАП' },
        total_amount: 3,
        default_amount: 2,
        min_game_amount: 1,
        max_game_amount: 3,
      },
    },
    basketball: {
      basketball_center: {
        name: { en: 'Center', ru: 'Центровой' },
        short_name: { en: 'CENT', ru: 'ЦЕНТ' },
        total_amount: 2,
        default_amount: 2,
        min_game_amount: 2,
        max_game_amount: 2,
      },
      basketball_power_forward: {
        name: { en: 'Power Forward', ru: 'Тяжёлый форвард' },
        short_name: { en: 'PFWD', ru: 'ТФВД' },
        total_amount: 2,
        default_amount: 2,
        min_game_amount: 2,
        max_game_amount: 2,
      },
      basketball_small_forward: {
        name: { en: 'Small Forward', ru: 'Лёгкий форвард' },
        short_name: { en: 'SFWS', ru: 'ЛФВД' },
        total_amount: 2,
        default_amount: 2,
        min_game_amount: 2,
        max_game_amount: 2,
      },
      basketball_point_guard: {
        name: { en: 'Point Guard', ru: 'Разыгрывающий защитник' },
        short_name: { en: 'PGRD', ru: 'РЗАЩ' },
        total_amount: 2,
        default_amount: 2,
        min_game_amount: 2,
        max_game_amount: 2,
      },
      basketball_shooting_guard: {
        name: { en: 'Shooting Guard', ru: 'Атакующий защитник' },
        short_name: { en: 'SGRD', ru: 'АЗАЩ' },
        total_amount: 2,
        default_amount: 2,
        min_game_amount: 2,
        max_game_amount: 2,
      },
    },
    hockey: {
      hockey_goalkeeper: {
        name: { en: 'Goalie', ru: 'Вратарь' },
        short_name: { en: 'GKP', ru: 'ВРТ' },
        total_amount: 3,
        default_amount: 2,
        min_game_amount: 2,
        max_game_amount: 2,
      },
      hockey_defender: {
        name: { en: 'Defenseman', ru: 'Защитник' },
        short_name: { en: 'DEF', ru: 'ЗАЩ' },
        total_amount: 7,
        default_amount: 6,
        min_game_amount: 6,
        max_game_amount: 6,
      },
      hockey_forward: {
        name: { en: 'Forward', ru: 'Нападающий' },
        short_name: { en: 'FWD', ru: 'НАП' },
        total_amount: 11,
        default_amount: 9,
        min_game_amount: 9,
        max_game_amount: 9,
      },
    },
  },
};
