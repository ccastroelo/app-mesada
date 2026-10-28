import { afterEach, before, after, describe, it } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  increment,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

const HOUR = 60 * 60 * 1000;
const inHours = (h) => Timestamp.fromMillis(Date.now() + h * HOUR);

let env;

const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080').split(':');

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mesada',
    firestore: {
      host,
      port: Number(port),
      rules: readFileSync('../firestore.rules', 'utf8'),
    },
  });
});

after(async () => {
  await env.cleanup();
});

afterEach(async () => {
  await env.clearFirestore();
});

const as = (uid) =>
  env.authenticatedContext(uid, { email: `${uid}@example.com` }).firestore();
const anon = () => env.unauthenticatedContext().firestore();
const seed = (fn) => env.withSecurityRulesDisabled((c) => fn(c.firestore()));

/** Família com um membro, criada direto no banco (sem passar pelas regras). */
const seedFamily = (fid, ownerUid) =>
  seed(async (db) => {
    await setDoc(doc(db, 'families', fid), {
      name: 'Família',
      createdBy: ownerUid,
      createdAt: Timestamp.now(),
    });
    await setDoc(doc(db, 'families', fid, 'members', ownerUid), {
      email: `${ownerUid}@example.com`,
      joinedAt: Timestamp.now(),
    });
  });

const seedInvite = (code, fid, { usedBy = null, expiresAt = inHours(24) } = {}) =>
  seed((db) =>
    setDoc(doc(db, 'invites', code), {
      familyId: fid,
      createdBy: 'ana',
      expiresAt,
      usedBy,
    }),
  );

/** O que o app faz ao criar a família (lote 1). */
const createFamily = (db, uid, fid = 'f1') => {
  const batch = writeBatch(db);
  batch.set(doc(db, 'families', fid), {
    name: 'Família Castro',
    createdBy: uid,
    createdAt: serverTimestamp(),
  });
  batch.set(doc(db, 'families', fid, 'members', uid), {
    email: `${uid}@example.com`,
    joinedAt: serverTimestamp(),
  });
  return batch.commit();
};

/** O que o app faz ao entrar com um código (um único lote). */
const joinWithCode = (db, uid, code, fid = 'f1') => {
  const batch = writeBatch(db);
  batch.set(doc(db, 'families', fid, 'members', uid), {
    email: `${uid}@example.com`,
    joinedAt: serverTimestamp(),
    code,
  });
  batch.update(doc(db, 'invites', code), { usedBy: uid });
  batch.set(doc(db, 'users', uid), { familyId: fid });
  return batch.commit();
};

describe('sem login', () => {
  it('não lê nem escreve nada', async () => {
    await seedFamily('f1', 'ana');
    const db = anon();
    await assertFails(getDoc(doc(db, 'families', 'f1')));
    await assertFails(getDocs(collection(db, 'families', 'f1', 'children')));
    await assertFails(setDoc(doc(db, 'users', 'x'), { familyId: 'f1' }));
  });
});

describe('usuário', () => {
  it('lê e grava só o próprio vínculo', async () => {
    await assertSucceeds(setDoc(doc(as('ana'), 'users', 'ana'), { familyId: 'f1' }));
    await assertFails(setDoc(doc(as('ana'), 'users', 'bia'), { familyId: 'f1' }));
    await assertFails(getDoc(doc(as('bia'), 'users', 'ana')));
  });

  it('rejeita campos extras', async () => {
    await assertFails(
      setDoc(doc(as('ana'), 'users', 'ana'), { familyId: 'f1', admin: true }),
    );
  });
});

