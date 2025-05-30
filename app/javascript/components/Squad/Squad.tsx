import React, { useState, useEffect } from 'react';

import type { TeamNames } from 'entities';
import { sportsData, SportPosition, LineupPlayer } from 'entities';
import { localizeValue, showAlert, csrfToken } from 'helpers';

import { Week } from 'components';

import { apiRequest } from 'requests/helpers/apiRequest';
import { teamsRequest } from 'requests/teamsRequest';
import { lineupPlayersRequest } from './requests/lineupPlayersRequest';

interface SquadProps {
  seasonId: string;
  sportKind: string;
  lineupId: string;
  weekId: number;
  weekDeadlineAt: string;
}

export const Squad = ({
  seasonId,
  sportKind,
  lineupId,
  weekId,
  weekDeadlineAt,
}: SquadProps): JSX.Element => {
  // static data
  const [teamNames, setTeamNames] = useState<TeamNames>({});
  const [lineupPlayers, setLineupPlayers] = useState<LineupPlayer[]>([]);
  // dynamic data
  const [playerIdForChange, setPlayerIdForChange] = useState<number | null>(null);
  const [playerIdsToChange, setPlayerIdsToChange] = useState<number[]>([]);
  const [changeOrder, setChangeOrder] = useState<number>(0);

  useEffect(() => {
    const fetchTeams = async () => {
      const data = await teamsRequest(seasonId);
      setTeamNames(data);
    };

    const fetchLineupPlayers = async () => {
      const data = await lineupPlayersRequest(lineupId);
      setLineupPlayers(data);
    };

    fetchTeams();
    fetchLineupPlayers();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const sportPositions = sportsData.positions[sportKind];
  const sport = sportsData.sports[sportKind];

  const sportPositionName = (sportPosition: SportPosition) => {
    return sportPosition.name.en.split(' ').join('-');
  };

  const activePlayersByPosition = (positionKind: string) => {
    return lineupPlayers.filter(
      (element: LineupPlayer) => element.active && element.player.position_kind === positionKind,
    );
  };

  const reservePlayers = () => {
    return lineupPlayers
      .filter((element: LineupPlayer) => {
        return !element.active;
      })
      .sort((a: LineupPlayer, b: LineupPlayer) => {
        return a.change_order > b.change_order ? 1 : -1;
      });
  };

  const oppositeTeamNames = (item: LineupPlayer) => {
    const values = item.team.opposite_team_ids;
    if (values.length === 0) return '-';

    return values.map((element: number) => teamNames[element].short_name).join(', ');
  };

  const changePlayer = (item: LineupPlayer, isActive: boolean) => {
    if (playerIdForChange === null) {
      // beginning of change selection
      const positionKind = item.player.position_kind;
      const playersToChange = isActive ? reservePlayers() : lineupPlayers;

      let activePlayersOnPosition = isActive ? activePlayersByPosition(positionKind).length : 0;
      let activePlayersOnNextPosition = isActive ? 0 : activePlayersByPosition(positionKind).length;

      const result = playersToChange
        .map((element: LineupPlayer) => {
          // skip for the same player
          if (element.id === item.id) return null;

          const nextPositionKind = element.player.position_kind;
          // allow change for player on the same position
          if (nextPositionKind === positionKind) return element.id;

          // skip change if current position player amount will left less than minimum
          if (!isActive) activePlayersOnPosition = activePlayersByPosition(nextPositionKind).length;
          if (activePlayersOnPosition === sportPositions[positionKind].min_game_amount) return null;
          // skip change if change position player amount will be more than maximum
          if (isActive)
            activePlayersOnNextPosition = activePlayersByPosition(nextPositionKind).length;
          if (activePlayersOnNextPosition === sportPositions[nextPositionKind].max_game_amount)
            return null;
          // allow change for player
          return element.id;
        })
        .filter((element: number | null) => element);

      setPlayerIdsToChange(result as number[]);
      if (result.length > 0) {
        setChangeOrder(item.change_order);
        setPlayerIdForChange(item.id);
      }
    } else {
      if (playerIdsToChange.includes(item.id))
        changePlayers(item.id, !isActive, Math.max(item.change_order, changeOrder));

      setChangeOrder(0);
      setPlayerIdForChange(null);
      setPlayerIdsToChange([]);
    }
  };

  const changePlayers = (
    playerIdToChange: number,
    stateForInitialPlayer: boolean,
    changeOrderValue: number,
  ) => {
    // playerIdToChange - id of changeable player
    // playerIdForChange - id of initial player
    // stateForInitialPlayer - new state for initial player
    setLineupPlayers(
      lineupPlayers.map((element: LineupPlayer) => {
        if (element.id === playerIdToChange) {
          element.active = stateForInitialPlayer;
          element.change_order = stateForInitialPlayer ? 0 : changeOrderValue;
        }
        if (element.id === playerIdForChange) {
          element.active = !stateForInitialPlayer;
          element.change_order = stateForInitialPlayer ? changeOrderValue : 0;
        }
        return element;
      }),
    );
  };

  const classListForPlayerCard = (id: number) => {
    return [
      'player-card',
      playerIdForChange === id ? 'for-change' : '',
      playerIdsToChange.includes(id) ? 'to-change' : '',
    ].join(' ');
  };

  const submit = async () => {
    const payload = {
      data: lineupPlayers.map((element: LineupPlayer) => {
        return {
          id: element.id,
          active: element.active,
          change_order: element.change_order,
        };
      }),
    };

    const requestOptions = {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ lineup_players: payload }),
    };

    const submitResult = await apiRequest({
      url: `/lineups/${lineupId}/players.json`,
      options: requestOptions,
    });
    if (submitResult.message) {
      showAlert('notice', `<p>${submitResult.message}</p>`);
    } else {
      submitResult.errors.forEach((error: string) => showAlert('alert', `<p>${error}</p>`));
    }
  };

  return (
    <>
      <h1>Pick team</h1>
      <div className="deadline flex items-center justify-center">
        <span>Gameweek 1 deadline:</span>
        <span>{weekDeadlineAt}</span>
      </div>
      <div id="team-players-by-positions" className={sportKind}>
        {Object.entries(sportPositions).map(([positionKind, sportPosition]) => (
          <div
            className={`sport-position ${sportPositionName(sportPosition as SportPosition)}`}
            key={positionKind}
          >
            {activePlayersByPosition(positionKind).map((item: LineupPlayer) => (
              <div className="player-card-box" key={item.id}>
                <div className={classListForPlayerCard(item.id)}>
                  <p className="player-team-name">{teamNames[item.team.id]?.short_name}</p>
                  <p className="player-name">{localizeValue(item.player.name).split(' ')[0]}</p>
                  <p className="player-value">{oppositeTeamNames(item)}</p>
                  {sport.changes ? (
                    <div className="action" onClick={() => changePlayer(item, true)}>
                      +/-
                    </div>
                  ) : null}
                </div>
              </div>
            ))}
          </div>
        ))}
      </div>
      {sport.changes && (
        <div className="substitutions">
          {reservePlayers().map((item: LineupPlayer) => (
            <div className="player-card-box" key={item.id}>
              <div className={classListForPlayerCard(item.id)}>
                <p className="player-team-name">{teamNames[item.team.id]?.short_name}</p>
                <p className="player-name">{localizeValue(item.player.name).split(' ')[0]}</p>
                <p className="player-value">{oppositeTeamNames(item)}</p>
                <div className="action" onClick={() => changePlayer(item, false)}>
                  +/-
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
      <div id="submit-button">
        <button className="button" onClick={submit}>
          Save team
        </button>
      </div>
      {Object.keys(teamNames).length > 0 ? <Week id={weekId} teamNames={teamNames} /> : null}
    </>
  );
};