describe('criar família', () => {
  it('criador cria a família e entra como membro', async () => {
    await assertSucceeds(createFamily(as('ana'), 'ana'));
    await assertSucceeds(getDoc(doc(as('ana'), 'families', 'f1')));
  });

  it('não dá para criar família em nome de outro', async () => {
    await assertFails(
      setDoc(doc(as('ana'), 'families', 'f1'), {
        name: 'Fraude',
        createdBy: 'bia',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('exige nome não vazio', async () => {
    await assertFails(
      setDoc(doc(as('ana'), 'families', 'f1'), {
        name: '',
        createdBy: 'ana',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('estranho não se adiciona como membro de família alheia', async () => {
    await seedFamily('f1', 'ana');
    await assertFails(
      setDoc(doc(as('eva'), 'families', 'f1', 'members', 'eva'), {
        email: 'eva@example.com',
        joinedAt: serverTimestamp(),
      }),
    );
  });

  it('família não pode ser apagada', async () => {
    await seedFamily('f1', 'ana');
    await assertFails(deleteDoc(doc(as('ana'), 'families', 'f1')));
  });

  it('membro só altera o nome', async () => {
    await seedFamily('f1', 'ana');
    await assertSucceeds(updateDoc(doc(as('ana'), 'families', 'f1'), { name: 'Novo' }));
    await assertFails(
      updateDoc(doc(as('ana'), 'families', 'f1'), { createdBy: 'eva' }),
    );
    await assertFails(updateDoc(doc(as('eva'), 'families', 'f1'), { name: 'Hack' }));
  });
});

describe('dados da família', () => {
  it('membro lê e escreve filhos, regras e lançamentos', async () => {
    await seedFamily('f1', 'ana');
    const db = as('ana');
    await assertSucceeds(
      setDoc(doc(db, 'families', 'f1', 'children', 'c1'), {
        name: 'Lucas',
        email: '',
        allowanceCents: 10000,
      }),
    );
    await assertSucceeds(
      setDoc(doc(db, 'families', 'f1', 'rules', 'r1'), {
        description: 'Arrumar a cama',
        valueCents: 50,
      }),
    );
    await assertSucceeds(
      setDoc(doc(db, 'families', 'f1', 'entries', 'c1_r1'), {
        childId: 'c1',
        ruleId: 'r1',
        quantity: 0,
        enabled: true,
      }),
    );
    await assertSucceeds(getDocs(collection(db, 'families', 'f1', 'children')));
  });

  it('quem não é membro não lê nem escreve', async () => {
    await seedFamily('f1', 'ana');
    const db = as('eva');
    await assertFails(getDocs(collection(db, 'families', 'f1', 'children')));
    await assertFails(getDocs(collection(db, 'families', 'f1', 'entries')));
    await assertFails(
      setDoc(doc(db, 'families', 'f1', 'rules', 'r1'), {
        description: 'x',
        valueCents: 1,
      }),
    );
  });

  it('membro de uma família não acessa outra', async () => {
    await seedFamily('f1', 'ana');
    await seedFamily('f2', 'bia');
    await assertFails(getDocs(collection(as('ana'), 'families', 'f2', 'children')));
  });

  it('valida dinheiro em centavos inteiros e limites', async () => {
    await seedFamily('f1', 'ana');
    const db = as('ana');
    const child = (data) => setDoc(doc(db, 'families', 'f1', 'children', 'c1'), data);
    await assertFails(child({ name: 'Lucas', email: '', allowanceCents: 100.5 }));
    await assertFails(child({ name: 'Lucas', email: '', allowanceCents: -1 }));
    await assertFails(child({ name: 'Lucas', email: '', allowanceCents: 100000000 }));
    await assertFails(child({ name: '', email: '', allowanceCents: 100 }));
    const rule = (data) => setDoc(doc(db, 'families', 'f1', 'rules', 'r1'), data);
    await assertFails(rule({ description: 'x', valueCents: 0.5 }));
    await assertFails(rule({ description: 'x', valueCents: 100000 }));
    await assertSucceeds(rule({ description: 'Desconto', valueCents: -50 }));
  });

  it('lançamento: id deve ser filho_regra e quantidade nunca negativa', async () => {
    await seedFamily('f1', 'ana');
    const db = as('ana');
    const entry = (id, data) => setDoc(doc(db, 'families', 'f1', 'entries', id), data);
    await assertFails(
      entry('qualquer', { childId: 'c1', ruleId: 'r1', quantity: 0, enabled: true }),
    );
    await assertFails(
      entry('c1_r1', { childId: 'c1', ruleId: 'r1', quantity: -1, enabled: true }),
    );
    await assertFails(
      entry('c1_r1', { childId: 'c1', ruleId: 'r1', quantity: 1.5, enabled: true }),
    );
    await assertSucceeds(
      entry('c1_r1', { childId: 'c1', ruleId: 'r1', quantity: 2, enabled: true }),
    );
  });

  it('increment atômico: +1 passa, mas não deixa a quantidade ficar negativa', async () => {
    await seedFamily('f1', 'ana');
    const db = as('ana');
    const ref = doc(db, 'families', 'f1', 'entries', 'c1_r1');
    await seed((d) =>
      setDoc(doc(d, 'families', 'f1', 'entries', 'c1_r1'), {
        childId: 'c1',
        ruleId: 'r1',
        quantity: 0,
        enabled: true,
      }),
    );
    await assertSucceeds(updateDoc(ref, { quantity: increment(1) }));
    await assertSucceeds(updateDoc(ref, { quantity: increment(-1) }));
    await assertFails(updateDoc(ref, { quantity: increment(-1) }));
  });
});

describe('convites', () => {
  it('membro cria convite de até 48 h', async () => {
    await seedFamily('f1', 'ana');
    await assertSucceeds(
      setDoc(doc(as('ana'), 'invites', 'ABC123'), {
        familyId: 'f1',
        createdBy: 'ana',
        expiresAt: inHours(48 - 1),
        usedBy: null,
      }),
    );
  });

  it('rejeita convite com validade acima de 48 h ou já expirado', async () => {
    await seedFamily('f1', 'ana');
    const db = as('ana');
    const invite = (code, expiresAt) =>
      setDoc(doc(db, 'invites', code), {
        familyId: 'f1',
        createdBy: 'ana',
        expiresAt,
        usedBy: null,
      });
    await assertFails(invite('LONGO1', inHours(72)));
    await assertFails(invite('PASSOU', inHours(-1)));
  });

  it('não-membro não cria convite para a família', async () => {
    await seedFamily('f1', 'ana');
    await assertFails(
      setDoc(doc(as('eva'), 'invites', 'ABC123'), {
        familyId: 'f1',
        createdBy: 'eva',
        expiresAt: inHours(24),
        usedBy: null,
      }),
    );
  });

  it('qualquer logado lê pelo código, mas ninguém lista', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    await assertSucceeds(getDoc(doc(as('eva'), 'invites', 'ABC123')));
    await assertFails(getDocs(collection(as('eva'), 'invites')));
    await assertFails(getDoc(doc(anon(), 'invites', 'ABC123')));
  });
});

describe('entrar com código', () => {
  it('convidado entra, vira membro e enxerga os dados', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    await assertSucceeds(joinWithCode(as('bia'), 'bia', 'ABC123'));
    await assertSucceeds(getDocs(collection(as('bia'), 'families', 'f1', 'children')));
  });

  it('o código é de uso único', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    await assertSucceeds(joinWithCode(as('bia'), 'bia', 'ABC123'));
    await assertFails(joinWithCode(as('eva'), 'eva', 'ABC123'));
  });

  it('convite expirado não vale', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('VELHO1', 'f1', { expiresAt: inHours(-1) });
    await assertFails(joinWithCode(as('bia'), 'bia', 'VELHO1'));
  });

  it('código inexistente não vale', async () => {
    await seedFamily('f1', 'ana');
    await assertFails(joinWithCode(as('bia'), 'bia', 'NAOEXI'));
  });

  it('convite de uma família não abre outra', async () => {
    await seedFamily('f1', 'ana');
    await seedFamily('f2', 'carlos');
    await seedInvite('ABC123', 'f1');
    await assertFails(joinWithCode(as('bia'), 'bia', 'ABC123', 'f2'));
  });

  it('não dá para entrar sem consumir o convite no mesmo lote', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    await assertFails(
      setDoc(doc(as('bia'), 'families', 'f1', 'members', 'bia'), {
        email: 'bia@example.com',
        joinedAt: serverTimestamp(),
        code: 'ABC123',
      }),
    );
  });

  it('não dá para queimar o convite de outro sem virar membro', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    await assertFails(updateDoc(doc(as('eva'), 'invites', 'ABC123'), { usedBy: 'eva' }));
  });

  it('não dá para entrar em nome de outro usuário', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    const db = as('eva');
    const batch = writeBatch(db);
    batch.set(doc(db, 'families', 'f1', 'members', 'bia'), {
      email: 'bia@example.com',
      joinedAt: serverTimestamp(),
      code: 'ABC123',
    });
    batch.update(doc(db, 'invites', 'ABC123'), { usedBy: 'bia' });
    await assertFails(batch.commit());
  });
});

describe('sair da família', () => {
  it('cada um remove só o próprio vínculo', async () => {
    await seedFamily('f1', 'ana');
    await seedInvite('ABC123', 'f1');
    await joinWithCode(as('bia'), 'bia', 'ABC123');
    await assertFails(deleteDoc(doc(as('bia'), 'families', 'f1', 'members', 'ana')));
    await assertSucceeds(deleteDoc(doc(as('bia'), 'families', 'f1', 'members', 'bia')));
    await assertFails(getDocs(collection(as('bia'), 'families', 'f1', 'children')));
  });
});
